_: {
  programs.ghostty = {
    enable = true;
    installVimSyntax = true;
    installBatSyntax = true;
    enableZshIntegration = true;
    settings = {
      font-family = "BlexMono Nerd Font";
      font-style-bold = false;
      font-style-bold-italic = false;
      # font-size = 11;
      theme = "GruvboxDarkHard";
      # theme = "0x96f";
      # theme = "tokyonight_night";
      # background = "000000";
      window-decoration = false;
      window-padding-x = 10;
      window-padding-y = 10;
      window-padding-color = "extend";
      keybind = [
        "ctrl+shift+n=new_window"
      ];
    };
  };
}
