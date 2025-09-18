{pkgs, ...}: let
  musicDir = "/home/beau/media/music";
in {
  home.packages = with pkgs; [
    # mopidy
    mopidy-subidy
    mopidy-mpd
  ];
  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-subidy
      mopidy-mpd
      # mopidy-local
    ];
    settings = {
      file = {
        enabled = true;
        media_dirs = [
          "${musicDir}"
        ];
        # follow_symlinks = false;
        # show_dotfiles = false;
        # excluded_file_extensions = [
        #   ".html"
        #   ".zip"
        #   ".jpg"
        #   ".jpeg"
        #   ".png"
        #   ".directory"
        #   ".log"
        #   ".nfo"
        #   ".pdf"
        #   ".txt"
        # ];
      };
      m3u = {
        enabled = true;
        playlists_dir = "${musicDir}/mopidy/playlists";
        default_encoding = "utf-8";
        default_extension = ".m3u8";
      };
      http = {
        hostname = "0.0.0.0";
      };
      mpd = {
        enabled = true;
        hostname = "localhost";
        port = 6600;
        max_connections = 20;
        connection_timeout = 60;
      };
      subidy = {
        enabled = true;
        url = "https://music.beauslab.casa";
        username = "admin";
        password = "admin";
        api_version = "1.16";
      };
      # might add spotify support at some point
      # but tbh I like self-hosting more, better selection ;)
      # spotify = {
      # client_id = "${config.sops.secrets."spotify_id".path}";
      # client_secret = "${config.sops.secrets."spotify_secret".path}";
      # username = "${config.sops.secrets."spotify_username".path}";
      # password = "${config.sops.secrets."spotify_password".path}";
      # sops.secrets.spotify_id = {};
      # sops.secrets.spotify_secret = {};
      # sops.secrets.spotify_username = {};
      # sops.secrets.spotify_password = {};
      # };
    };
  };
  programs.ncmpcpp = {
    enable = true;
    settings = {
      ncmpcpp_directory = "${musicDir}/ncmpcpp";
      lyrics_directory = "${musicDir}/lyrics";
      progressbar_look = "->";
      display_volume_level = "no";
      autocenter_mode = "yes";
      message_delay_time = 1;
      playlist_display_mode = "columns";
      playlist_editor_display_mode = "columns";
      browser_display_mode = "columns";
      media_library_primary_tag = "album_artist";
      media_library_albums_split_by_date = "no";
      ignore_leading_the = "yes";
      ignore_diacritics = "yes";
      external_editor = "vim";
      use_console_editor = "yes";
      startup_screen = "browser";
      mpd_host = "localhost";
      mpd_port = 6600;
    };
    bindings = [
      {
        key = "j";
        command = "scroll_down";
      }
      {
        key = "k";
        command = "scroll_up";
      }
      {
        key = "u";
        command = "page_up";
      }
      {
        key = "d";
        command = "page_down";
      }
      {
        key = "G";
        command = "move_end";
      }
      {
        key = "g";
        command = "move_home";
      }
      {
        key = "h";
        command = "jump_to_parent_directory";
      }
      {
        key = "h";
        command = "previous_column";
      }
      {
        key = "l";
        command = "next_column";
      }
      {
        key = "l";
        command = "enter_directory";
      }
      {
        key = "l";
        command = "run_action";
      }
      {
        key = "l";
        command = "play_item";
      }
      {
        key = "s";
        command = "reset_search_engine";
      }
      {
        key = "s";
        command = "show_search_engine";
      }
      {
        key = "f";
        command = "show_browser";
      }
      {
        key = "f";
        command = "change_browse_mode";
      }
      {
        key = "x";
        command = "delete_playlist_items";
      }
      {
        key = "P";
        command = "show_playlist";
      }
      {
        key = "m";
        command = "show_media_library";
      }
    ];
  };
}
