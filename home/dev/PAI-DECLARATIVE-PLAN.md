# PAI Declarative Migration Plan

**Goal:** Move all PAI configuration into `src/nixos` so that `~/.claude` can be deleted and rebuilt entirely from source control.

**Philosophy:** "Delete your darlings" - if it's not in git, it doesn't exist after a rebuild.

---

## Current State

### Already Declarative (in src/nixos)
- `home/dev/pai.nix` - env vars, hooks registration, directory structure

### Still Imperative (in ~/.claude, not source controlled)
| File | Type | Should Be Declarative? |
|------|------|------------------------|
| `skills/CORE/SKILL.md` | Config | Yes - identity definition |
| `skills/CORE/Contacts.md` | Config | Yes - template, user edits |
| `skills/CORE/CoreStack.md` | Config | Yes - stack preferences |
| `skills/CORE/SYSTEM/MEMORYSYSTEM.md` | Docs | Yes - system documentation |
| `hooks/*.ts` | Code | Yes - hook implementations |
| `hooks/lib/observability.ts` | Code | Yes - shared utilities |
| `.env` | Config | Maybe - could use sops |
| `MEMORY/*` | Data | No - runtime data, gitignored |
| `settings.json` | Config | Partial - we merge into it |

---

## Migration Plan

### Phase 1: Move Skill Files to home.file

**Approach:** Use `home.file` to declaratively place skill markdown files.

```nix
# home/dev/pai.nix additions
home.file = {
  ".claude/skills/CORE/SKILL.md".text = ''
    ---
    name: CORE
    description: Personal AI Infrastructure core...
    ---
    # CORE - Personal AI Infrastructure

    ## Identity
    **Assistant:** Timn
    **User:** Beau
    ...
  '';

  ".claude/skills/CORE/CoreStack.md".text = ''
    # Core Stack Preferences
    ...
  '';

  ".claude/skills/CORE/SYSTEM/MEMORYSYSTEM.md".source =
    ../pai-files/MEMORYSYSTEM.md;  # or inline
};
```

**Decision needed:** Inline text vs separate files in `home/dev/pai-files/`?
- Inline: Everything in one place, easy to see config
- Separate files: Cleaner nix, markdown syntax highlighting works

**Recommendation:** Create `home/dev/pai-files/` directory for markdown files, reference via `.source`.

### Phase 2: Package Hooks as a Derivation

**Approach:** Create a nix derivation that builds the hook scripts.

```nix
# home/dev/pai-hooks.nix
{ pkgs, ... }:
let
  paiHooks = pkgs.stdenv.mkDerivation {
    name = "pai-hooks";
    src = ./pai-hooks;  # directory with .ts files

    installPhase = ''
      mkdir -p $out/hooks/lib
      cp *.ts $out/hooks/
      cp lib/*.ts $out/hooks/lib/
    '';
  };
in {
  home.file.".claude/hooks".source = "${paiHooks}/hooks";
}
```

**Alternative:** Just use `home.file` with `.source` pointing to a local directory:
```nix
home.file.".claude/hooks".source = ./pai-hooks;
home.file.".claude/hooks".recursive = true;
```

**Recommendation:** Use the simpler `home.file` approach unless we need build-time processing.

### Phase 3: Handle Secrets (.env)

**Current:** `.env` file with DA, TIME_ZONE, optional ElevenLabs keys.

**Options:**
1. **sops-nix:** Encrypt secrets, decrypt at activation
2. **home.sessionVariables:** Already doing this for non-secrets
3. **settings.json env:** Already merging env vars here

**Recommendation:**
- Non-secrets (DA, TIME_ZONE): Keep in `home.sessionVariables` and settings.json merge
- Secrets (ELEVENLABS_API_KEY): Add to sops if/when needed

### Phase 4: Handle Runtime Data (MEMORY/)

**Philosophy:** MEMORY/ contains runtime data, not config. It should:
- Be created by activation script (already done)
- NOT be in source control
- Be ephemeral (can be lost on "delete your darlings")

**Recommendation:** Keep current approach - directory structure is declarative, contents are ephemeral.

**Optional enhancement:** Add a "warm start" mechanism that seeds MEMORY/ with baseline learnings from a checked-in template.

### Phase 5: Settings.json Strategy

**Current:** We merge PAI config into existing settings.json

**Problem:** settings.json also contains:
- Permissions (user-specific, accumulates over time)
- Plugin config
- Other Claude Code settings

**Options:**
1. **Keep current merge approach:** Works, but settings.json is partially imperative
2. **Fully declarative settings.json:** Risk losing user permissions
3. **Separate PAI settings:** Use a different mechanism if Claude Code supports it

**Recommendation:** Keep current merge approach. The permissions list is intentionally mutable (grows as you approve commands). The PAI parts (env, hooks) are declaratively merged.

---

## Proposed File Structure

```
src/nixos/home/dev/
├── pai.nix                    # Main module, env vars, activation
├── pai-hooks/                 # Hook TypeScript files
│   ├── security-validator.ts
│   ├── initialize-session.ts
│   ├── load-core-context.ts
│   ├── update-tab-titles.ts
│   └── lib/
│       └── observability.ts
└── pai-files/                 # Skill markdown files
    ├── SKILL.md
    ├── Contacts.md
    ├── CoreStack.md
    └── SYSTEM/
        └── MEMORYSYSTEM.md
```

---

## Implementation Steps

1. [x] Create `home/dev/pai-hooks/` directory ✅ 2026-01-09
2. [x] Copy hook .ts files from ~/.claude/hooks/ to pai-hooks/ ✅ 2026-01-09
3. [x] Create `home/dev/pai-files/` directory ✅ 2026-01-09
4. [x] Copy skill .md files from ~/.claude/skills/CORE/ to pai-files/ ✅ 2026-01-09
5. [x] Update pai.nix to use home.file with .source ✅ 2026-01-09
6. [x] Test with `nh os switch` ✅ 2026-01-09
7. [x] Verify hooks still work after restart ✅ 2026-01-09
8. [ ] Delete ~/.claude and rebuild to test full declarative flow
9. [ ] Commit all changes

**Note:** Browser skill is now declarative too! Source stored in `pai-skills/Browser/`,
copied to `~/.claude/skills/Browser/` on activation with `bun install` for dependencies.

---

## Rollback Plan

If something breaks:
```bash
# Restore from backup (created by PAI installer)
cp -r ~/.claude-BACKUP/* ~/.claude/
```

---

## Future Enhancements

- **PAI as a flake module:** Package PAI as a reusable home-manager module
- **Upstream to PAI repo:** Contribute NixOS module back to danielmiessler/PAI
- **ZFS integration:** Snapshot ~/.claude before major changes
- **Warm start templates:** Seed MEMORY/ with baseline learnings

---

## Session Continuation Prompt

To continue this work in a new session, paste:

```
Continue the PAI declarative migration from home/dev/PAI-DECLARATIVE-PLAN.md.
The goal is to move all ~/.claude configuration into src/nixos so the home
directory can be deleted and rebuilt. Start with Phase 1 (skill files) and
Phase 2 (hooks), then verify with a test rebuild.
```
