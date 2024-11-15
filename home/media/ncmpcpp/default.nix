{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
  ];
  programs.ncmpcpp = {
    enable = true;
    settings = {
      ncmpcpp_directory = "~/.local/share/ncmpcpp";
      lyrics_directory = "~/.local/share/lyrics";
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
