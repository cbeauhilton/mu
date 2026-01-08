{pkgs, ...}: {
  services.udev.packages = [
    (pkgs.writeTextDir "etc/udev/rules.d/70-meshtastic.rules" ''
      # Seeed T1000E
      SUBSYSTEM=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="8029", MODE:="0666", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="0029", MODE:="0666", TAG+="uaccess"
    '')
    (pkgs.writeTextDir "lib/udev/rules.d/70-stm32-dfu.rules" ''
      # DFU (Internal bootloader for STM32 and AT32 MCUs)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", ATTRS{idProduct}=="df11", MODE:="0666", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", TAG+="uaccess"
    '')
  ];

  users.users.beau.extraGroups = [
    "dialout"
    "tty"
    "uucp"
  ];

  environment.systemPackages = with pkgs; [
    python313Packages.meshtastic
    esptool
    adafruit-nrfutil
  ];

  environment.shellAliases = {
    meshtastic-info = "meshtastic --info";
    list-serial = "ls -la /dev/tty*";
  };

  # adafruit-nrfutil --verbose dfu serial --package ~/dl/firmware-tracker-t1000-e-2.6.11.60ec05e-ota.zip -p /dev/ttyACM4 -b 115200 --singlebank --touch 1200

  # what finally worked:
  # go to meshtastic website and download the firmware zip (includes all possible firmware)
  # unzip that, find the t1000e zip within it
  # then make sure I knew which ACM* the thing was connected to
  # and run that command
}
