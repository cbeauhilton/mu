{
  pkgs,
  inputs,
}: {
  startupScript = import ./system/startup.nix {inherit pkgs;};
  toggleLaptopScreen = import ./system/toggle-laptop-screen.nix {inherit pkgs;};
  screenRecordScript = import ./media/screen-record.nix {inherit pkgs;};
  screenshotAreaScript = import ./media/screenshot-area.nix {inherit pkgs inputs;};
  screenshotActiveScript = import ./media/screenshot-active.nix {inherit pkgs inputs;};
  screenshotOutputScript = import ./media/screenshot-output.nix {inherit pkgs inputs;};
}
