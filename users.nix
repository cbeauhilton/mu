{pkgs, ...}: let
  username = "beau";
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  session = "${pkgs.hyprland}/bin/Hyprland";
in {
  users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = ["docker" "networkmanager" "wheel" "audio" "pipewire" "libvirtd"];
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${tuigreet} --greeting '' --asterisks --remember --remember-user-session --time --cmd ${session}";
        user = "greeter";
      };
    };
  };
}
