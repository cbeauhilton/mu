{...}: {
  programs.foot = {
    enable = true;
    server.enable = true; # Enables foot server for faster startup
    settings = {
      main = {
        # Font configuration matching your Ghostty setup
        font = "BlexMono Nerd Font:size=11";
        font-bold = "BlexMono Nerd Font:style=Bold:size=11";
        font-italic = "BlexMono Nerd Font:style=Italic:size=11";
        font-bold-italic = "BlexMono Nerd Font:style=Bold Italic:size=11";
        
        # pad = "10x10";
        # resize-delay-ms = 100;
        
        # Performance optimizations
        dpi-aware = "yes";
        workers = 4; # Adjust based on your CPU cores
      };

      # # Gruvbox Dark Hard theme colors
      # colors = {
      #   # Background and foreground
      #   background = "1d2021";  # Gruvbox dark hard background
      #   foreground = "ebdbb2";  # Gruvbox light foreground
      #
      #   # Normal colors (0-7)
      #   regular0 = "282828";   # black
      #   regular1 = "cc241d";   # red
      #   regular2 = "98971a";   # green
      #   regular3 = "d79921";   # yellow
      #   regular4 = "458588";   # blue
      #   regular5 = "b16286";   # magenta
      #   regular6 = "689d6a";   # cyan
      #   regular7 = "a89984";   # white
      #
      #   # Bright colors (8-15)
      #   bright0 = "928374";    # bright black
      #   bright1 = "fb4934";    # bright red
      #   bright2 = "b8bb26";    # bright green
      #   bright3 = "fabd2f";    # bright yellow
      #   bright4 = "83a598";    # bright blue
      #   bright5 = "d3869b";    # bright magenta
      #   bright6 = "8ec07c";    # bright cyan
      #   bright7 = "ebdbb2";    # bright white
      #
      #   # Selection colors
      #   selection-foreground = "1d2021";
      #   selection-background = "ebdbb2";
      #
      #   # URL colors
      #   urls = "83a598";  # Blue for URLs
      # };

      # Cursor configuration
      cursor = {
        style = "block";
        blink = "no";
      };

      # Mouse behavior
      mouse = {
        hide-when-typing = "yes";
        alternate-scroll-mode = "yes";
      };

      # Scrollback
      scrollback = {
        lines = 10000;
        multiplier = 3.0;
      };

    };
  };
}
