# Media and recording tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    ffmpeg
    wf-recorder
    wl-clipboard
  ];
}
