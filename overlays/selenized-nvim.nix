# Selenized colorscheme for Neovim with all 4 variants
_final: prev: {
  vimPlugins =
    prev.vimPlugins
    // {
      selenized-nvim = prev.callPackage ./selenized-nvim {};
    };
}
