{...}: {
  imports = [
    ./browsers
    ./desktop
    ./media
    ./shell
    ./nvim
    # ./work
  ];

  home.file = {
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
  };
}
