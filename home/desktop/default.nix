{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hyprland
    ./ghostty
    ./xremap
    ./waybar
    ./rofi
    ./zathura
    # ./ags
  ];
  home.packages = with pkgs; [
    arandr # GUI for arranging multiple screens
    clipse
    code-cursor # vscode with LLMs built in
    discord-ptb
    ffmpeg
    graphviz
    libnotify
    pavucontrol # GUI for audio inputs/outputs
    sqlitebrowser
    wf-recorder
    wl-clipboard
    zotero # should probably move this to an "academic" folder or smth
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
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };
  home.preferXdgDirectories = true;
  xdg = {
    enable = true;
    userDirs = {
      createDirectories = true;
      download = "${config.home.homeDirectory}/dl";
      music = "${config.home.homeDirectory}/media/music";
      videos = "${config.home.homeDirectory}/media/videos";
      pictures = "${config.home.homeDirectory}/media/images";
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/media/images/screenshots";
      };
    };
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
