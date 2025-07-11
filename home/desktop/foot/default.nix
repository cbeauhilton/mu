{...}:
  let
    font = "BlexMono Nerd Font";
    fontsize = "10";
  in
  {
  programs.foot = {
    enable = true;
    server.enable = true; # Enables foot server for faster startup
    settings = {
      main = {
        font = "${font}:size=${fontsize}";
        font-bold = "${font}:style=Bold:size=${fontsize}";
        font-italic = "${font}:style=Italic:size=${fontsize}";
        font-bold-italic = "${font}:style=Bold Italic:size=${fontsize}";

        # pad = "10x10";
        # resize-delay-ms = 100;

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
    };
  };
}
