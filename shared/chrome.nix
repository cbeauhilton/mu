_: let
  # Extensions to install (ID;update_url format for force install)
  chromeExtensions = [
    "fcoeoabgfenejglbffodgkkbkcdhcgfn" # Claude in Chrome
    "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
  ];

  # Convert to ExtensionInstallForcelist format
  extensionForcelist = map (id: "${id};https://clients2.google.com/service/update2/crx") chromeExtensions;

  # Chrome policy JSON
  chromePolicy = {
    ExtensionInstallForcelist = extensionForcelist;
  };
in {
  # Chromium policies (for Chromium browser)
  programs.chromium = {
    enable = true;
    extensions = chromeExtensions;
  };

  # Google Chrome policies (separate from Chromium)
  environment.etc."opt/chrome/policies/managed/extensions.json" = {
    text = builtins.toJSON chromePolicy;
    mode = "0644";
  };
}
