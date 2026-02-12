# CLI tools and utilities
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    alejandra
    curl
    deadnix
    dust
    gh
    git
    gping # Ping with a graph
    hcloud
    just
    sops
    statix
    tmux
    vim-full
    wget
  ];
}
