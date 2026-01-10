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
  # Shell environment variables (for terminal access)
  home.sessionVariables = {
    DA = paiConfig.daName;
    TIME_ZONE = paiConfig.timeZone;
    PAI_SOURCE_APP = paiConfig.daName;
  };

  # Activation script to:
  # 1. Create PAI directory structure
  # 2. Merge PAI env vars into settings.json
  home.activation.configurePai = lib.hm.dag.entryAfter ["writeBoundary"] ''
    PAI_DIR="$HOME/.claude"
    SETTINGS_FILE="$PAI_DIR/settings.json"

    # Create PAI directory structure
    mkdir -p "$PAI_DIR/skills/CORE/workflows"
    mkdir -p "$PAI_DIR/skills/CORE/tools"
    mkdir -p "$PAI_DIR/skills/CORE/SYSTEM"
    mkdir -p "$PAI_DIR/hooks/lib"
    mkdir -p "$PAI_DIR/tools"
    mkdir -p "$PAI_DIR/voice"

    # Create MEMORY system structure (history/learning/state)
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
}
