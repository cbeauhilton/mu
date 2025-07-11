{
  config,
  pkgs,
  lib,
  ...
}: let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "b8860253fc44e500edeb7a09db648a829084facd";
    hash = "sha256-29K8PmBoqAMcQhDIfOVnbJt2FU4BR6k23Es9CqyEloo=";
  };
in {
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
    shellWrapperName = "y";

    plugins = {
      chmod = "${yazi-plugins}/chmod.yazi";
      full-border = "${yazi-plugins}/full-border.yazi";
      toggle-pane = "${yazi-plugins}/toggle-pane.yazi";
      git = "${yazi-plugins}/git.yazi";
      mount = "${yazi-plugins}/mount.yazi";
      zoom = "${yazi-plugins}/zoom.yazi";
      starship = pkgs.fetchFromGitHub {
        owner = "Rolv-Apneseth";
        repo = "starship.yazi";
        rev = "a63550b2f91f0553cc545fd8081a03810bc41bc0";
        sha256 = "sha256-PYeR6fiWDbUMpJbTFSkM57FzmCbsB4W4IXXe25wLncg=";
      };
    };

    initLua = ''
      require("full-border"):setup()
      require("starship"):setup()
      require("git"):setup()
    '';

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "T";
          run = "plugin toggle-pane max-preview";
          desc = "Maximize or restore the preview pane";
        }
        {
          on = ["c" "m"];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
        {
          on = "!";
          run = "shell \"$SHELL\" --block --confirm";
          desc = "Open shell here";
        }
        {
          on = "M";
          run = "plugin mount";
          desc = "Mount/unmount drives";
        }
        {
          on = "+";
          run = "plugin zoom 1";
          desc = "Zoom in hovered file";
        }
        {
          on = "-";
          run = "plugin zoom -1";
          desc = "Zoom out hovered file";
        }
      ];
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
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
      plugin = {
        prepend_fetchers = [
          {
            id = "git";
            name = "*";
            run = "git";
          }
          {
            id = "git";
            name = "*/";
            run = "git";
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
