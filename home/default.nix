{...}: {
  imports = [
    ./browsers
    ./desktop
    ./media
    ./shell
    ./work
  ];

  home.file = {
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
  };
}
