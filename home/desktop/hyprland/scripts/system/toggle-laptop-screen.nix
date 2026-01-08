{
  pkgs,
  monitors,
}: let
  laptopDesc = monitors.laptop.description;
in
  pkgs.writeShellScriptBin "toggle-laptop-screen" ''
    LAPTOP_NAME=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[]|select(.description=="${laptopDesc}").name')
    if [ -z "$LAPTOP_NAME" ]; then
      echo "Laptop monitor not found"
      exit 1
    fi
    if [ $(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[]|select(.description=="${laptopDesc}").dpmsStatus') = "true" ]; then
      sleep 1 && ${pkgs.hyprland}/bin/hyprctl dispatch dpms off "$LAPTOP_NAME"
    else
      ${pkgs.hyprland}/bin/hyprctl dispatch dpms on "$LAPTOP_NAME"
    fi
  ''
