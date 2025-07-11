{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    # ueberzugpp # image preview - only needed if terminal doesn't have builtin image support
    fd # file searching
    imv # image viewer (lightweight)
    jq # JSON preview
    ffmpegthumbnailer # video thumbnails
    mpv # video and audio player
    poppler # pdf preview
    ripgrep # file content searching
    unar # archive preview
    fzf # directory jumping
    zoxide # directory jumping
  ];
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    keymap = {
    };
    settings = {
      opener = {
        text = [
          {
            run = "'${lib.getExe pkgs.neovim} \"$@\"'";
            desc = "Open in Vim";
          }
        ];
        image = [
          {
            run = "${lib.getExe pkgs.imv} \"$@\"";
            # run = "'${lib.getExe pkgs.imv} \"$@\"'";
            desc = "View in imv";
          }
        ];
        video = [
          {
            run = "'${lib.getExe pkgs.mpv} \"$@\"'";
            desc = "Play in mpv";
          }
        ];
        audio = [
          {
            run = "'${lib.getExe pkgs.mpv} \"$@\"'";
            desc = "Play in mpv";
          }
        ];
      };
      log = {
        enabled = true;
      };
      manager = {
        show_hidden = false;
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
