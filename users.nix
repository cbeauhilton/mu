{
  ...
}: let
  username = "beau";
in {

users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = ["docker" "networkmanager" "wheel" "audio" "pipewire" "libvirtd"];
  };

  # Enable automatic login for the user.
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "${username}";
    };
  };

}
