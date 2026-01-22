{
  pkgs,
  inputs,
}:
pkgs.writeShellScriptBin "screenshot-claude" ''
  set -euo pipefail

  SCREENSHOT_DIR="/home/beau/src/.screenshots"
  mkdir -p "$SCREENSHOT_DIR"

  timestamp() {
    ${pkgs.coreutils}/bin/date +"%Y%m%d-%H%M%S"
  }

  cmd_info() {
    echo "=== Monitors ==="
    ${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | "  \(.name): \(.width)x\(.height) @ \(.x),\(.y) | workspace \(.activeWorkspace.name) | focused=\(.focused)"'

    echo ""
    echo "=== Workspaces ==="
    ${pkgs.hyprland}/bin/hyprctl workspaces -j | ${pkgs.jq}/bin/jq -r '.[] | "  [\(.name)] on \(.monitor) - \(.windows) windows"'

    echo ""
    echo "=== Windows ==="
    ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | "  [\(.workspace.name)] \(.class): \(.title)"'
  }

  cmd_monitor() {
    local monitor="''${1:-}"
    if [[ -z "$monitor" ]]; then
      monitor=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name')
    fi

    local filename="$SCREENSHOT_DIR/$(timestamp)-$monitor.png"
    ${pkgs.grim}/bin/grim -o "$monitor" "$filename"
    echo "$filename"
  }

  cmd_window() {
    local pattern="''${1:-}"
    if [[ -z "$pattern" ]]; then
      echo "Error: window pattern required" >&2
      exit 1
    fi

    local addr
    addr=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r --arg p "$pattern" '.[] | select(.title | test($p; "i")) | .address' | head -1)

    if [[ -z "$addr" ]]; then
      echo "Error: no window matching '$pattern'" >&2
      exit 1
    fi

    ${pkgs.hyprland}/bin/hyprctl dispatch focuswindow "address:$addr" >/dev/null
    sleep 0.2

    local title
    title=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r --arg a "$addr" '.[] | select(.address == $a) | .title' | head -c 30 | tr ' /:' '___')

    local filename="$SCREENSHOT_DIR/$(timestamp)-$title.png"
    ${inputs.hyprland-contrib.packages.x86_64-linux.grimblast}/bin/grimblast save active "$filename" 2>/dev/null
    echo "$filename"
  }

  cmd_all() {
    local filename="$SCREENSHOT_DIR/$(timestamp)-all.png"
    ${pkgs.grim}/bin/grim "$filename"
    echo "$filename"
  }

  cmd_active() {
    local filename="$SCREENSHOT_DIR/$(timestamp)-active.png"
    ${inputs.hyprland-contrib.packages.x86_64-linux.grimblast}/bin/grimblast save active "$filename" 2>/dev/null
    echo "$filename"
  }

  cmd_workspace() {
    local ws="''${1:-}"
    if [[ -z "$ws" ]]; then
      echo "Error: workspace number required" >&2
      exit 1
    fi

    local current_ws
    current_ws=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .activeWorkspace.name')

    ${pkgs.hyprland}/bin/hyprctl dispatch workspace "$ws" >/dev/null
    sleep 0.3

    local filename="$SCREENSHOT_DIR/$(timestamp)-ws$ws.png"
    ${pkgs.grim}/bin/grim -o "$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name')" "$filename"

    ${pkgs.hyprland}/bin/hyprctl dispatch workspace "$current_ws" >/dev/null

    echo "$filename"
  }

  cmd_help() {
    cat <<EOF
  screenshot-claude - Hyprland screenshot tool for Claude

  Commands:
    info                    Show monitors, workspaces, and windows
    monitor [NAME]          Capture monitor (default: focused)
    window PATTERN          Focus and capture window by title pattern
    workspace N             Switch to workspace N, capture, switch back
    active                  Capture currently active window
    all                     Capture all monitors stitched together

  Screenshots saved to: $SCREENSHOT_DIR
  EOF
  }

  case "''${1:-help}" in
    info) cmd_info ;;
    monitor) cmd_monitor "''${2:-}" ;;
    window) cmd_window "''${2:-}" ;;
    workspace) cmd_workspace "''${2:-}" ;;
    active) cmd_active ;;
    all) cmd_all ;;
    help|--help|-h) cmd_help ;;
    *) echo "Unknown command: $1" >&2; cmd_help; exit 1 ;;
  esac
''
