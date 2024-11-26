{pkgs, ...}: {
  imports = [
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    # greetd.tuigreet
    alacritty
    alejandra
    bitwarden-cli
    bun
    curl
    devenv
    docker
    docker-compose
    git
    just
    libgcc
    mpv
    neovim
    networkmanagerapplet
    nh
    openssl
    pnpm
    postgresql
    rustup
    sops
    tmux
    vlc
    wget
    uv
    zig
  ];
}
