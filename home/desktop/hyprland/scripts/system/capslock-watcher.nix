{pkgs}:
pkgs.writeShellScriptBin "capslock-watcher" ''
  CAPS_LED=""
  for f in /sys/class/leds/input*::capslock/brightness; do
    [ -f "$f" ] && CAPS_LED="$f" && break
  done
  [ -z "$CAPS_LED" ] && exit 0

  NOTIFIED=0
  while true; do
    STATE=$(cat "$CAPS_LED" 2>/dev/null || echo 0)
    if [ "$STATE" = "1" ] && [ "$NOTIFIED" = "0" ]; then
      ${pkgs.libnotify}/bin/notify-send -u critical -t 0 \
        "Caps Lock ON" \
        "Press Ctrl+Alt+Escape to reset keybinds"
      NOTIFIED=1
    elif [ "$STATE" = "0" ] && [ "$NOTIFIED" = "1" ]; then
      NOTIFIED=0
    fi
    sleep 1
  done
''
