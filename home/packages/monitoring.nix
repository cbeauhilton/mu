# System monitoring tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    btop
    ethtool
    iftop
    iotop
    lm_sensors
    lsof
    ltrace
    pciutils
    strace
    sysstat
    usbutils
  ];
}
