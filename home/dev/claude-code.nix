{pkgs, ...}: {
  programs = {
    claude-code = {
      enable = true;
      package = pkgs.claude-code;

      mcpServers = {
        nixos = {
          command = "nix";
          args = [
            "run"
            "github:utensils/mcp-nixos"
            "--"
          ];
        };
      };
    };

    mcp = {
      enable = true;
      servers = {
        nixos = {
          command = "nix";
          args = [
            "run"
            "github:utensils/mcp-nixos"
            "--"
          ];
        };
      };
    };

    zsh.shellAliases = {
      cc = "claude-code";
    };

    bash.shellAliases = {
      cc = "claude-code";
    };
  };

  home.packages = with pkgs; [
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

  home.sessionVariables = {
  };
}
