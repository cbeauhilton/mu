{
  config,
  pkgs,
  ...
}: {
  # sops.secrets.spotify_id = {};
  # sops.secrets.spotify_secret = {};
  # sops.secrets.spotify_username = {};
  # sops.secrets.spotify_password = {};
  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      # mopidy-spotify # failing to build for some reason
      mopidy-subidy
      mopidy-mpd
    ];
    settings = {
      file = {
        enabled = true;
        media_dirs = [
          "/home/beau/media/music"
        ];
        follow_symlinks = false;
        show_dotfiles = false;
        excluded_file_extensions = [
          ".html"
          ".zip"
          ".jpg"
          ".jpeg"
          ".png"
          ".directory"
          ".log"
          ".nfo"
          ".pdf"
          ".txt"
        ];
      };
      m3u = {
        playlists_dir = "$XDG_CONFIG_DIR/mopidy/playlists";
      };
      mpd = {
        enabled = true;
        hostname = "::";
        port = 6600;
      };
      subidy = {
        enabled = true;
        url = "https://music.beauslab.casa";
        username = "admin";
        password = "admin";
        api_version = "1.16";
      };
      spotify = {
        # client_id = "${config.sops.secrets."spotify_id".path}";
        # client_secret = "${config.sops.secrets."spotify_secret".path}";
        # username = "${config.sops.secrets."spotify_username".path}";
        # password = "${config.sops.secrets."spotify_password".path}";
      };
    };
  };
}
