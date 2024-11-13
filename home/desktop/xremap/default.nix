{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.xremap-flake.packages.${system}.default
  ];
  home.file.".config/xremap/config.yml".source = ./config.yml;
}
