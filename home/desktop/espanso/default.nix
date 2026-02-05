{pkgs, ...}: {
  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
    matches = {
      pai = {
        matches = [
          {
            trigger = ".ho";
            replace = "Please use the /handoff skill to prepare for the next session.";
          }
        ];
      };
    };
  };
}
