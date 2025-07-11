{pkgs, ...}: {
  programs.stylix = {
    enable = true;
    autoEnable = true;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  };
}
