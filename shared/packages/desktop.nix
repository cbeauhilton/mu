# Desktop applications
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    anki
    bitwarden-cli
    bitwarden-desktop
    bluetui # TUI for bluetooth
    google-chrome
    junction # use as default browser to add selection
    mpv
    systemctl-tui
    teams-for-linux
    trippy # traceroute + ping, pretty
    visidata # vd - terminal data multitool
    vlc
  ];
}
