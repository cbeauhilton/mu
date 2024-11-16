{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hyprland
    ./xremap
    ./waybar
    ./rofi
    ./zathura
    # ./ags
  ];
  home.packages = with pkgs; [
    arandr # GUI for arranging multiple screens
    code-cursor # vscode with LLMs built in
    pavucontrol # GUI for audio inputs/outputs
    simplescreenrecorder
    zotero # should probably move this to an "academic" folder or smth
    libnotify
  ];
  # theming
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Numix-Cursor";
    package = pkgs.numix-cursor-theme;
    size = 32;
  };
  gtk = {
    enable = true;
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };
  home.sessionVariables.GTK_THEME = "Materia-dark";

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };

  xdg = {
    enable = true;
    userDirs.download = "${config.home.homeDirectory}/dl";
    desktopEntries = {
      firefox = {
        name = "Firefox";
        genericName = "Web Browser";
        exec = "firefox %U";
        terminal = false;
        categories = ["Application" "Network" "WebBrowser"];
        mimeType = ["text/html" "text/xml"];
      };
    };
  };
}
