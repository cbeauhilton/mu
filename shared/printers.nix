{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = [pkgs.brlaser];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_MFC_L8900CDW";
        location = "Home Office";
        deviceUri = "ipp://BRN94DDF861A2A8.local/ipp/print";
        model = "everywhere";
      }
    ];
    ensureDefaultPrinter = "Brother_MFC_L8900CDW";
  };
}
