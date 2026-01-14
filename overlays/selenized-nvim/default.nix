{
  lib,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "selenized-nvim";
  version = "1.0.0";
  src = ./.;

  meta = with lib; {
    description = "Selenized colorscheme for Neovim with all 4 variants (dark, black, light, white)";
    homepage = "https://github.com/jan-warchol/selenized";
    license = licenses.mit;
    maintainers = [];
  };
}
