#!/usr/bin/env bun
// $PAI_DIR/hooks/event-query.ts
// Query helpers for deriving state from events
// Usage: bun event-query.ts <command> [project] [options]

import { existsSync, readdirSync } from 'fs';
import { join, basename } from 'path';
import { Database } from 'bun:sqlite';

const EVENTS_DIR = process.env.PAI_DIR
  ? join(process.env.PAI_DIR, 'events')
  : join(process.env.HOME!, '.claude', 'events');

function getProject(): string {
  try {
    const proc = Bun.spawnSync(['git', 'rev-parse', '--show-toplevel'], {
      stdout: 'pipe',
      stderr: 'pipe'
    });
    if (proc.exitCode === 0) {
      return basename(proc.stdout.toString().trim());
    }
  } catch {}
  return basename(process.cwd());
}

function getDb(project: string): Database | null {
  const dbPath = join(EVENTS_DIR, `${project}.db`);
  if (!existsSync(dbPath)) {
    console.error(`No events for project: ${project}`);
    return null;
  }
  return new Database(dbPath, { readonly: true });
}

function listProjects(): void {
  if (!existsSync(EVENTS_DIR)) {
    console.log('No events directory');
    return;
  }

  const files = readdirSync(EVENTS_DIR).filter(f => f.endsWith('.db'));
  console.log('Projects with events:');
  for (const f of files) {
    const project = f.replace('.db', '');
    const db = new Database(join(EVENTS_DIR, f), { readonly: true });
    const count = db.query('SELECT COUNT(*) as c FROM events').get() as { c: number };
    const latest = db.query('SELECT MAX(timestamp) as t FROM events').get() as { t: string };
    db.close();
    console.log(`  ${project}: ${count.c} events, last: ${latest.t || 'never'}`);
  }
}

function projectStatus(project: string): void {
  const db = getDb(project);
  if (!db) return;

  console.log(`\n=== ${project} ===\n`);

  // Recent slices
  const slices = db.query(`
    SELECT slice_id, timestamp, json_extract(data, '$.prompt_preview') as prompt
    FROM events
    WHERE event_type = 'slice_started'
    ORDER BY timestamp DESC
    LIMIT 5
  `).all() as { slice_id: string; timestamp: string; prompt: string }[];

  console.log('Recent slices:');
  for (const s of slices) {
    console.log(`  [${s.timestamp}] ${s.prompt || '(no prompt)'}`);
  }

  // Files modified
  const files = db.query(`
    SELECT entity_id as file, COUNT(*) as edits, MAX(timestamp) as last
    FROM events
    WHERE event_type IN ('file_created', 'file_modified')
    GROUP BY entity_id
    ORDER BY last DESC
    LIMIT 10
  `).all() as { file: string; edits: number; last: string }[];

  console.log('\nRecent files:');
  for (const f of files) {
    console.log(`  ${f.file} (${f.edits} edits, last: ${f.last})`);
  }

  // Commands
  const commands = db.query(`
    SELECT json_extract(data, '$.command') as cmd, json_extract(data, '$.success') as success, timestamp
    FROM events
    WHERE event_type = 'command_executed'
    ORDER BY timestamp DESC
    LIMIT 5
  `).all() as { cmd: string; success: number; timestamp: string }[];

  console.log('\nRecent commands:');
  for (const c of commands) {
    const status = c.success ? '✓' : '✗';
    console.log(`  ${status} ${c.cmd?.substring(0, 60) || '?'}`);
  }

  // Event summary
  const summary = db.query(`
    SELECT event_type, COUNT(*) as count
    FROM events
    GROUP BY event_type
    ORDER BY count DESC
  `).all() as { event_type: string; count: number }[];

  console.log('\nEvent summary:');
  for (const s of summary) {
    console.log(`  ${s.event_type}: ${s.count}`);
  }

  db.close();
}

function sliceEvents(project: string, sliceId?: string): void {
  const db = getDb(project);
  if (!db) return;

  // Get latest slice if not specified
  if (!sliceId) {
    const latest = db.query(`
      SELECT slice_id FROM events
      WHERE event_type = 'slice_started'
      ORDER BY timestamp DESC
      LIMIT 1
    `).get() as { slice_id: string } | null;

    if (!latest) {
      console.log('No slices found');
      db.close();
      return;
    }
    sliceId = latest.slice_id;
  }

  const events = db.query(`
    SELECT timestamp, event_type, entity_type, entity_id, data
    FROM events
    WHERE slice_id = ?
    ORDER BY timestamp
  `).all(sliceId) as { timestamp: string; event_type: string; entity_type: string; entity_id: string; data: string }[];

  console.log(`\nSlice: ${sliceId}\n`);
  for (const e of events) {
    const data = e.data ? JSON.parse(e.data) : {};
    const detail = e.entity_id || data.prompt_preview || data.command?.substring(0, 40) || '';
    console.log(`  [${e.timestamp}] ${e.event_type}: ${detail}`);
  }

  db.close();
}

function recentActivity(days: number = 7): void {
  if (!existsSync(EVENTS_DIR)) {
    console.log('No events directory');
    return;
  }

  console.log(`\nActivity in last ${days} days:\n`);

  const files = readdirSync(EVENTS_DIR).filter(f => f.endsWith('.db'));
  for (const f of files) {
    const project = f.replace('.db', '');
    const db = new Database(join(EVENTS_DIR, f), { readonly: true });

    const activity = db.query(`
      SELECT
        COUNT(*) as events,
        COUNT(DISTINCT slice_id) as slices,
        COUNT(DISTINCT session_id) as sessions
      FROM events
      WHERE timestamp > datetime('now', '-${days} days')
    `).get() as { events: number; slices: number; sessions: number };

    if (activity.events > 0) {
      console.log(`${project}: ${activity.events} events, ${activity.slices} slices, ${activity.sessions} sessions`);
    }

    db.close();
  }
}

// CLI
const [cmd, ...args] = process.argv.slice(2);

switch (cmd) {
  case 'projects':
  case 'ls':
    listProjects();
    break;

  case 'status':
  case 'st':
    projectStatus(args[0] || getProject());
    break;

  case 'slice':
    sliceEvents(args[0] || getProject(), args[1]);
    break;

  case 'recent':
    recentActivity(parseInt(args[0]) || 7);
    break;

  default:
    console.log(`Usage: event-query <command> [project] [options]

Commands:
  projects, ls     List all projects with events
  status, st       Show project status (files, commands, summary)
  slice [id]       Show events for a slice (latest if no ID)
  recent [days]    Show recent activity across projects
`);
}
