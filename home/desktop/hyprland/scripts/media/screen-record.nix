{ pkgs }:
pkgs.writeShellScriptBin "screen-record" ''
  mkdir -p ~/media/videos/screenrecordings
  timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
  filename="$HOME/media/videos/screenrecordings/$timestamp.mkv"

  if pgrep -x "wf-recorder" > /dev/null; then
    pkill -x wf-recorder
    ${pkgs.libnotify}/bin/notify-send "Screen Recording" "Recording stopped"
  else
    ${pkgs.wf-recorder}/bin/wf-recorder -f "$filename" &
    ${pkgs.libnotify}/bin/notify-send "Screen Recording" "Recording started: $timestamp.mkv"
  fi
''
