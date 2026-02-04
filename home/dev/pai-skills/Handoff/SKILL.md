---
name: Handoff
description: Session handoff for context continuity. USE WHEN ending a session, switching context, or user says /handoff. Generates structured summary and persists to event store.
---

# Handoff - Session Context Transfer

**Generates a structured handoff and persists it to the event store for the next session.**

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

### 3. Persist to Event Store

After generating and showing the handoff to the user, store it:

```bash
bun ~/.claude/hooks/event-store.ts handoff '<json>'
```

Where `<json>` is a JSON object with the handoff fields:

```json
{
  "goal": "string",
  "done": ["string", "..."],
  "decisions": ["string", "..."],
  "open": ["string", "..."],
  "next": ["string", "..."],
  "context": ["string", "..."]
}
```

The event store persists this as a `session_handoff` event. The next session's `load-event-context.ts` hook will automatically surface it in the resume context.

### 4. Confirm

Tell the user the handoff is stored. Session is safe to end.

---

## Anti-Patterns

- **Don't pad** — Empty sections should be omitted, not filled with "N/A"
- **Don't be vague** — "worked on stuff" is useless; "added volume.nix keybinds for wpctl" is useful
- **Don't include the whole conversation** — This is a summary, not a transcript
- **Don't speculate** — Only include things that actually happened or were actually decided
