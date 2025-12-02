{pkgs, ...}: {
  imports = [
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    # nvi # this is a nice version of vi, but breaking the install. idk.
    # oryx # TUI for sniffing traffic - not yet packaged for nix
    # somo # TUI for netstat - not yet packaged for nix
    alejandra
    bitwarden-desktop
    bitwarden-cli
    bluetui # TUI for bluetooth
    bun
    curl
    devenv
    lazydocker
    docker
    docker-compose
    git
    gping # Ping with a graph
    junction # use as default browser to add selection, haven't implemented yet, seems cool
    just
    libgcc
    gcc # C compiler for nvim-treesitter
    tree-sitter # CLI for nvim-treesitter
    mpv
    neovim
    # nh
    openssl
    pnpm
    postgresql
    rustup
    sops
    systemctl-tui
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
