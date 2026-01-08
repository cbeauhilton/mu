{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      nerd-fonts.blex-mono
      nerd-fonts.hack
      nerd-fonts.fira-code
      ibm-plex
    ];
    fontDir.enable = true;
    fontconfig.defaultFonts = {
      serif = ["IBM Plex Serif"];
      sansSerif = ["IBM Plex Sans"];
      monospace = ["BlexMono"];
    };
  };
}
