_: let
  # Toggle between iwd and NetworkManager for wireless management
  useIwd = true; # Set to false to use NetworkManager instead
in {
  imports = [
    (
      if useIwd
      then ../../shared/networking/iwd.nix
      else ../../shared/networking/networkmanager.nix
    )
    # ../../shared/printers.nix
  ];

  boot.kernelParams = [
    "pcie_ports=compat"
    "pcie_port_pm=off"
    "pcie_aspm.policy=performance"
    "pci=nocrs"
    "amd_iommu=on"
    "iommu=pt"
  ];

  powerManagement.powertop.enable = true;

  services = {
    hardware.bolt.enable = true; # thunderbolt/usb-c 4 compatibility
    system76-scheduler.settings.cfsProfiles.enable = true; # Better CPU scheduling
    power-profiles-daemon.enable = false; # Disable GNOME power management
    tlp = {
      enable = true;
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 81;
      };
    };
  };
}
