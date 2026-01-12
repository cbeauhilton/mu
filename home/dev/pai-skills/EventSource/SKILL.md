---
name: EventSource
description: SQLite event sourcing for progress tracking. USE WHEN starting complex tasks, multi-step work, or when asked to track progress. Current state = f(events).
---

# EventSource - SQLite Progress Tracking

**Current state is a function of events.** Never store mutable state directly - store events and derive state.

---

## Philosophy

1. **Events are immutable facts** — Something happened. Record it. Never update or delete.
2. **State is derived** — Current state = fold(events). Always reconstructable.
3. **Audit trail built-in** — Every change is recorded with timestamp.
4. **Simple tooling** — SQLite + shell. No servers, no complexity.
5. **Project-scoped** — Every event belongs to a project for easy filtering.

---

## Quick Start

### Initialize Event Store

```bash
sqlite3 ~/.claude/events/progress.db <<'EOF'
CREATE TABLE IF NOT EXISTS events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT DEFAULT (datetime('now')),
    project TEXT NOT NULL,
    session_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT,
    data JSON,
    metadata JSON
);
CREATE INDEX IF NOT EXISTS idx_project ON events(project);
CREATE INDEX IF NOT EXISTS idx_session ON events(session_id);
CREATE INDEX IF NOT EXISTS idx_type ON events(event_type);
CREATE INDEX IF NOT EXISTS idx_entity ON events(entity_type, entity_id);
EOF
```

### Detect Project

```bash
# Auto-detect from git root, fallback to current directory name
PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
SESSION_ID="${PROJECT}-$(date +%Y%m%d-%H%M%S)"
```

### Log Events

```bash
# Detect project and session
PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
SESSION_ID="${PROJECT}-$(date +%Y%m%d-%H%M%S)"

# Session started
sqlite3 ~/.claude/events/progress.db "INSERT INTO events
(project, session_id, event_type, entity_type, entity_id, data) VALUES
('$PROJECT', '$SESSION_ID', 'session_started', 'session', '$SESSION_ID',
json_object('goal', 'Build feature X', 'context', 'User requested...'));"

# Task started
sqlite3 ~/.claude/events/progress.db "INSERT INTO events
(project, session_id, event_type, entity_type, entity_id, data) VALUES
('$PROJECT', '$SESSION_ID', 'task_started', 'task', 'research',
json_object('task', 'Research existing code'));"

# Task completed
sqlite3 ~/.claude/events/progress.db "INSERT INTO events
(project, session_id, event_type, entity_type, entity_id, data) VALUES
('$PROJECT', '$SESSION_ID', 'task_completed', 'task', 'research',
json_object('result', 'Found 3 relevant files'));"

# File created/modified
sqlite3 ~/.claude/events/progress.db "INSERT INTO events
(project, session_id, event_type, entity_type, entity_id, data) VALUES
('$PROJECT', '$SESSION_ID', 'file_created', 'file', 'src/feature.go',
json_object('lines', 150, 'purpose', 'Main feature implementation'));"
```

---

## Event Types

| Event Type | Entity Type | Purpose |
|------------|-------------|---------|
| `session_started` | session | Begin tracking a task |
| `session_completed` | session | Task finished |
| `task_started` | task | Sub-task begun |
| `task_completed` | task | Sub-task finished |
| `task_blocked` | task | Hit a blocker |
| `resource_fetched` | doc/url | Fetched external resource |
| `file_created` | file | Created new file |
| `file_modified` | file | Modified existing file |
| `file_deleted` | file | Deleted file |
| `error_encountered` | task/file | Hit an error |
| `decision_made` | decision | Recorded a design decision |
| `question_asked` | question | Asked user a question |
| `answer_received` | question | Got user response |

---

## Query Patterns

### By Project

```sql
-- All events for a specific project
SELECT * FROM events
WHERE project = 'nats-dcb'
ORDER BY timestamp DESC;

-- Recent activity per project
SELECT
    project,
    COUNT(*) as events,
    MAX(timestamp) as last_activity
FROM events
GROUP BY project
ORDER BY last_activity DESC;
```

### Current Session Events
```sql
SELECT * FROM events
WHERE session_id = 'your-session-id'
ORDER BY timestamp;
```

### Task Status (Derived State)
```sql
-- Tasks that started but didn't complete (for a project)
SELECT entity_id as task,
       MAX(CASE WHEN event_type = 'task_started' THEN timestamp END) as started,
       MAX(CASE WHEN event_type = 'task_completed' THEN timestamp END) as completed
FROM events
WHERE project = 'my-project' AND entity_type = 'task'
GROUP BY entity_id
HAVING completed IS NULL;
```

### Files Modified in Project
```sql
SELECT DISTINCT entity_id as file,
       json_extract(data, '$.purpose') as purpose,
       MAX(timestamp) as last_modified
FROM events
WHERE project = 'my-project'
  AND event_type IN ('file_created', 'file_modified')
GROUP BY entity_id
ORDER BY last_modified DESC;
```

### Project Summary
```sql
SELECT
    event_type,
    COUNT(*) as count
FROM events
WHERE project = 'my-project'
GROUP BY event_type
ORDER BY count DESC;
```

### Recent Sessions (All Projects)
```sql
SELECT
    project,
    session_id,
    MIN(timestamp) as started,
    MAX(timestamp) as last_activity,
    json_extract(data, '$.goal') as goal
FROM events
WHERE event_type = 'session_started'
GROUP BY session_id
ORDER BY started DESC
LIMIT 10;
```

### Cross-Project Activity (This Week)
```sql
SELECT
    project,
    COUNT(*) as events,
    COUNT(DISTINCT session_id) as sessions
FROM events
WHERE timestamp > datetime('now', '-7 days')
GROUP BY project
ORDER BY events DESC;
```

---

## Workflow

### At Task Start

1. Detect project: `PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")`
2. Generate session ID: `SESSION_ID="${PROJECT}-$(date +%Y%m%d-%H%M%S)"`
3. Create event store if needed
4. Log `session_started` with goal and context

### During Task

Log events as you work:
- Starting/completing sub-tasks
- Fetching resources
- Creating/modifying files
- Encountering errors
- Making decisions

### At Task End

1. Log `session_completed`
2. Query for summary if needed

---

## Helper Script

Create `~/.local/bin/evlog`:

```bash
#!/bin/bash
# Usage: evlog <event_type> <entity_type> <entity_id> '<json_data>'
# Project auto-detected from git root or cwd
# Session ID from EVLOG_SESSION env var or auto-generated

DB="${EVLOG_DB:-$HOME/.claude/events/progress.db}"
PROJECT="${EVLOG_PROJECT:-$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")}"
SESSION="${EVLOG_SESSION:-${PROJECT}-$(date +%Y%m%d-%H%M%S)}"

EVENT_TYPE="$1"
ENTITY_TYPE="$2"
ENTITY_ID="$3"
DATA="${4:-'{}'}"

sqlite3 "$DB" "INSERT INTO events (project, session_id, event_type, entity_type, entity_id, data)
VALUES ('$PROJECT', '$SESSION', '$EVENT_TYPE', '$ENTITY_TYPE', '$ENTITY_ID', json('$DATA'));"

echo "[$PROJECT] $EVENT_TYPE: $ENTITY_TYPE/$ENTITY_ID"
```

Then use:
```bash
# Auto-detects project from git
evlog task_completed task research '{"findings": "..."}'

# Or set session for multiple events
export EVLOG_SESSION="my-feature-20260110"
evlog task_started task implementation '{}'
evlog file_created file "src/new.go" '{"lines": 50}'
evlog task_completed task implementation '{}'
```

---

## Integration with TodoWrite

EventSource complements TodoWrite:

- **TodoWrite** — User-visible task list, real-time status
- **EventSource** — Persistent audit log, reconstructable history

Use both:
1. TodoWrite for current task visibility
2. EventSource for permanent record per project

```bash
# When completing a todo, also log the event
evlog task_completed task "fix-auth-bug" '{"resolution": "Updated token refresh"}'
# Then update TodoWrite
```

---

## Example Session

```bash
# Detect project and start session
PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
SESSION="${PROJECT}-refactor-auth-$(date +%Y%m%d)"
export EVLOG_SESSION="$SESSION"

# Start
evlog session_started session "$SESSION" \
  '{"goal": "Refactor auth module", "files": ["auth.go", "middleware.go"]}'

# Research phase
evlog task_started task research '{"task": "Read existing auth code"}'
# ... do research ...
evlog task_completed task research '{"findings": "Current impl uses JWT, need refresh tokens"}'

# Implementation
evlog file_modified file "auth.go" '{"changes": "Added refresh token generation"}'

# Complete
evlog session_completed session "$SESSION" '{"outcome": "Auth refactored with refresh tokens"}'
```

---

## Migration (Existing DBs)

If you have an existing database without the project column:

```sql
-- Add column
ALTER TABLE events ADD COLUMN project TEXT;

-- Create index
CREATE INDEX IF NOT EXISTS idx_project ON events(project);

-- Backfill (set a default or derive from session_id)
UPDATE events SET project = 'legacy' WHERE project IS NULL;
-- Or parse from session_id if it contains project name:
-- UPDATE events SET project = substr(session_id, 1, instr(session_id, '-')-1) WHERE project IS NULL;
```

---

## Why SQLite?

1. **Zero dependencies** — Already on every system
2. **File-based** — Easy to backup, inspect, share
3. **SQL queries** — Flexible state derivation
4. **JSON support** — Structured event data
5. **ACID** — Reliable writes

---

## Anti-Patterns

**DON'T:**
- Update events (they're immutable facts)
- Delete events (use compensating events instead)
- Store derived state (always reconstruct from events)
- Use complex event schemas (keep it simple)
- Forget to set project (use auto-detection)

**DO:**
- Log generously (storage is cheap)
- Include context in events
- Use consistent event type naming
- Query to derive current state
- Filter by project for focused views
