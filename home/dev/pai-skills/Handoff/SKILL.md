---
name: Handoff
description: Session handoff for context continuity. USE WHEN ending a session, switching context, or user says /handoff. Generates structured summary and persists to project memory.
---

# Handoff - Session Context Transfer

**Generates a structured handoff and writes it to the project's auto-memory so the next session picks it up automatically.**

---

## When to Use

- User invokes `/handoff`
- Before ending a long or complex session
- When switching to a different project mid-conversation

---

## Procedure

### 1. Review the Session

Look back through the conversation and identify:
- What the user asked for (the goal)
- What was actually accomplished
- Key decisions made and their rationale
- Anything still open, blocked, or partially done
- Gotchas, temporary hacks, or important context that would be lost

### 2. Generate the Handoff

Output a structured summary using this format:

```
## Session Handoff

**Goal**: [One sentence - what we set out to do]

**Done**:
- [Concrete accomplishment with file/location references]
- [Another accomplishment]

**Decisions**:
- [Choice made] — [why]

**Open**:
- [What's still pending or incomplete]

**Next**:
1. [First thing the next session should do]
2. [Second priority]

**Context**:
- [Gotchas, temp hacks, non-obvious things to know]
```

**Guidelines:**
- Be specific — reference files, functions, error messages
- "Done" means actually done, not "started working on"
- "Next" should be actionable first steps, not a roadmap
- "Context" is for things that would cause confusion without explanation
- Skip any section that's empty — don't pad

### 3. Persist to Project Memory

Write the handoff to the project's auto-memory file using the Write tool:

```
~/.claude/projects/{project-path}/memory/HANDOFF.md
```

The project path mirrors the working directory with `-` replacing `/` (e.g. `-home-beau-src-nixos`). This file auto-loads into the system prompt on the next session.

If a previous handoff exists, **replace it** — only the latest handoff matters.

### 4. Confirm

Tell the user the handoff is stored in project memory. The next session (or `claude --continue`) will see it automatically.

---

## Anti-Patterns

- **Don't pad** — Empty sections should be omitted, not filled with "N/A"
- **Don't be vague** — "worked on stuff" is useless; "added volume.nix keybinds for wpctl" is useful
- **Don't include the whole conversation** — This is a summary, not a transcript
- **Don't speculate** — Only include things that actually happened or were actually decided
