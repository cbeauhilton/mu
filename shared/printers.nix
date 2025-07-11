{
  config,
  pkgs,
  ...
}: {
  # Enable printing
  services.printing.enable = true;

  # Enable network discovery of printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Your printer
  hardware.printers = {
    ensurePrinters = [
      {
        name = "HP_OfficeJet_Pro_9010";
        location = "Home Office";
        deviceUri = "ipp://192.168.1.88/ipp/print";
        model = "everywhere";
      }
    ];
    ensureDefaultPrinter = "HP_OfficeJet_Pro_9010";
  };
}
