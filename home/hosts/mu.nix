# Home-manager configuration for mu (ThinkPad X1 Carbon)
{...}: {
  imports = [../common.nix];

  # Host-specific module enables
  browsers.chrome-debug.enable = true;
  media.music.enable = true;
  # work.azure.enable = true; # uncomment when needed

  home = {
    username = "beau";
    stateVersion = "23.11";
  };
}
