{pkgs}:
pkgs.writeShellScriptBin "volume" ''
  ACTION=$1

  # Get all audio sink IDs from the Sinks section of wpctl status
  SINKS=$(${pkgs.wireplumber}/bin/wpctl status | \
    ${pkgs.gawk}/bin/awk '
      /Sinks:/ { in_sinks=1; next }
      /Sources:|Filters:/ { in_sinks=0 }
      in_sinks && /\[vol:/ {
        for (i=1; i<=NF; i++) {
          if ($i ~ /^[0-9]+\.$/) {
            sub(/\.$/, "", $i)
            print $i
          }
        }
      }
    ')

  case "$ACTION" in
    raise)
      for sink in $SINKS; do
        ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 "$sink" 5%+
      done
      ;;
    lower)
      for sink in $SINKS; do
        ${pkgs.wireplumber}/bin/wpctl set-volume "$sink" 5%-
      done
      ;;
    mute)
      for sink in $SINKS; do
        ${pkgs.wireplumber}/bin/wpctl set-mute "$sink" toggle
      done
      ;;
  esac
''
