# ESP32 Development Support
# Self-contained module for ESP32/ESP8266 flashing and development
# Can be removed without affecting anything else
{pkgs, ...}: {
  # Kernel modules for USB serial devices
  boot.kernelModules = [
    "cdc_acm" # ESP32-C6/S3 native USB CDC
    "cp210x" # Silicon Labs CP2102/CP2104
    "ch341" # CH340/CH341
    "ftdi_sio" # FTDI chips
  ];

  # udev rules for ESP devices
  services.udev.packages = [
    (pkgs.writeTextDir "etc/udev/rules.d/70-esp-dev.rules" ''
      # ESP32-C6/S3/H2 native USB JTAG/serial (Espressif VID)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", MODE:="0666", TAG+="uaccess"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", MODE:="0666", TAG+="uaccess", GROUP="dialout"

      # ESP32-S2 native USB (also 303a but different PIDs)
      # PID 1001 = USB JTAG/serial debug unit
      # PID 0002 = USB OTG
      SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE:="0666", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="0002", MODE:="0666", TAG+="uaccess"

      # Adafruit boards (VID 239a) - includes Feather boards
      SUBSYSTEM=="usb", ATTRS{idVendor}=="239a", MODE:="0666", TAG+="uaccess"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="239a", MODE:="0666", TAG+="uaccess", GROUP="dialout"

      # Silicon Labs CP210x USB to UART
      SUBSYSTEM=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE:="0666", TAG+="uaccess"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE:="0666", TAG+="uaccess", GROUP="dialout"

      # WCH CH340/CH341
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE:="0666", TAG+="uaccess"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE:="0666", TAG+="uaccess", GROUP="dialout"

      # FTDI FT232/FT2232
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", MODE:="0666", TAG+="uaccess"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", MODE:="0666", TAG+="uaccess", GROUP="dialout"
    '')
  ];

  # Ensure user is in required groups (you already have this in users.nix, but being explicit)
  users.users.beau.extraGroups = [
    "dialout"
    "tty"
    "uucp"
  ];

  # ESP development tools
  environment.systemPackages = with pkgs; [
    esptool # Flash ESP32/ESP8266
    minicom # Serial terminal
    screen # Alternative serial terminal
    picocom # Lightweight serial terminal
  ];

  environment.shellAliases = {
    esp-list = "ls -la /dev/ttyACM* /dev/ttyUSB* 2>/dev/null || echo 'No USB serial devices found'";
    esp-monitor = "picocom -b 115200";
  };
}
