# Compression and archive tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    p7zip
    unzip
    xz
    zip
  ];
}
