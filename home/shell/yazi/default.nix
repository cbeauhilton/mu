{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    ffmpegthumbnailer # video thumbnails
    unar # archive preview
    jq # JSON preview
    poppler # pdf preview
    fd # file searching
    ripgrep # file content searching
    fzf # directory jumping
    zoxide # directory jumping
    ueberzugpp # image preview - only needed if terminal doesn't have builtin image support, e.g. Alacritty
  ];
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    keymap = {
    };
    settings = {
      opener.text = [
        {
          run = "'${lib.getExe pkgs.neovim} \"$@\"'";
        }
      ];
      log = {
        enabled = true;
      };
      manager = {
        show_hidden = true;
        sort_by = "mtime";
        sort_dir_first = true;
        sort_reverse = true;
        prepend_keymap = [
          {
            on = "!";
            run = "shell \"$SHELL\" --block --confirm";
            desc = "Open shell here";
          }
        ];
      };
    };
    theme = {
      filetype = {
        rules = [
          {
            fg = "#458588";
            mime = "image/*";
          }
          {
            fg = "#B16286";
            mime = "video/*";
          }
          {
            fg = "#8EC07C";
            mime = "audio/*";
          }
          {
            fg = "#D79921";
            mime = "application/x-bzip";
          }
        ];
      };
    };
  };
}
