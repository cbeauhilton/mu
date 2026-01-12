{...}: {
  imports = [
    ./chrome.nix
    ./firefox.nix
  ];

  # programs.librewolf.enable = true;
  programs.qutebrowser.enable = true;
}
