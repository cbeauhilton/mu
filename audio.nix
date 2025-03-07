{ config, pkgs, ... }:

{
  # Enable sound with pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 1024; # Increased from default for stability
        "default.clock.min-quantum" = 1024;
        "default.clock.max-quantum" = 2048;
      };
    };
    # Specific USB device configuration
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/main.lua.d/99-usb-headset.lua" ''
        alsa_monitor.rules = {
          {
            matches = {{{ "node.name", "matches", "alsa_output.usb-DSEA_A_S_EPOS_IMPACT_860T*" }}};
            apply_properties = {
              ["audio.format"] = "S16LE",  # Your device uses 16-bit format
              ["audio.rate"] = 48000,      # Match system rate
              ["api.alsa.period-size"] = 1024,
              ["api.alsa.headroom"] = 256,
            },
          },
        }
      '')
    ];
  };

  # Bluetooth audio support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.package = pkgs.bluez;
  services.blueman.enable = true;
} 