# Theme configuration for consistent styling across terminal, neovim, and desktop
#
# Available themes:
#   - selenized-black (OLED-friendly true black)
#   - selenized-dark
#   - selenized-light
#   - selenized-white
#   - gruvbox-dark-hard
#
# Usage: Set `theme` in extraSpecialArgs, then reference in modules
_: let
  themes = {
    selenized-black = {
      name = "selenized-black";
      base16 = "selenized-black";
      nvim = {
        plugin = "selenized";
        colorscheme = "selenized";
        variant = "black";
      };
    };
    selenized-dark = {
      name = "selenized-dark";
      base16 = "selenized-dark";
      nvim = {
        plugin = "selenized";
        colorscheme = "selenized";
        variant = "dark";
      };
    };
    selenized-light = {
      name = "selenized-light";
      base16 = "selenized-light";
      nvim = {
        plugin = "selenized";
        colorscheme = "selenized";
        variant = "light";
      };
    };
    selenized-white = {
      name = "selenized-white";
      base16 = "selenized-white";
      nvim = {
        plugin = "selenized";
        colorscheme = "selenized";
        variant = "white";
      };
    };
    gruvbox-dark-hard = {
      name = "gruvbox-dark-hard";
      base16 = "gruvbox-dark-hard";
      nvim = {
        plugin = "gruvbox";
        colorscheme = "gruvbox";
        variant = null;
      };
    };
  };
in {
  inherit themes;

  # Default theme
  default = themes.selenized-black;

  # Helper to get theme by name
  get = name: themes.${name} or themes.selenized-black;
}
