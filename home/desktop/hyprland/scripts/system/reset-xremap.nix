{pkgs}:
pkgs.writeShellScriptBin "reset-xremap" ''
  ${pkgs.procps}/bin/pkill -x xremap || true
  sleep 0.5
  xremap --watch .config/xremap/config.yml &
  disown
  ${pkgs.libnotify}/bin/notify-send -t 3000 "Keybinds Reset" "xremap restarted"
''
