{...}: {
  imports = [
    ./browsers
    ./desktop
    ./dev
    ./media
    ./nvim
    ./packages
    ./shell
    ./work # conditional via work.azure.enable
  ];

  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
