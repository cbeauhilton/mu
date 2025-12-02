{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../home
  ];

  home.username = "beau";
  home.packages = with pkgs; [
    neofetch

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    kdePackages.dolphin

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
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

    # nix related
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # fonts
    nerd-fonts.blex-mono
    nerd-fonts.hack
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    ibm-plex

    (pkgs.writeShellScriptBin "newpy" ''
      dir_name="''${1:-python-project}"
      mkdir -p "$dir_name"
      ${pkgs.git}/bin/git clone git@github.com:clementpoiret/nix-python-devenv.git "$dir_name"
      cd "$dir_name"
    '')
    inputs.naviterm.packages.${pkgs.system}.default
  ];

  home.file.".config/naviterm/naviterm.ini".text = ''
    server_address=https://music.beauslab.casa
    user=admin
    password=admin
    server_auth=token
    primary_accent=yellow
    secondary_accent=gray
    home_list_size=30
    follow_cursor_queue=true
    draw_while_unfocused=false
    save_player_status=true
  '';

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Beau Hilton";
        email = "beau@beauhilton.com";
      };
    };
  };
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;
  programs.neovim.defaultEditor = true;
  programs.yt-dlp = {
    enable = true;
    settings = {
      embed-chapters = true; # embed all the things
      embed-metadata = true;
      embed-thumbnail = true;
      convert-thumbnail = "jpg";
      # so every file manager can show the thumbnail - webp support is not quite universal
      embed-subs = true;
      sub-langs = "all";
      # subtitle files are very small,
      # and sometimes language names are declared badly,
      # so worth it to grab them all
      downloader = "aria2c";
      downloader-args = "aria2c:'-c -x16 -s16 -k2M'";
      # -c is resume if interrupted ("continue"),
      # -x is max connections to a server,
      # -s is number of connections used for download of a specific file,
      # -k is size of chunks
      download-archive = "yt-dlp-archive.txt";
      # writes a file to the current directory specifying which files have already been downloaded -
      # nice for updating your collection of a channel's videos
      # (just run the download command again and it will grab only what you're missing)
      restrict-filenames = true; # disallow spaces, weird characters, etc.
      output = "%(upload_date>%Y-%m-%d)s--%(uploader)s--%(title)s--%(id)s.%(ext)s";
      # I like to be able to sort by date
      # and have enough info in the filename
      # so I don't need to open it to find out what it is,
      # so I include the:
      # - ISO 8601-style date
      # - uploader's name
      # - title of the video
      # - video ID (for easy copy pasta if I ever want to find it online,
      # e.g. to see the comment section or show notes.)
    };
  };
  programs.aria2 = {
    enable = true;
  };

  fonts.fontconfig.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    shellAliases = {
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
  };

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}
