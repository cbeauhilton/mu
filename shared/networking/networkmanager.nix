{
  config,
  pkgs,
  ...
}: {
  networking.networkmanager.enable = true;
  users.users.beau.extraGroups = ["networkmanager"];
  environment.systemPackages = with pkgs; [networkmanagerapplet];
}
