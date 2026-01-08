# Home packages aggregator - imports categorized package lists
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./cli.nix
    ./compression.nix
    ./desktop.nix
    ./dev.nix
    ./fonts.nix
    ./media.nix
    ./monitoring.nix
    ./network.nix
  ];

  # Custom scripts and special packages that need extra configuration
  home.packages = [
    (pkgs.writeShellScriptBin "newpy" ''
      dir_name="''${1:-python-project}"
      mkdir -p "$dir_name"
      ${pkgs.git}/bin/git clone git@github.com:clementpoiret/nix-python-devenv.git "$dir_name"
      cd "$dir_name"
    '')
    inputs.naviterm.packages.${pkgs.system}.default
  ];
}
