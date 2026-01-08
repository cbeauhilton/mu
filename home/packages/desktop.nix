# Desktop applications and tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    arandr
    clipse
    code-cursor
    discord-ptb
    dragon-drop
    graphviz
    kdePackages.dolphin
    libnotify
    pavucontrol
    showmethekey
    sqlitebrowser
    zotero
  ];
}
