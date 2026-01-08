# Fonts
{pkgs, ...}: {
  home.packages = with pkgs; [
    ibm-plex
    nerd-fonts.blex-mono
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
  ];
}
