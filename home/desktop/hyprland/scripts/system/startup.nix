{pkgs}:
pkgs.writeShellScriptBin "start" ''
  ${pkgs.waybar}/bin/waybar &
  sleep 1
  ${pkgs.mako}/bin/mako &
  ${pkgs.clipse}/bin/clipse -listen &
  ${pkgs.waypaper}/bin/waypaper --resume &
  xremap --watch .config/xremap/config.yml &
''
