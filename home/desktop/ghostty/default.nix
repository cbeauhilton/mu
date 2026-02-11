{
  lib,
  config,
  ...
}: {
  options.custom.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator";

  config = lib.mkIf config.custom.ghostty.enable {
    programs.ghostty = {
      enable = true;
      installVimSyntax = true;
      installBatSyntax = true;
      enableZshIntegration = true;
      settings = {
        font-family = "BlexMono Nerd Font";
        font-style-bold = false;
        font-style-bold-italic = false;
        theme = "Gruvbox Dark Hard";
        window-decoration = false;
        window-padding-x = 10;
        window-padding-y = 10;
        window-padding-color = "extend";
        keybind = [
          "ctrl+shift+n=new_window"
        ];
      };
    };
  };
}
