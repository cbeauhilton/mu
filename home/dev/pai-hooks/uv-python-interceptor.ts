#!/usr/bin/env bun
// $PAI_DIR/hooks/uv-python-interceptor.ts
// PreToolUse hook: Intercepts bare python/python3 commands and suggests uv run
//
// Exit codes:
//   0 = allow (not a python command, or already using uv)
//   2 = block (bare python detected, use uv run instead)

interface PreToolUsePayload {
  session_id: string;
  tool_name: string;
  tool_input: Record<string, unknown>;
}

// Patterns that indicate bare python usage
const PYTHON_PATTERNS = [
  /^python3?\s+/,           // python script.py, python3 script.py
  /^python3?\s*$/,          // just "python" or "python3"
  /&&\s*python3?\s+/,       // cmd && python script.py
  /;\s*python3?\s+/,        // cmd; python script.py
  /\|\s*python3?\s+/,       // cmd | python script.py
];

// Patterns that are OK (already using uv or other valid patterns)
const ALLOWED_PATTERNS = [
  /uv\s+run/,               // uv run python ...
  /uv\s+pip/,               // uv pip install
  /uv\s+venv/,              // uv venv
  /uv\s+sync/,              // uv sync
  /uv\s+add/,               // uv add
  /uv\s+remove/,            // uv remove
  /which\s+python/,         // which python
  /--version/,              // python --version (harmless)
  /type\s+python/,          // type python
];

function isPythonCommand(cmd: string): boolean {
  // First check if it's an allowed pattern
  for (const pattern of ALLOWED_PATTERNS) {
    if (pattern.test(cmd)) {
      return false;
    }
  }

  // Then check if it matches a bare python pattern
  for (const pattern of PYTHON_PATTERNS) {
    if (pattern.test(cmd)) {
      return true;
    }
  }

  return false;
}

function transformToUv(cmd: string): string {
  // Simple transformation: replace "python" or "python3" with "uv run python"
  return cmd
    .replace(/^python3\s+/, "uv run python3 ")
    .replace(/^python\s+/, "uv run python ")
    .replace(/&&\s*python3\s+/g, "&& uv run python3 ")
    .replace(/&&\s*python\s+/g, "&& uv run python ")
    .replace(/;\s*python3\s+/g, "; uv run python3 ")
    .replace(/;\s*python\s+/g, "; uv run python ");
}

async function main() {
  try {
    const stdinData = await Bun.stdin.text();
    if (!stdinData.trim()) {
      process.exit(0);
    }

    const payload: PreToolUsePayload = JSON.parse(stdinData);

    // Only intercept Bash commands
    if (payload.tool_name !== "Bash") {
      process.exit(0);
    }

    const command = payload.tool_input?.command;
    if (typeof command !== "string") {
      process.exit(0);
    }

    if (!isPythonCommand(command)) {
      process.exit(0);
    }

    const suggested = transformToUv(command);

    console.error(`BLOCKED: Use uv to run Python commands.

Detected bare python command:
  ${command}

Use uv run instead:
  ${suggested}

Why: uv manages Python versions and dependencies automatically.
     It ensures reproducible environments without global installs.

Quick reference:
  uv run python script.py    # Run with managed Python
  uv run pytest              # Run tools from pyproject.toml
  uv pip install package     # Install to current venv
  uv add package             # Add to pyproject.toml`);

    process.exit(2);
  } catch (error) {
    // Never crash - log error and allow the command
    console.error("[uv-python-interceptor] Error:", error);
    process.exit(0);
  }
}

main();
