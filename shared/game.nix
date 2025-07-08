{pkgs, ...}: {
  imports = [
  ];

  # Enable Steam for compatibility and runtime
  programs.steam = {
    enable = true;
    # remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Enable gaming tools
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamemode
        pkgs.gamescope
        pkgs.steam-run
      ];
    })
  ];

  users.users.beau = {
    extraGroups = ["gamemode"];
  };

  # Roblox
  systemd.services.flatpak-repo = {
    wantedBy = ["multi-user.target"];
    path = [pkgs.flatpak];
    script = ''flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo     '';
  };

  programs.gamemode.settings = {
    general = {
      # Disable screensaver inhibitor if you don't have a screensaver
      inhibit_screensaver = 0;
    };
  };
}
