{
  pkgs,
  config,
  inputs,
  ...
}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        # i-dont-care-about-cookies # ninja-cookie is better?
        # noscript
        # torrent-control # sends links to torrent client, idk if I actually want this
        aria2-integration
        bitwarden
        clearurls
        dark-mode-website-switcher
        darkreader
        decentraleyes
        linkding-extension
        ninja-cookie # auto-declines non-essential cookies
        privacy-badger
        rsshub-radar
        stylus
        theater-mode-for-youtube
        ublock-origin
        vimium-c
        violentmonkey
        youtube-recommended-videos
      ];
      settings = {
        "browser.aboutConfig.showWarning" = false; # silences about:config's warning page
        "browser.download.useDownloadDir" = true; # don't ask where to save stuff, just download it to the last selected folder
        "browser.newtab.preload" = false;
        "browser.newtabpage.activity-stream.default.sites" = "";
        "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = true;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.sessionstore.resume_from_crash" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "identity.fxaccounts.enabled" = false;
        "services.sync.prefs.sync-seen.browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "signon.rememberSignons" = false; # prefer BitWarden
        "trailhead.firstrun.didSeeAboutWelcome" = true;
      };
    };
  };
  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
