{
  pkgs,
  inputs,
  monitors,
}: {
  startupScript = import ./system/startup.nix {inherit pkgs;};
  toggleLaptopScreen = import ./system/toggle-laptop-screen.nix {inherit pkgs monitors;};
  terminalHere = import ./system/terminal-here.nix {inherit pkgs;};
  screenRecordScript = import ./media/screen-record.nix {inherit pkgs;};
  screenshotAreaScript = import ./media/screenshot-area.nix {inherit pkgs inputs;};
  screenshotActiveScript = import ./media/screenshot-active.nix {inherit pkgs inputs;};
  screenshotOutputScript = import ./media/screenshot-output.nix {inherit pkgs inputs;};
  screenshotClaudeScript = import ./media/screenshot-claude.nix {inherit pkgs inputs;};
  volumeScript = import ./system/volume.nix {inherit pkgs;};
}
