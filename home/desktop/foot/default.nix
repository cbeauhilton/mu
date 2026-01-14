{theme, ...}: let
  font = "BlexMono Nerd Font";
  fontsize = "10";

  # Selenized color palettes
  colors = {
    selenized-black = {
      background = "181818";
      foreground = "b9b9b9";
      regular0 = "252525"; # bg_1
      regular1 = "ed4a46"; # red
      regular2 = "70b433"; # green
      regular3 = "dbb32d"; # yellow
      regular4 = "368aeb"; # blue
      regular5 = "eb6eb7"; # magenta
      regular6 = "3fc5b7"; # cyan
      regular7 = "777777"; # dim_0
      bright0 = "3b3b3b"; # bg_2
      bright1 = "ff5e56"; # br_red
      bright2 = "83c746"; # br_green
      bright3 = "efc541"; # br_yellow
      bright4 = "4f9cfe"; # br_blue
      bright5 = "ff81ca"; # br_magenta
      bright6 = "56d8c9"; # br_cyan
      bright7 = "dedede"; # fg_1
    };
    selenized-dark = {
      background = "103c48";
      foreground = "adbcbc";
      regular0 = "184956";
      regular1 = "fa5750";
      regular2 = "75b938";
      regular3 = "dbb32d";
      regular4 = "4695f7";
      regular5 = "f275be";
      regular6 = "41c7b9";
      regular7 = "72898f";
      bright0 = "2d5b69";
      bright1 = "ff665c";
      bright2 = "84c747";
      bright3 = "ebc13d";
      bright4 = "58a3ff";
      bright5 = "ff84cd";
      bright6 = "53d6c7";
      bright7 = "cad8d9";
    };
    gruvbox-dark-hard = {
      background = "1d2021";
      foreground = "ebdbb2";
      regular0 = "282828";
      regular1 = "cc241d";
      regular2 = "98971a";
      regular3 = "d79921";
      regular4 = "458588";
      regular5 = "b16286";
      regular6 = "689d6a";
      regular7 = "a89984";
      bright0 = "928374";
      bright1 = "fb4934";
      bright2 = "b8bb26";
      bright3 = "fabd2f";
      bright4 = "83a598";
      bright5 = "d3869b";
      bright6 = "8ec07c";
      bright7 = "ebdbb2";
    };
  };

  # Get colors for current theme (default to selenized-black if not found)
  c = colors.${theme.name} or colors.selenized-black;
in {
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        font = "${font}:size=${fontsize}";
        font-bold = "${font}:style=Bold:size=${fontsize}";
        font-italic = "${font}:style=Italic:size=${fontsize}";
        font-bold-italic = "${font}:style=Bold Italic:size=${fontsize}";
        dpi-aware = "yes";
      };

      cursor = {
        style = "block";
        blink = "no";
      };

      mouse = {
        hide-when-typing = "yes";
        alternate-scroll-mode = "yes";
      };

      scrollback = {
        lines = 10000;
        multiplier = 3.0;
      };

      colors = {
        inherit
          (c)
          background
          foreground
          regular0
          regular1
          regular2
          regular3
          regular4
          regular5
          regular6
          regular7
          bright0
          bright1
          bright2
          bright3
          bright4
          bright5
          bright6
          bright7
          ;
      };
    };
  };
}
