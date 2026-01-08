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
    just
    sops
    statix
    tmux
    vim-full
    wget
  ];
}
