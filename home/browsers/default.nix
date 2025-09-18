{ ... }:
{
  imports = [
    ./firefox.nix
    ./zen.nix
  ];

  programs.chromium.enable = true;
  # programs.librewolf.enable = true;
  programs.qutebrowser.enable = true;
}
