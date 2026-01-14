{
  pkgs,
  theme,
  ...
}: {
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme.base16}.yaml";
    polarity = "dark";
    # Targets to style (foot gets styled automatically via autoEnable)
    targets = {
      # Disable nvim styling - we handle it ourselves via lazyvim-nix
      neovim.enable = false;
      # Disable qt - we have our own qt config in desktop/default.nix
      qt.enable = false;
    };
  };
}
