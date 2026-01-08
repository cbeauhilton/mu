{
  pkgs,
  config,
  lib,
  ...
}: {
  options.browsers.chrome-debug.enable =
    lib.mkEnableOption "Chrome with remote debugging for Claude";

  config = lib.mkIf config.browsers.chrome-debug.enable (let
    chrome-debug = pkgs.writeShellScriptBin "google-chrome-debug" ''
      exec ${pkgs.google-chrome}/bin/google-chrome-stable \
        --remote-debugging-port=9222 \
        --user-data-dir="$HOME/.chrome-debug" \
        "$@"
    '';
  in {
    home.packages = [chrome-debug];

    xdg.desktopEntries.google-chrome-debug = {
      name = "Google Chrome (Debug)";
      genericName = "Web Browser";
      comment = "Chrome with remote debugging enabled for Claude";
      exec = "${chrome-debug}/bin/google-chrome-debug %U";
      icon = "google-chrome";
      terminal = false;
      categories = ["Network" "WebBrowser"];
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/xml"
        "application/rss+xml"
        "application/rdf+xml"
      ];
    };
  });
}
