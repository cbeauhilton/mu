{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./espanso
    ./foot
    ./ghostty
    ./hyprland
    ./rofi
    # ./stylix  # TODO: re-enable once Qt compatibility is fixed
    ./waybar
    ./xremap
    ./zathura
  ];

  home = {
    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
      size = 32;
    };
    sessionVariables.GTK_THEME = "Materia-dark";
    preferXdgDirectories = true;
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
    gtk4.extraConfig.Settings = "gtk-application-prefer-dark-theme=1";
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };

  xdg = {
    enable = true;
    userDirs = {
      createDirectories = true;
      documents = "${config.home.homeDirectory}/docs";
      download = "${config.home.homeDirectory}/dl";
      music = "${config.home.homeDirectory}/media/music";
      videos = "${config.home.homeDirectory}/media/videos";
      pictures = "${config.home.homeDirectory}/media/images";
      desktop = config.home.homeDirectory;
      templates = config.home.homeDirectory;
      publicShare = config.home.homeDirectory;
      extraConfig.XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/media/images/screenshots";
    };
    desktopEntries.firefox = {
      name = "Firefox";
      genericName = "Web Browser";
      exec = "firefox %U";
      terminal = false;
      categories = ["Application" "Network" "WebBrowser"];
      mimeType = ["text/html" "text/xml"];
    };
  };
}
