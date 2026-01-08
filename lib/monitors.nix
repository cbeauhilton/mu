# Monitor configuration abstraction
# Use display descriptions (from `hyprctl monitors all`) for stability across port reassignments
{lib}: let
  mkMonitor = {
    description,
    resolution,
    refreshRate ? 60,
    position,
    scale ? 1,
    transform ? null,
    enabled ? true,
  }: {
    inherit description resolution refreshRate position scale transform enabled;

    # Generate Hyprland monitor string
    toHyprland =
      if !enabled
      then "desc:${description}, disable"
      else let
        base = "desc:${description}, ${toString (builtins.elemAt resolution 0)}x${toString (builtins.elemAt resolution 1)}@${toString refreshRate}, ${toString (builtins.elemAt position 0)}x${toString (builtins.elemAt position 1)}, ${toString scale}";
        transformStr =
          if transform != null
          then ", transform, ${toString transform}"
          else "";
      in
        base + transformStr;
  };
in {
  inherit mkMonitor;

  # Host-specific monitor configurations
  hosts = {
    mu = {
      laptop = mkMonitor {
        description = "Lenovo Group Limited 0x4146";
        resolution = [3840 2400];
        refreshRate = 60;
        position = [4862 810];
        scale = 2;
      };

      dellP2419H = mkMonitor {
        description = "Dell Inc. DELL P2419H 2SMZYR2";
        resolution = [1920 1080];
        refreshRate = 60;
        position = [2942 930];
        scale = 1;
      };

      l3Pro = mkMonitor {
        description = "Biomedical Systems Laboratory L3 PRO L3PRO-240328";
        resolution = [1920 860];
        refreshRate = 60;
        position = [2942 2010];
        scale = 1;
      };

      dellP2417H = mkMonitor {
        description = "Dell Inc. DELL P2417H FMXNR78C18KT";
        resolution = [1920 1080];
        refreshRate = 60;
        position = [1862 360];
        scale = 1;
        transform = 1; # 90 degrees
      };
    };
  };

  # Convert a set of monitors to Hyprland config list
  toHyprlandConfig = monitors: let
    monitorList = lib.attrValues monitors;
    configured = map (m: m.toHyprland) monitorList;
    # Fallback for any unrecognized monitors
    fallback = ", preferred, auto, 1";
  in
    configured ++ [fallback];

  # Get the laptop monitor description for toggle scripts
  getLaptopDescription = monitors:
    if monitors ? laptop
    then monitors.laptop.description
    else null;
}
