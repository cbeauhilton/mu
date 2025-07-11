{ pkgs, inputs }:
  pkgs.writeShellScriptBin "screenshot-output" ''
    mkdir -p ~/media/images/screenshots
    timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
    filename="$HOME/media/images/screenshots/$timestamp.png"
    ${inputs.hyprland-contrib.packages.x86_64-linux.grimblast}/bin/grimblast --notify copysave output "$filename"
''
