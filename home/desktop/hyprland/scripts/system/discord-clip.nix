{pkgs}:
pkgs.writeShellScriptBin "discord-clip" ''
  INBOX="$HOME/.claude/knowledge/discord/datastar/inbox.md"
  mkdir -p "$(dirname "$INBOX")"
  echo -e "\n---\n**Clipped:** $(date '+%Y-%m-%d %H:%M')\n" >> "$INBOX"
  ${pkgs.wl-clipboard}/bin/wl-paste >> "$INBOX"
  ${pkgs.libnotify}/bin/notify-send -t 2000 "Clipped to knowledge base"
''
