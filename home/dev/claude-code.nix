{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./mcp-servers.nix
  ];

  programs = {
    claude-code = {
      enable = true;
      package = pkgs.claude-code;
      # MCP servers are now managed in mcp-servers.nix
      # and written directly to ~/.claude.json
    };
    # Removed programs.mcp - it writes to ~/.config/mcp/mcp.json
    # but Claude Code looks in ~/.claude.json
    zsh.shellAliases.cc = "claude-code";
    bash.shellAliases.cc = "claude-code";
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
    ];
    activation = {
      claudeStableLink = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p $HOME/.local/bin
        rm -f $HOME/.local/bin/claude $HOME/.local/bin/claude-bun
        ln -s ${pkgs.claude-code}/bin/claude $HOME/.local/bin/claude
        ln -s ${pkgs.claude-code-bun}/bin/claude-bun $HOME/.local/bin/claude-bun
        if [ -d "$HOME/.claude" ]; then chmod -R 700 "$HOME/.claude"; fi
        mkdir -p $HOME/.claude
      '';
      preserveClaudeConfig = lib.hm.dag.entryBefore ["writeBoundary"] ''
        if [ -f "$HOME/.claude.json" ]; then
          cp -p "$HOME/.claude.json" "$HOME/.claude.json.backup" 2>/dev/null || true
        fi
      '';
      restoreClaudeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -f "$HOME/.claude.json.backup" ] && [ ! -f "$HOME/.claude.json" ]; then
          cp -p "$HOME/.claude.json.backup" "$HOME/.claude.json"
        fi
      '';
    };
  };
}
