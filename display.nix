{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # X server configuration
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    xkb.options = "caps:escape";
    # videoDrivers = [ "displaylink" "modesetting" ];
  };

  console = {
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Hardware graphics support
  hardware.graphics.enable = true;

  # DisplayLink configuration
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     displaylink = prev.displaylink.overrideAttrs (old: {
  #       version = "6.1.0-17";
  #       src = pkgs.fetchurl {
  #         url = "https://www.synaptics.com/sites/default/files/exe_files/2024-10/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.1-EXE.zip";
  #         name = "displaylink-610.zip";
  #         sha256 = "1b3w7gxz54lp0hglsfwm5ln93nrpppjqg5sfszrxpw4qgynib624";
  #       };
  #
  #       # Simplified installation approach
  #       installPhase = ''
  #         mkdir -p $out/share/displaylink
  #         cp displaylink-driver-6.1.0-17.run $out/share/displaylink/
  #         cd $out/share/displaylink
  #         chmod +x displaylink-driver-6.1.0-17.run
  #
  #         # Create a simple script to run the DisplayLink manager
  #         mkdir -p $out/bin
  #         cat > $out/bin/DisplayLinkManager <<EOF
  #         #!/bin/sh
  #         echo "DisplayLink Manager starting..."
  #         # Add any necessary environment setup here
  #         exec /run/current-system/sw/bin/evdi_dlm
  #         EOF
  #         chmod +x $out/bin/DisplayLinkManager
  #
  #         # Include the driver in firmware
  #         mkdir -p $out/lib/firmware/displaylink
  #         cp displaylink-driver-6.1.0-17.run $out/lib/firmware/displaylink/
  #       '';
  #     });
  #   })
  # ];

  # Use the built-in NixOS functions for the rest, with minimal customization
  boot.extraModulePackages = with config.boot.kernelPackages; [evdi];
  boot.kernelModules = ["evdi"];

  # Ensure dlm service runs
  # systemd.services.dlm.wantedBy = [ "multi-user.target" ];

  # Hyprland configuration
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.default;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  # Environment variables for Wayland and DisplayLink
  environment.variables = {
    # Wayland/Electron variables
    NIXOS_OZONE_WL = "1";

    # DisplayLink variables for Wayland/Hyprland
    WLR_DRM_DEVICES = "/dev/dri/card1";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_EVDI_RENDER_DEVICE = "/dev/dri/card1";
  };

  # Input device configuration
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
    mouse.naturalScrolling = false;
  };
}
