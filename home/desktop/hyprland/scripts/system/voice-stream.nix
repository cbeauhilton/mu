{pkgs}:
pkgs.writeShellScriptBin "voice-stream" ''
  LOCKFILE="/tmp/voice-stream.lock"
  LOOP_PID="/tmp/voice-stream-loop.pid"
  CHUNK="/tmp/voice-stream-chunk.wav"
  MODEL_DIR="$HOME/.local/share/whisper-cpp"
  MODEL="$MODEL_DIR/ggml-small.bin"
  CHUNK_SEC=4

  if [ -f "$LOCKFILE" ]; then
    # Stop streaming — kill entire process tree first to prevent
    # any in-flight wtype from firing while SUPER is still held
    rm -f "$LOCKFILE"
    if [ -f "$LOOP_PID" ]; then
      loop=$(cat "$LOOP_PID")
      pkill -TERM -P "$loop" 2>/dev/null
      kill "$loop" 2>/dev/null
      rm -f "$LOOP_PID"
    fi
    rm -f "$CHUNK"
    ${pkgs.libnotify}/bin/notify-send -t 2000 "Voice Stream" "Stopped"
  else
    # Download model on first use
    if [ ! -f "$MODEL" ]; then
      mkdir -p "$MODEL_DIR"
      ${pkgs.libnotify}/bin/notify-send "Voice Stream" "Downloading model (one-time)..."
      ${pkgs.whisper-cpp-vulkan}/bin/whisper-cpp-download-ggml-model small "$MODEL_DIR"
    fi

    touch "$LOCKFILE"
    ${pkgs.libnotify}/bin/notify-send -t 2000 "Voice Stream" "Streaming..."

    (
      while [ -f "$LOCKFILE" ]; do
        ${pkgs.sox}/bin/rec -r 16000 -c 1 -b 16 "$CHUNK" trim 0 "$CHUNK_SEC" 2>/dev/null
        [ -f "$LOCKFILE" ] || break

        text=$(${pkgs.whisper-cpp-vulkan}/bin/whisper-cli \
          -m "$MODEL" \
          -f "$CHUNK" \
          -np -nt \
          --language en \
          2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;/^$/d' | tr '\n' ' ')

        rm -f "$CHUNK"

        if [ -n "$text" ] && [ -f "$LOCKFILE" ]; then
          # Clipboard paste avoids modifier key interference with keybinds.
          # Ctrl+Shift+V works in both terminals and GUI apps.
          ${pkgs.wl-clipboard}/bin/wl-copy -- "$text "
          sleep 0.15
          ${pkgs.wtype}/bin/wtype -M ctrl -M shift v -m shift -m ctrl
        fi
      done
    ) &
    echo $! > "$LOOP_PID"
  fi
''
