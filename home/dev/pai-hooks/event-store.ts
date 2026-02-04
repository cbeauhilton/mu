#!/usr/bin/env bun
// $PAI_DIR/hooks/event-store.ts
// Automatic event sourcing for Claude Code sessions
// Handles: UserPromptSubmit (slice start), PostToolUse (events), SessionStop (session end)
// State = f(events) - current slice derived from events, no mutable state files
//
// CLI Mode: Can also be used to manage work queue
//   bun event-store.ts queue "description" [--context "..."]
//   bun event-store.ts block "description" --reason "..."
//   bun event-store.ts complete <work_id>
//   bun event-store.ts work [--all]
//   bun event-store.ts handoff '<json>'

import { existsSync, mkdirSync } from 'fs';
import { join, basename } from 'path';
import { Database } from 'bun:sqlite';
import { randomUUIDv7 } from 'bun';

const EVENTS_DIR = process.env.PAI_DIR
  ? join(process.env.PAI_DIR, 'events')
  : join(process.env.HOME!, '.claude', 'events');

// Ensure events directory exists
if (!existsSync(EVENTS_DIR)) {
  mkdirSync(EVENTS_DIR, { recursive: true });
}

interface HookPayload {
  session_id: string;
  cwd?: string;
  // UserPromptSubmit
  prompt?: string;
  // PostToolUse
  tool_name?: string;
  tool_input?: Record<string, any>;
  tool_response?: {
    output?: string;
    error?: string;
    [key: string]: any;
  };
  // SessionStop
  [key: string]: any;
}

function getProject(cwd: string | undefined): string {
  if (!cwd) return 'unknown';

  // Try git root first
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

function getDb(project: string): Database {
  const dbPath = join(EVENTS_DIR, `${project}.db`);
  const db = new Database(dbPath);

  // Initialize schema if needed
  db.run(`
    CREATE TABLE IF NOT EXISTS events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      event_id TEXT UNIQUE NOT NULL,
      timestamp TEXT DEFAULT (datetime('now')),
      session_id TEXT NOT NULL,
      slice_id TEXT,
      event_type TEXT NOT NULL,
      entity_type TEXT NOT NULL,
      entity_id TEXT,
      data JSON,
      tags JSON
    )
  `);
  db.run(`CREATE INDEX IF NOT EXISTS idx_session ON events(session_id)`);
  db.run(`CREATE INDEX IF NOT EXISTS idx_slice ON events(slice_id)`);
  db.run(`CREATE INDEX IF NOT EXISTS idx_type ON events(event_type)`);
  db.run(`CREATE INDEX IF NOT EXISTS idx_entity ON events(entity_type, entity_id)`);

  return db;
}

// Derive current slice from events (pure ES - no mutable state)
function getCurrentSlice(project: string, sessionId: string): string | null {
  const db = getDb(project);
  const result = db.query(`
    SELECT slice_id FROM events
    WHERE session_id = ? AND event_type = 'slice_started'
    ORDER BY timestamp DESC LIMIT 1
  `).get(sessionId) as { slice_id: string } | null;
  db.close();
  return result?.slice_id || null;
}

function logEvent(
  project: string,
  sessionId: string,
  sliceId: string | null,
  eventType: string,
  entityType: string,
  entityId: string | null,
  data: Record<string, any>,
  tags: string[] = []
): void {
  const db = getDb(project);
  const eventId = randomUUIDv7();

  db.run(
    `INSERT INTO events (event_id, session_id, slice_id, event_type, entity_type, entity_id, data, tags)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [eventId, sessionId, sliceId, eventType, entityType, entityId, JSON.stringify(data), JSON.stringify(tags)]
  );

  db.close();
}

// Map tool calls to events - keep it focused, not too verbose
function toolToEvent(toolName: string, input: Record<string, any>, response: any): {
  eventType: string;
  entityType: string;
  entityId: string | null;
  data: Record<string, any>;
  tags: string[];
} | null {

  switch (toolName) {
    case 'Write':
      return {
        eventType: 'file_created',
        entityType: 'file',
        entityId: input.file_path,
        data: { lines: input.content?.split('\n').length || 0 },
        tags: ['file', 'write']
      };

    case 'Edit':
      return {
        eventType: 'file_modified',
        entityType: 'file',
        entityId: input.file_path,
        data: {
          old_length: input.old_string?.length || 0,
          new_length: input.new_string?.length || 0
        },
        tags: ['file', 'edit']
      };

    case 'Bash': {
      const cmd = input.command || '';
      // Skip noisy commands
      if (cmd.startsWith('ls') || cmd.startsWith('cat') || cmd.startsWith('echo')) {
        return null;
      }
      // Capture significant commands
      const isGit = cmd.startsWith('git');
      const isTest = cmd.includes('test') || cmd.includes('pytest') || cmd.includes('go test');
      const isBuild = cmd.includes('build') || cmd.includes('compile');

      return {
        eventType: 'command_executed',
        entityType: 'command',
        entityId: cmd.split(' ')[0], // First word as ID
        data: {
          command: cmd.substring(0, 200), // Truncate
          success: !response?.error
        },
        tags: ['command', isGit ? 'git' : '', isTest ? 'test' : '', isBuild ? 'build' : ''].filter(Boolean)
      };
    }

    case 'WebFetch':
      return {
        eventType: 'resource_fetched',
        entityType: 'url',
        entityId: input.url,
        data: { prompt: input.prompt?.substring(0, 100) },
        tags: ['web', 'fetch']
      };

    case 'WebSearch':
      return {
        eventType: 'web_searched',
        entityType: 'search',
        entityId: input.query,
        data: { query: input.query },
        tags: ['web', 'search']
      };

    case 'Task':
      return {
        eventType: 'task_spawned',
        entityType: 'task',
        entityId: input.subagent_type,
        data: {
          description: input.description,
          prompt: input.prompt?.substring(0, 200)
        },
        tags: ['task', input.subagent_type || '']
      };

    case 'TodoWrite':
      return {
        eventType: 'todos_updated',
        entityType: 'todos',
        entityId: null,
        data: {
          count: input.todos?.length || 0,
          in_progress: input.todos?.filter((t: any) => t.status === 'in_progress').length || 0,
          completed: input.todos?.filter((t: any) => t.status === 'completed').length || 0
        },
        tags: ['todos']
      };

    // Skip these - too noisy
    case 'Read':
    case 'Glob':
    case 'Grep':
    case 'LSP':
      return null;

    default:
      return null;
  }
}

async function handleUserPromptSubmit(payload: HookPayload): Promise<void> {
  const project = getProject(payload.cwd);
  const sliceId = randomUUIDv7();
  const promptPreview = (payload.prompt || '').substring(0, 100);

  // Log slice started event (slice is derived from this event later)
  logEvent(
    project,
    payload.session_id,
    sliceId,
    'slice_started',
    'slice',
    sliceId,
    { prompt_preview: promptPreview },
    ['slice', 'start']
  );
}

async function handlePostToolUse(payload: HookPayload): Promise<void> {
  const toolName = payload.tool_name;
  if (!toolName) return;

  // Derive project and slice from payload + events
  const project = getProject(payload.cwd);
  const sliceId = getCurrentSlice(project, payload.session_id);
  if (!sliceId) return; // No active slice for this session

  const event = toolToEvent(
    toolName,
    payload.tool_input || {},
    payload.tool_response
  );

  if (event) {
    logEvent(
      project,
      payload.session_id,
      sliceId,
      event.eventType,
      event.entityType,
      event.entityId,
      event.data,
      event.tags
    );
  }
}

async function handleSessionStop(payload: HookPayload): Promise<void> {
  const project = getProject(payload.cwd);
  const sliceId = getCurrentSlice(project, payload.session_id);

  logEvent(
    project,
    payload.session_id,
    sliceId,
    'session_stopped',
    'session',
    payload.session_id,
    {},
    ['session', 'stop']
  );
}

// =============================================================================
// CLI Mode - Work Queue Management
// =============================================================================

function cliGetProject(): string {
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

function cliQueueWork(description: string, context?: string): void {
  const project = cliGetProject();
  const db = getDb(project);
  const workId = randomUUIDv7();

  db.run(
    `INSERT INTO events (event_id, session_id, slice_id, event_type, entity_type, entity_id, data, tags)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      workId,
      'cli',
      null,
      'work_queued',
      'work',
      workId,
      JSON.stringify({ description, context, status: 'pending' }),
      JSON.stringify(['work', 'queued'])
    ]
  );
  db.close();

  console.log(`✅ Work queued: ${workId.substring(0, 8)}`);
  console.log(`   ${description}`);
}

function cliBlockWork(description: string, reason: string): void {
  const project = cliGetProject();
  const db = getDb(project);
  const workId = randomUUIDv7();

  db.run(
    `INSERT INTO events (event_id, session_id, slice_id, event_type, entity_type, entity_id, data, tags)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      workId,
      'cli',
      null,
      'work_blocked',
      'work',
      workId,
      JSON.stringify({ description, reason, status: 'blocked' }),
      JSON.stringify(['work', 'blocked'])
    ]
  );
  db.close();

  console.log(`🚫 Work blocked: ${workId.substring(0, 8)}`);
  console.log(`   ${description}`);
  console.log(`   Reason: ${reason}`);
}

function cliCompleteWork(workIdPrefix: string): void {
  const project = cliGetProject();
  const db = getDb(project);

  // Find the work item by prefix
  const work = db.query(`
    SELECT event_id, json_extract(data, '$.description') as description
    FROM events
    WHERE event_type IN ('work_queued', 'work_blocked')
      AND event_id LIKE ?
    ORDER BY timestamp DESC
    LIMIT 1
  `).get(workIdPrefix + '%') as { event_id: string; description: string } | null;

  if (!work) {
    console.error(`❌ No work item found matching: ${workIdPrefix}`);
    db.close();
    process.exit(1);
  }

  const completionId = randomUUIDv7();
  db.run(
    `INSERT INTO events (event_id, session_id, slice_id, event_type, entity_type, entity_id, data, tags)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      completionId,
      'cli',
      null,
      'work_completed',
      'work',
      work.event_id,
      JSON.stringify({ work_id: work.event_id, description: work.description }),
      JSON.stringify(['work', 'completed'])
    ]
  );
  db.close();

  console.log(`✅ Work completed: ${work.event_id.substring(0, 8)}`);
  console.log(`   ${work.description}`);
}

function cliListWork(showAll: boolean): void {
  const project = cliGetProject();
  const dbPath = join(EVENTS_DIR, `${project}.db`);

  if (!existsSync(dbPath)) {
    console.log(`No events for project: ${project}`);
    return;
  }

  const db = new Database(dbPath, { readonly: true });

  const query = showAll
    ? `
      SELECT
        e.event_id,
        e.event_type,
        json_extract(e.data, '$.description') as description,
        json_extract(e.data, '$.status') as status,
        json_extract(e.data, '$.reason') as reason,
        json_extract(e.data, '$.context') as context,
        e.timestamp,
        CASE WHEN c.event_id IS NOT NULL THEN 1 ELSE 0 END as completed
      FROM events e
      LEFT JOIN events c ON c.event_type = 'work_completed'
        AND json_extract(c.data, '$.work_id') = e.event_id
      WHERE e.event_type IN ('work_queued', 'work_blocked')
      ORDER BY e.timestamp DESC
      LIMIT 20
    `
    : `
      SELECT
        e.event_id,
        e.event_type,
        json_extract(e.data, '$.description') as description,
        json_extract(e.data, '$.status') as status,
        json_extract(e.data, '$.reason') as reason,
        json_extract(e.data, '$.context') as context,
        e.timestamp
      FROM events e
      WHERE e.event_type IN ('work_queued', 'work_blocked')
        AND e.event_id NOT IN (
          SELECT json_extract(data, '$.work_id')
          FROM events
          WHERE event_type = 'work_completed'
        )
      ORDER BY e.timestamp DESC
    `;

  const items = db.query(query).all() as any[];
  db.close();

  if (items.length === 0) {
    console.log(`No ${showAll ? '' : 'open '}work items for: ${project}`);
    return;
  }

  console.log(`\n📋 ${showAll ? 'All' : 'Open'} work items for: ${project}\n`);

  for (const item of items) {
    const icon = item.event_type === 'work_blocked' ? '🚫' :
                 item.completed ? '✅' : '📌';
    const id = item.event_id.substring(0, 8);

    console.log(`${icon} [${id}] ${item.description}`);
    if (item.reason) console.log(`   Blocked: ${item.reason}`);
    if (item.context) console.log(`   Context: ${item.context}`);
    console.log(`   Created: ${item.timestamp}`);
    console.log('');
  }
}

function cliHandoff(jsonData: string): void {
  const project = cliGetProject();
  const db = getDb(project);
  const eventId = randomUUIDv7();

  let data: Record<string, any>;
  try {
    data = JSON.parse(jsonData);
  } catch {
    console.error('Invalid JSON. Expected: {"goal":"...","done":[...],...}');
    process.exit(1);
  }

  // Get current session ID from latest slice if available
  const latestSession = db.query(`
    SELECT session_id FROM events
    WHERE event_type = 'slice_started'
    ORDER BY timestamp DESC LIMIT 1
  `).get() as { session_id: string } | null;

  const sessionId = latestSession?.session_id || 'cli';

  db.run(
    `INSERT INTO events (event_id, session_id, slice_id, event_type, entity_type, entity_id, data, tags)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      eventId,
      sessionId,
      null,
      'session_handoff',
      'handoff',
      eventId,
      JSON.stringify(data),
      JSON.stringify(['handoff'])
    ]
  );
  db.close();

  console.log(`Handoff stored: ${eventId.substring(0, 8)}`);
}

function runCli(): boolean {
  const args = process.argv.slice(2);
  if (args.length === 0) return false;

  const cmd = args[0];

  // Check if this looks like a CLI command vs hook stdin
  if (!['queue', 'block', 'complete', 'work', 'list', 'handoff'].includes(cmd)) {
    return false;
  }

  switch (cmd) {
    case 'queue': {
      const description = args[1];
      if (!description) {
        console.error('Usage: event-store.ts queue "description" [--context "..."]');
        process.exit(1);
      }
      const ctxIdx = args.indexOf('--context');
      const context = ctxIdx > 0 ? args[ctxIdx + 1] : undefined;
      cliQueueWork(description, context);
      break;
    }

    case 'block': {
      const description = args[1];
      const reasonIdx = args.indexOf('--reason');
      const reason = reasonIdx > 0 ? args[reasonIdx + 1] : 'unspecified';
      if (!description) {
        console.error('Usage: event-store.ts block "description" --reason "..."');
        process.exit(1);
      }
      cliBlockWork(description, reason);
      break;
    }

    case 'complete': {
      const workId = args[1];
      if (!workId) {
        console.error('Usage: event-store.ts complete <work_id_prefix>');
        process.exit(1);
      }
      cliCompleteWork(workId);
      break;
    }

    case 'work':
    case 'list': {
      const showAll = args.includes('--all') || args.includes('-a');
      cliListWork(showAll);
      break;
    }

    case 'handoff': {
      const jsonData = args[1];
      if (!jsonData) {
        console.error('Usage: event-store.ts handoff \'{"goal":"...","done":[...],...}\'');
        process.exit(1);
      }
      cliHandoff(jsonData);
      break;
    }
  }

  return true;
}

// =============================================================================
// Main - Hook Mode or CLI Mode
// =============================================================================

async function main() {
  // Check for CLI mode first
  if (runCli()) {
    process.exit(0);
  }

  // Hook mode - read from stdin
  try {
    const stdinData = await Bun.stdin.text();
    if (!stdinData.trim()) {
      process.exit(0);
    }

    const payload: HookPayload = JSON.parse(stdinData);

    // Detect hook type from payload shape
    if (payload.prompt !== undefined) {
      // UserPromptSubmit
      await handleUserPromptSubmit(payload);
    } else if (payload.tool_name !== undefined) {
      // PostToolUse
      await handlePostToolUse(payload);
    } else if (!payload.tool_name && !payload.prompt) {
      // SessionStop (minimal payload)
      await handleSessionStop(payload);
    }

  } catch (error) {
    // Never crash hooks
    console.error('[event-store] Error:', error);
  }

  process.exit(0);
}

main();
