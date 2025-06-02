{pkgs, ...}: {
  imports = [
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    # nvi # this is a nice version of vi, but breaking the install. idk.
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
    teams-for-linux
    tmux
    uv
    vlc
    wget
    zig
    terraform
    tenv
    vim-full
  ];
}
