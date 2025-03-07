{ config, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.blex-mono
    nerd-fonts.hack
    nerd-fonts.fira-code
    ibm-plex
  ];

  fonts.fontDir.enable = true;
  fonts.fontconfig = {
    defaultFonts = {
      serif = ["IBM Plex Serif"];
      sansSerif = ["IBM Plex Sans"];
      monospace = ["BlexMono"];
    };
  };
} 