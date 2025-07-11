{pkgs}:
pkgs.writeShellScriptBin "toggle-laptop-screen" ''
  if [ $(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[]|select(.description=="Lenovo Group Limited 0x4146").dpmsStatus') = "true" ]; then
    sleep 1 && ${pkgs.hyprland}/bin/hyprctl dispatch dpms off eDP-1
  else
    ${pkgs.hyprland}/bin/hyprctl dispatch dpms on eDP-1
  fi
''
