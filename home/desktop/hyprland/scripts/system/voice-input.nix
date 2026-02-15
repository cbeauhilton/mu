{pkgs}:
pkgs.writeShellScriptBin "voice-input" ''
  PIDFILE="/tmp/voice-input.pid"
  WAVFILE="/tmp/voice-input.wav"
  MODEL_DIR="$HOME/.local/share/whisper-cpp"
  MODEL="$MODEL_DIR/ggml-small.bin"

  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    # Stop recording and transcribe
    kill "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    ${pkgs.libnotify}/bin/notify-send -t 2000 "Voice Input" "Transcribing..."

    text=$(${pkgs.whisper-cpp-vulkan}/bin/whisper-cli \
      -m "$MODEL" \
      -f "$WAVFILE" \
      -np -nt \
      --language en \
      2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;/^$/d' | tr '\n' ' ')

    rm -f "$WAVFILE"

    if [ -n "$text" ]; then
      ${pkgs.wtype}/bin/wtype -- "$text"
      ${pkgs.libnotify}/bin/notify-send -t 2000 "Voice Input" "Typed: ''${text:0:80}"
    else
      ${pkgs.libnotify}/bin/notify-send -t 2000 "Voice Input" "No speech detected"
    fi
  else
    # Download model on first use
    if [ ! -f "$MODEL" ]; then
      mkdir -p "$MODEL_DIR"
      ${pkgs.libnotify}/bin/notify-send "Voice Input" "Downloading model (one-time)..."
      ${pkgs.whisper-cpp-vulkan}/bin/whisper-cpp-download-ggml-model small "$MODEL_DIR"
    fi

    # Start recording
    ${pkgs.sox}/bin/rec -r 16000 -c 1 -b 16 "$WAVFILE" &
    echo $! > "$PIDFILE"
    ${pkgs.libnotify}/bin/notify-send -t 2000 "Voice Input" "Listening..."
  fi
''
