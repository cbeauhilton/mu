{
  pkgs,
  lib,
  ...
}: {
  programs = {
    claude-code = {
      enable = true;
      package = pkgs.claude-code;
      mcpServers.nixos = {
        command = "nix";
        args = ["run" "github:utensils/mcp-nixos" "--"];
      };
    };
    mcp = {
      enable = true;
      servers.nixos = {
        command = "nix";
        args = ["run" "github:utensils/mcp-nixos" "--"];
      };
    };
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
