{
  config,
  pkgs,
  ...
}: {
  networking.wireless.iwd.enable = true;
  environment.systemPackages = with pkgs; [impala];

  sops.secrets.aon_lan_password = {};

  sops.templates."AON-LAN.8021x" = {
    content = ''
      [Security]
      EAP-Method=PEAP
      EAP-Identity=anonymous
      EAP-PEAP-Phase2-Method=MSCHAPV2
      EAP-PEAP-Phase2-Identity=beau.hilton
      EAP-PEAP-Phase2-Password=${config.sops.placeholder.aon_lan_password}

      [Settings]
      AutoConnect=true
    '';
    path = "/var/lib/iwd/AON-LAN.8021x";
    mode = "0600";
  };
}
