# Common home-manager configuration shared across all hosts
{...}: {
  imports = [
    ./browsers
    ./desktop
    ./dev
    ./media
    ./nvim
    ./packages
    ./secrets
    ./shell
    ./work
  ];

  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
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
        export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$GOPATH/bin"
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
