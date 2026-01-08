{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./foot
    ./ghostty
    ./hyprland
    ./rofi
    ./waybar
    ./xremap
    ./zathura
  ];

  home = {
    packages = with pkgs; [
      arandr
      clipse
      code-cursor
      discord-ptb
      ffmpeg
      graphviz
      libnotify
      pavucontrol
      showmethekey
      sqlitebrowser
      wf-recorder
      wl-clipboard
      zotero
      neofetch
      zip
      xz
      unzip
      p7zip
      ripgrep
      jq
      yq-go
      eza
      fzf
      mtr
      iperf3
      dnsutils
      ldns
      aria2
      socat
      nmap
      ipcalc
      age
      cowsay
      file
      gawk
      gnupg
      gnused
      gnutar
      tree
      which
      zstd
      nix-output-monitor
      hugo
      glow
      btop
      iotop
      iftop
      strace
      ltrace
      lsof
      sysstat
      lm_sensors
      ethtool
      pciutils
      usbutils
      nerd-fonts.blex-mono
      nerd-fonts.hack
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      ibm-plex
    ];
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
      download = "${config.home.homeDirectory}/dl";
      music = "${config.home.homeDirectory}/media/music";
      videos = "${config.home.homeDirectory}/media/videos";
      pictures = "${config.home.homeDirectory}/media/images";
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
