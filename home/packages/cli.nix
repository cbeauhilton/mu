# CLI tools and utilities
{pkgs, ...}: {
  home.packages = with pkgs; [
    age
    aria2
    bat
    bc
    cowsay
    delta
    dnsutils
    eza
    fd
    file
    fzf
    gawk
    glow
    gnupg
    gnused
    gnutar
    hugo
    ipcalc
    jq
    ldns
    ncdu
    neofetch
    nil
    nix-output-monitor
    ov
    ripgrep
    socat
    tree
    which
    yq-go
    zstd
  ];
}
