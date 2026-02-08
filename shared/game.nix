{
  pkgs,
  lib,
  config,
  ...
}: {
  options.custom.gaming.enable = lib.mkEnableOption "gaming packages and configuration";

  config = lib.mkIf config.custom.gaming.enable {
    programs = {
      steam.enable = true;
      gamescope.enable = true;
      gamemode = {
        enable = true;
        settings.general.inhibit_screensaver = 0;
      };
    };

    environment.systemPackages = with pkgs; [
      (heroic.override {
        extraPkgs = pkgs: [
          pkgs.gamemode
          pkgs.gamescope
          pkgs.steam-run
        ];
      })
    ];

    users.users.beau.extraGroups = ["gamemode"];

    # Roblox flatpak repo
    systemd.services.flatpak-repo = {
      wantedBy = ["multi-user.target"];
      path = [pkgs.flatpak];
      script = "flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
    };
  };
}
