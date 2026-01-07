{...}: {
  imports = [
    ./firefox.nix
    # ./zen.nix
  ];

  # programs.librewolf.enable = true;
  programs.qutebrowser.enable = true;
}
