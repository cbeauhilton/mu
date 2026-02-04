#!/usr/bin/env bun
// $PAI_DIR/hooks/load-event-context.ts
// SessionStart hook: Restore context from event store
// Makes the SQLite DB the system of record - pick up where we left off

import { existsSync } from 'fs';
import { join, basename } from 'path';
import { Database } from 'bun:sqlite';

const EVENTS_DIR = process.env.PAI_DIR
  ? join(process.env.PAI_DIR, 'events')
  : join(process.env.HOME!, '.claude', 'events');

interface SessionStartPayload {
  session_id: string;
  cwd?: string;
  [key: string]: any;
}

function isSubagentSession(): boolean {
  return process.env.CLAUDE_CODE_AGENT !== undefined ||
         process.env.SUBAGENT === 'true';
}

function isFreshSession(): boolean {
  return process.env.CLAUDE_FRESH === '1' ||
         process.env.CLAUDE_FRESH === 'true';
}

function getProject(cwd: string | undefined): string {
  if (!cwd) return 'unknown';

  try {
    const proc = Bun.spawnSync(['git', 'rev-parse', '--show-toplevel'], {
      cwd,
      stdout: 'pipe',
      stderr: 'pipe'
    });
    if (proc.exitCode === 0) {
      return basename(proc.stdout.toString().trim());
    }
  } catch {}

  return basename(cwd);
}

function getDb(project: string): Database | null {
  const dbPath = join(EVENTS_DIR, `${project}.db`);
  if (!existsSync(dbPath)) {
    return null;
  }
  return new Database(dbPath, { readonly: true });
}

function formatTimeAgo(timestamp: string): string {
  const now = new Date();
  const then = new Date(timestamp + 'Z'); // SQLite stores UTC
  const diffMs = now.getTime() - then.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);

  if (diffDays > 0) return `${diffDays}d ago`;
  if (diffHours > 0) return `${diffHours}h ago`;
  if (diffMins > 0) return `${diffMins}m ago`;
  return 'just now';
}

interface SliceInfo {
  slice_id: string;
  timestamp: string;
  prompt: string;
}

interface FileInfo {
  file: string;
  edits: number;
  last: string;
}

interface CommandInfo {
  cmd: string;
  success: number;
  timestamp: string;
}

interface WorkItem {
  id: string;
  description: string;
  status: string;
  created: string;
  context: string;
}

interface HandoffInfo {
  timestamp: string;
  goal: string;
  done: string;
  decisions: string;
  open: string;
  next: string;
  context: string;
}

function buildContext(project: string, db: Database): string {
  const lines: string[] = [];

  // Get last session info
  const lastSlice = db.query(`
    SELECT slice_id, timestamp, json_extract(data, '$.prompt_preview') as prompt
    FROM events
    WHERE event_type = 'slice_started'
    ORDER BY timestamp DESC
    LIMIT 1
  `).get() as SliceInfo | null;

  if (!lastSlice) {
    return ''; // No history for this project
  }

  lines.push(`📋 RESUMING PROJECT: ${project}`);
  lines.push('');
  lines.push(`Last activity: ${formatTimeAgo(lastSlice.timestamp)}`);
  if (lastSlice.prompt) {
    lines.push(`Last prompt: "${lastSlice.prompt}..."`);
  }

  // Latest handoff from previous session
  const handoff = db.query(`
    SELECT timestamp,
           json_extract(data, '$.goal') as goal,
           json_extract(data, '$.done') as done,
           json_extract(data, '$.decisions') as decisions,
           json_extract(data, '$.open') as open,
           json_extract(data, '$.next') as next,
           json_extract(data, '$.context') as context
    FROM events
    WHERE event_type = 'session_handoff'
    ORDER BY timestamp DESC
    LIMIT 1
  `).get() as HandoffInfo | null;

  if (handoff) {
    lines.push('');
    lines.push(`Handoff (${formatTimeAgo(handoff.timestamp)}):`);
    if (handoff.goal) lines.push(`  Goal: ${handoff.goal}`);

    // Parse JSON arrays, fall back to plain string
    const formatList = (raw: string | null): string[] => {
      if (!raw) return [];
      try {
        const arr = JSON.parse(raw);
        return Array.isArray(arr) ? arr : [String(raw)];
      } catch {
        return [String(raw)];
      }
    };

    const done = formatList(handoff.done);
    if (done.length > 0) {
      lines.push('  Done:');
      for (const d of done) lines.push(`    - ${d}`);
    }

    const decisions = formatList(handoff.decisions);
    if (decisions.length > 0) {
      lines.push('  Decisions:');
      for (const d of decisions) lines.push(`    - ${d}`);
    }

    const open = formatList(handoff.open);
    if (open.length > 0) {
      lines.push('  Open:');
      for (const o of open) lines.push(`    - ${o}`);
    }

    const next = formatList(handoff.next);
    if (next.length > 0) {
      lines.push('  Next:');
      for (const n of next) lines.push(`    - ${n}`);
    }

    const ctx = formatList(handoff.context);
    if (ctx.length > 0) {
      lines.push('  Context:');
      for (const c of ctx) lines.push(`    - ${c}`);
    }
  }

  // Recent files modified
  const files = db.query(`
    SELECT entity_id as file, COUNT(*) as edits, MAX(timestamp) as last
    FROM events
    WHERE event_type IN ('file_created', 'file_modified')
      AND timestamp > datetime('now', '-7 days')
    GROUP BY entity_id
    ORDER BY last DESC
    LIMIT 5
  `).all() as FileInfo[];

  if (files.length > 0) {
    lines.push('');
    lines.push('Recent files:');
    for (const f of files) {
      const shortPath = f.file.replace(process.env.HOME || '', '~');
      lines.push(`  • ${shortPath} (${f.edits} edits)`);
    }
  }

  // Recent commands (significant ones)
  const commands = db.query(`
    SELECT json_extract(data, '$.command') as cmd,
           json_extract(data, '$.success') as success,
           timestamp
    FROM events
    WHERE event_type = 'command_executed'
      AND timestamp > datetime('now', '-1 day')
    ORDER BY timestamp DESC
    LIMIT 3
  `).all() as CommandInfo[];

  if (commands.length > 0) {
    lines.push('');
    lines.push('Recent commands:');
    for (const c of commands) {
      const status = c.success ? '✓' : '✗';
      const shortCmd = c.cmd?.substring(0, 50) || '?';
      lines.push(`  ${status} ${shortCmd}`);
    }
  }

  // Work queue items (pending/blocked tasks)
  const workItems = db.query(`
    SELECT
      event_id as id,
      json_extract(data, '$.description') as description,
      json_extract(data, '$.status') as status,
      timestamp as created,
      json_extract(data, '$.context') as context
    FROM events
    WHERE event_type IN ('work_queued', 'work_blocked')
      AND event_id NOT IN (
        SELECT json_extract(data, '$.work_id')
        FROM events
        WHERE event_type = 'work_completed'
      )
    ORDER BY timestamp DESC
    LIMIT 5
  `).all() as WorkItem[];

  if (workItems.length > 0) {
    lines.push('');
    lines.push('⏳ Open work items:');
    for (const w of workItems) {
      const statusIcon = w.status === 'blocked' ? '🚫' : '📌';
      lines.push(`  ${statusIcon} ${w.description}`);
      if (w.context) {
        lines.push(`      Context: ${w.context}`);
      }
    }
  }

  // Session stats
  const stats = db.query(`
    SELECT
      COUNT(DISTINCT session_id) as sessions,
      COUNT(DISTINCT slice_id) as slices,
      COUNT(*) as events
    FROM events
    WHERE timestamp > datetime('now', '-7 days')
  `).get() as { sessions: number; slices: number; events: number };

  lines.push('');
  lines.push(`Stats (7d): ${stats.sessions} sessions, ${stats.slices} prompts, ${stats.events} events`);

  return lines.join('\n');
}

async function main() {
  try {
    // Skip for subagents
    if (isSubagentSession()) {
      process.exit(0);
    }

    // Skip if fresh session requested
    if (isFreshSession()) {
      console.log('🔄 Fresh session requested - skipping context restoration');
      process.exit(0);
    }

    const stdinData = await Bun.stdin.text();
    if (!stdinData.trim()) {
      process.exit(0);
    }

    const payload: SessionStartPayload = JSON.parse(stdinData);
    const project = getProject(payload.cwd);
    const db = getDb(project);

    if (!db) {
      // No event history for this project - that's fine
      process.exit(0);
    }

    const context = buildContext(project, db);
    db.close();

    if (context) {
      console.log(`<system-reminder>
EVENT STORE CONTEXT (Auto-loaded from ${project}.db)

${context}

To start fresh without this context, set CLAUDE_FRESH=1
</system-reminder>`);
    }

  } catch (error) {
    // Never crash hooks
    console.error('[load-event-context] Error:', error);
  }

  process.exit(0);
}

main();
