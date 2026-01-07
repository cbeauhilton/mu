{pkgs, ...}: {
  imports = [
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    # nvi # this is a nice version of vi, but breaking the install. idk.
    # oryx # TUI for sniffing traffic - not yet packaged for nix
    # somo # TUI for netstat - not yet packaged for nix
    anki
    alejandra
    bitwarden-desktop
    bitwarden-cli
    bluetui # TUI for bluetooth
    bun
    claude-code
    curl
    devenv
    lazydocker
    docker
    docker-compose
    dust
    google-chrome
    golangci-lint
    golangci-lint-langserver
    git
    gping # Ping with a graph
    junction # use as default browser to add selection, haven't implemented yet, seems cool
    just
    libgcc
    gcc # C compiler for nvim-treesitter
    go
    gotools
    go-task
    natscli
    templ
    tree-sitter # CLI for nvim-treesitter
    mpv
    natscli
    nats-top
    neovim
    # nh
    openssl
    pnpm
    postgresql
    rustup
    sops
    sqlite
    sqlite-interactive
    systemctl-tui
    statix
    teams-for-linux
    tenv
    terraform
    tmux
    trippy # traceroute + ping, pretty
    uv
    vim-full
    vlc
    wget
    visidata # vd - terminal data multitool
    zig
  ];
}
