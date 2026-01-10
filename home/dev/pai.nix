{
  pkgs,
  lib,
  ...
}: let
  # PAI Configuration
  paiConfig = {
    daName = "Timn";
    userName = "Beau";
    timeZone = "America/Chicago";
    # Optional: ElevenLabs for voice notifications
    # elevenLabsApiKey = "";
    # elevenLabsVoiceId = "";
  };

  # Environment variables for settings.json
  paiEnv = {
    DA = paiConfig.daName;
    TIME_ZONE = paiConfig.timeZone;
    PAI_DIR = "$HOME/.claude";
    PAI_SOURCE_APP = paiConfig.daName;
  };

  # PAI Hooks configuration
  # Uses $PAI_DIR which is expanded at runtime by Claude Code
  paiHooks = {
    SessionStart = [
      {
        matcher = "*";
        hooks = [
          {
            type = "command";
            command = "bun run $PAI_DIR/hooks/initialize-session.ts";
          }
          {
            type = "command";
            command = "bun run $PAI_DIR/hooks/load-core-context.ts";
          }
        ];
      }
    ];
    PreToolUse = [
      {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            command = "bun run $PAI_DIR/hooks/security-validator.ts";
          }
        ];
      }
    ];
    UserPromptSubmit = [
      {
        matcher = "*";
        hooks = [
          {
            type = "command";
            command = "bun run $PAI_DIR/hooks/update-tab-titles.ts";
          }
        ];
      }
    ];
  };

  # Convert to JSON for merging into ~/.claude/settings.json
  paiSettingsJson = builtins.toJSON {
    env = paiEnv;
    hooks = paiHooks;
  };
in {
  home = {
    # Shell environment variables (for terminal access)
    sessionVariables = {
      DA = paiConfig.daName;
      TIME_ZONE = paiConfig.timeZone;
      PAI_SOURCE_APP = paiConfig.daName;
    };

    # Declarative file management for hooks and skills
    file = {
      # Hooks - TypeScript files for Claude Code hooks
      ".claude/hooks" = {
        source = ./pai-hooks;
        recursive = true;
      };

      # CORE skill files
      ".claude/skills/CORE/SKILL.md".source = ./pai-files/SKILL.md;
      ".claude/skills/CORE/Contacts.md".source = ./pai-files/Contacts.md;
      ".claude/skills/CORE/CoreStack.md".source = ./pai-files/CoreStack.md;
      ".claude/skills/CORE/SYSTEM/MEMORYSYSTEM.md".source = ./pai-files/SYSTEM/MEMORYSYSTEM.md;

      # Browser skill source (stored in nix config for reference during activation)
      # Note: We copy these files (not symlink) so bun can create node_modules
      ".local/share/pai-skills/Browser" = {
        source = ./pai-skills/Browser;
        recursive = true;
      };

      # Datastar skill - hypermedia UI framework philosophy + reference
      ".claude/skills/Datastar" = {
        source = ./pai-skills/Datastar;
        recursive = true;
      };

      # EventSource skill - SQLite event sourcing for progress tracking
      ".claude/skills/EventSource" = {
        source = ./pai-skills/EventSource;
        recursive = true;
      };
    };

    # Activation script to:
    # 1. Create PAI directory structure (for mutable directories)
    # 2. Merge PAI env vars into settings.json
    activation.configurePai = lib.hm.dag.entryAfter ["writeBoundary"] ''
      PAI_DIR="$HOME/.claude"
      SETTINGS_FILE="$PAI_DIR/settings.json"

      # Create mutable directories (not managed by home.file)
      # These directories contain runtime data that should persist
      mkdir -p "$PAI_DIR/skills/CORE/workflows"
      mkdir -p "$PAI_DIR/skills/CORE/tools"
      mkdir -p "$PAI_DIR/tools"
      mkdir -p "$PAI_DIR/voice"

      # Create MEMORY system structure (history/learning/state)
      # This is runtime data, not declarative config
      mkdir -p "$PAI_DIR/MEMORY/research"
      mkdir -p "$PAI_DIR/MEMORY/sessions"
      mkdir -p "$PAI_DIR/MEMORY/learnings"
      mkdir -p "$PAI_DIR/MEMORY/decisions"
      mkdir -p "$PAI_DIR/MEMORY/execution"
      mkdir -p "$PAI_DIR/MEMORY/security"
      mkdir -p "$PAI_DIR/MEMORY/recovery"
      mkdir -p "$PAI_DIR/MEMORY/raw-outputs"
      mkdir -p "$PAI_DIR/MEMORY/backups"
      mkdir -p "$PAI_DIR/MEMORY/archive"
      mkdir -p "$PAI_DIR/MEMORY/analysis"
      mkdir -p "$PAI_DIR/MEMORY/ideas"
      mkdir -p "$PAI_DIR/MEMORY/releases"
      mkdir -p "$PAI_DIR/MEMORY/skills"
      mkdir -p "$PAI_DIR/MEMORY/Learning/OBSERVE"
      mkdir -p "$PAI_DIR/MEMORY/Learning/THINK"
      mkdir -p "$PAI_DIR/MEMORY/Learning/PLAN"
      mkdir -p "$PAI_DIR/MEMORY/Learning/BUILD"
      mkdir -p "$PAI_DIR/MEMORY/Learning/EXECUTE"
      mkdir -p "$PAI_DIR/MEMORY/Learning/VERIFY"
      mkdir -p "$PAI_DIR/MEMORY/Learning/ALGORITHM"
      mkdir -p "$PAI_DIR/MEMORY/Learning/sessions"
      mkdir -p "$PAI_DIR/MEMORY/State"
      mkdir -p "$PAI_DIR/MEMORY/Signals"
      mkdir -p "$PAI_DIR/MEMORY/Work"

      # Create history directories (used by hooks)
      mkdir -p "$PAI_DIR/history/sessions"
      mkdir -p "$PAI_DIR/history/learnings"
      mkdir -p "$PAI_DIR/history/research"
      mkdir -p "$PAI_DIR/history/decisions"

      # Install Browser skill with dependencies
      BROWSER_SRC="$HOME/.local/share/pai-skills/Browser"
      BROWSER_DEST="$PAI_DIR/skills/Browser"
      if [ -d "$BROWSER_SRC" ]; then
        # Create destination if it doesn't exist
        mkdir -p "$BROWSER_DEST"

        # Copy source files (rsync to handle updates properly)
        ${pkgs.rsync}/bin/rsync -a --delete --exclude='node_modules' "$BROWSER_SRC/" "$BROWSER_DEST/"

        # Install dependencies if needed (check if node_modules exists and package.json unchanged)
        if [ ! -d "$BROWSER_DEST/node_modules" ] || \
           [ "$BROWSER_SRC/package.json" -nt "$BROWSER_DEST/node_modules/.package-lock.json" ] 2>/dev/null; then
          echo "Installing Browser skill dependencies..."
          (cd "$BROWSER_DEST" && ${pkgs.bun}/bin/bun install --frozen-lockfile 2>/dev/null || ${pkgs.bun}/bin/bun install)
        fi
      fi

      # Ensure settings.json exists
      if [ ! -f "$SETTINGS_FILE" ]; then
        echo '{}' > "$SETTINGS_FILE"
      fi

      # Merge PAI settings (env + hooks) into settings.json, preserving other settings
      ${pkgs.jq}/bin/jq --argjson paiSettings '${paiSettingsJson}' \
        '. * $paiSettings' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" \
        && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

      chmod 600 "$SETTINGS_FILE"
    '';
  };
}
