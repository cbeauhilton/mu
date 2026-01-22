{
  pkgs,
  lib,
  config,
  ...
}: let
  # PAI Configuration
  paiConfig = {
    daName = "Timn";
    userName = "Beau";
    timeZone = "America/Chicago";
  };

  paiDir = "${config.home.homeDirectory}/.claude";
in {
  programs = {
    claude-code = {
      enable = true;
      package = pkgs.claude-code;

      # Hook files directory - symlinked to ~/.claude/hooks/
      hooksDir = ./pai-hooks;

      # MCP Server configuration - written to ~/.claude.json
      mcpServers = {
        # NixOS MCP - for querying NixOS options, packages, etc.
        nixos = {
          command = "nix";
          args = ["run" "github:utensils/mcp-nixos" "--"];
        };

        # NATS MCP - for interacting with NATS messaging
        nats = {
          command = "${pkgs.mcp-nats}/bin/mcp-nats";
          args = [];
        };

        # Karakeep MCP - bookmark manager integration
        # API key comes from shell environment (KARAKEEP_API_KEY)
        karakeep = {
          command = "npx";
          args = ["@karakeep/mcp"];
          env = {
            KARAKEEP_API_ADDR = "https://karakeep.lab.beauhilton.com";
            # KARAKEEP_API_KEY inherited from shell environment via sops
          };
        };

        # Claude in Chrome MCP - browser automation
        claude-in-chrome = {
          command = "npx";
          args = ["-y" "@anthropic/claude-in-chrome-mcp@latest"];
        };
      };

      # Settings - written to ~/.claude/settings.json
      settings = {
        # Environment variables available to Claude Code
        env = {
          DA = paiConfig.daName;
          TIME_ZONE = paiConfig.timeZone;
          PAI_DIR = paiDir;
          PAI_SOURCE_APP = paiConfig.daName;
        };

        # Hook configuration - references hook files in ~/.claude/hooks/
        hooks = {
          SessionStart = [
            {
              matcher = "*";
              hooks = [
                {
                  type = "command";
                  command = "bun run ${paiDir}/hooks/initialize-session.ts";
                }
                {
                  type = "command";
                  command = "bun run ${paiDir}/hooks/load-core-context.ts";
                }
                {
                  type = "command";
                  command = "bun run ${paiDir}/hooks/load-event-context.ts";
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
                  command = "bun run ${paiDir}/hooks/security-validator.ts";
                }
                {
                  type = "command";
                  command = "bun run ${paiDir}/hooks/uv-python-interceptor.ts";
                }
              ];
            }
            {
              matcher = "WebFetch";
              hooks = [
                {
                  type = "command";
                  command = "bun run ${paiDir}/hooks/local-repo-resolver.ts";
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
                  command = "bun run ${paiDir}/hooks/update-tab-titles.ts";
                }
                {
                  type = "command";
                  command = "bun run ${paiDir}/hooks/event-store.ts";
                }
              ];
            }
          ];
          PostToolUse = [
            {
              matcher = "*";
              hooks = [
                {
                  type = "command";
                  command = "bun run ${paiDir}/hooks/event-store.ts";
                }
              ];
            }
          ];
          SessionEnd = [
            {
              matcher = "*";
              hooks = [
                {
                  type = "command";
                  command = "bun run ${paiDir}/hooks/event-store.ts";
                }
              ];
            }
          ];
        };
      };
    };

    # Shell aliases
    zsh.shellAliases.cc = "claude-code";
    bash.shellAliases.cc = "claude-code";

    # Karakeep API key from sops (inherited by MCP server)
    zsh.initContent = ''
      if [ -f "${config.sops.secrets.karakeep_api_key.path}" ]; then
        export KARAKEEP_API_KEY="$(cat ${config.sops.secrets.karakeep_api_key.path})"
      fi
    '';
    bash.initExtra = ''
      if [ -f "${config.sops.secrets.karakeep_api_key.path}" ]; then
        export KARAKEEP_API_KEY="$(cat ${config.sops.secrets.karakeep_api_key.path})"
      fi
    '';
  };

  home = {
    sessionPath = ["$HOME/.local/bin"];

    packages = with pkgs; [
      claude-code-bun
      git
      curl
      wget
      jq
      pnpm
      uv
      gcc
      gnumake
      ripgrep
      fd
      tree
      bat
      eza
      docker
      docker-compose
      rsync # For Browser skill installation
    ];

    # Shell environment variables (for terminal access)
    sessionVariables = {
      DA = paiConfig.daName;
      TIME_ZONE = paiConfig.timeZone;
      PAI_SOURCE_APP = paiConfig.daName;
    };

    # Declarative file management for skills (not hooks - handled by hooksDir)
    file = {
      # Force overwrite settings.json (managed by programs.claude-code.settings)
      ".claude/settings.json".force = true;

      # CORE skill files
      ".claude/skills/CORE/SKILL.md".source = ./pai-files/SKILL.md;
      ".claude/skills/CORE/Contacts.md".source = ./pai-files/Contacts.md;
      ".claude/skills/CORE/CoreStack.md".source = ./pai-files/CoreStack.md;
      ".claude/skills/CORE/SYSTEM/MEMORYSYSTEM.md".source = ./pai-files/SYSTEM/MEMORYSYSTEM.md;

      # Browser skill source (stored separately, copied at activation for bun install)
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

      # ChromeLauncher skill - launch Chrome for Claude in Chrome extension
      ".claude/skills/ChromeLauncher/SKILL.md".source = ./pai-skills/ChromeLauncher/SKILL.md;
      ".claude/skills/ChromeLauncher/launch-chrome.sh" = {
        source = ./pai-skills/ChromeLauncher/launch-chrome.sh;
        executable = true;
      };
    };

    # Activation scripts for mutable directories and runtime setup
    activation = {
      # Stable symlinks to claude binaries (for consistent paths)
      claudeStableLink = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p $HOME/.local/bin
        rm -f $HOME/.local/bin/claude $HOME/.local/bin/claude-bun
        ln -s ${pkgs.claude-code}/bin/claude $HOME/.local/bin/claude
        ln -s ${pkgs.claude-code-bun}/bin/claude-bun $HOME/.local/bin/claude-bun
      '';

      # Create mutable PAI directories (runtime data, not declarative config)
      createPaiDirectories = lib.hm.dag.entryAfter ["writeBoundary"] ''
        PAI_DIR="$HOME/.claude"

        # Ensure base directory exists with proper permissions
        mkdir -p "$PAI_DIR"
        chmod 700 "$PAI_DIR"

        # Create mutable skill directories
        mkdir -p "$PAI_DIR/skills/CORE/workflows"
        mkdir -p "$PAI_DIR/skills/CORE/tools"
        mkdir -p "$PAI_DIR/tools"
        mkdir -p "$PAI_DIR/voice"

        # Create MEMORY system structure (runtime data)
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

        # Create repos cache directory (for local-repo-resolver hook)
        mkdir -p "$HOME/src/.repos"

        # Create events directory (for event-store hook)
        mkdir -p "$PAI_DIR/events"
      '';

      # Install Browser skill with dependencies (needs bun install)
      installBrowserSkill = lib.hm.dag.entryAfter ["writeBoundary" "createPaiDirectories"] ''
        BROWSER_SRC="$HOME/.local/share/pai-skills/Browser"
        BROWSER_DEST="$HOME/.claude/skills/Browser"

        if [ -d "$BROWSER_SRC" ]; then
          mkdir -p "$BROWSER_DEST"

          # Copy source files (rsync to handle updates properly)
          # Use --copy-links to dereference symlinks from nix store
          ${pkgs.rsync}/bin/rsync -a --copy-links --delete --exclude='node_modules' "$BROWSER_SRC/" "$BROWSER_DEST/"

          # Install dependencies if needed
          if [ ! -d "$BROWSER_DEST/node_modules" ] || \
             [ "$BROWSER_SRC/package.json" -nt "$BROWSER_DEST/node_modules/.package-lock.json" ] 2>/dev/null; then
            echo "Installing Browser skill dependencies..."
            (cd "$BROWSER_DEST" && ${pkgs.bun}/bin/bun install --frozen-lockfile 2>/dev/null || ${pkgs.bun}/bin/bun install)
          fi
        fi
      '';
    };
  };
}
