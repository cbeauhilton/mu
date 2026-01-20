{pkgs}:
pkgs.writeShellScriptBin "terminal-here" ''
  # Get PID of the focused window
  pid=$(${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.pid')

  if [ -z "$pid" ] || [ "$pid" = "null" ]; then
    ${pkgs.foot}/bin/footclient
    exit 0
  fi

  # Find child shell process (zsh, bash, fish, etc.)
  shell_pid=$(${pkgs.procps}/bin/pgrep -P "$pid" -x "zsh|bash|fish" | head -1)

  if [ -n "$shell_pid" ]; then
    cwd=$(readlink -f "/proc/$shell_pid/cwd" 2>/dev/null)
    if [ -n "$cwd" ] && [ -d "$cwd" ]; then
      ${pkgs.foot}/bin/footclient -D "$cwd"
      exit 0
    fi
  fi

  # Fallback: try the window's own cwd
  cwd=$(readlink -f "/proc/$pid/cwd" 2>/dev/null)
  if [ -n "$cwd" ] && [ -d "$cwd" ]; then
    ${pkgs.foot}/bin/footclient -D "$cwd"
  else
    ${pkgs.foot}/bin/footclient
  fi
''
