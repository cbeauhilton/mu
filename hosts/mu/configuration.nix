# Host-specific configuration for mu (ThinkPad X1 Carbon)
{pkgs, ...}: {
  imports = [
    ../common.nix
    ./default.nix # mu-specific hardware/power settings
    ./display.nix
    ./hardware-configuration.nix
  ];

  # Host identity
  networking.hostName = "mu";
  time.timeZone = "America/Chicago";

  # Kernel - zen for desktop responsiveness
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # State version - when this host was initially installed
  system.stateVersion = "23.05";
}
