{
  pkgs,
  inputs,
  ...
}: {
  imports = [../home];

  home = {
    username = "beau";
    stateVersion = "23.11";
    packages = with pkgs; [
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
      kdePackages.dolphin
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
      (pkgs.writeShellScriptBin "newpy" ''
        dir_name="''${1:-python-project}"
        mkdir -p "$dir_name"
        ${pkgs.git}/bin/git clone git@github.com:clementpoiret/nix-python-devenv.git "$dir_name"
        cd "$dir_name"
      '')
      inputs.naviterm.packages.${pkgs.system}.default
    ];
    file.".config/naviterm/naviterm.ini".text = ''
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
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      settings.user = {
        name = "Beau Hilton";
        email = "beau@beauhilton.com";
      };
    };
    yt-dlp = {
      enable = true;
      settings = {
        embed-chapters = true;
        embed-metadata = true;
        embed-thumbnail = true;
        convert-thumbnail = "jpg";
        embed-subs = true;
        sub-langs = "all";
        downloader = "aria2c";
        downloader-args = "aria2c:'-c -x16 -s16 -k2M'";
        download-archive = "yt-dlp-archive.txt";
        restrict-filenames = true;
        output = "%(upload_date>%Y-%m-%d)s--%(uploader)s--%(title)s--%(id)s.%(ext)s";
      };
    };
    aria2.enable = true;
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };
    bash = {
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
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
    };
  };
}
