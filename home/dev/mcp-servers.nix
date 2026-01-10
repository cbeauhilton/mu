{
  pkgs,
  lib,
  ...
}: let
  # MCP Server definitions
  # Each server can be enabled/disabled and configured here
  mcpServers = {
    # NixOS MCP - for querying NixOS options, packages, etc.
    nixos = {
      command = "nix";
      args = ["run" "github:utensils/mcp-nixos" "--"];
    };

    # NATS MCP - for interacting with NATS messaging
    # Requires: NATS_URL env var, and one of: NATS_NO_AUTHENTICATION=true, NATS_USER/NATS_PASSWORD
    nats = {
      command = "${pkgs.mcp-nats}/bin/mcp-nats";
      args = [];
      # Environment variables can be set here or via shell
      # env = {
      #   NATS_URL = "nats://localhost:4222";
      #   NATS_NO_AUTHENTICATION = "true";
      # };
    };
  };

  # Convert to JSON for merging into ~/.claude.json
  mcpServersJson = builtins.toJSON {inherit mcpServers;};
in {
  # Export for use in other modules
  _module.args.mcpServers = mcpServers;

  home.packages = with pkgs; [
    jq # Required for JSON manipulation in activation script
  ];

  # Activation script to merge mcpServers into ~/.claude.json
  home.activation.configureMcpServers = lib.hm.dag.entryAfter ["writeBoundary"] ''
    CLAUDE_CONFIG="$HOME/.claude.json"

    # Ensure the file exists with at least an empty object
    if [ ! -f "$CLAUDE_CONFIG" ]; then
      echo '{}' > "$CLAUDE_CONFIG"
    fi

    # Merge mcpServers into the existing config, preserving other settings
    ${pkgs.jq}/bin/jq --argjson servers '${mcpServersJson}' \
      '. * $servers' "$CLAUDE_CONFIG" > "$CLAUDE_CONFIG.tmp" \
      && mv "$CLAUDE_CONFIG.tmp" "$CLAUDE_CONFIG"

    chmod 600 "$CLAUDE_CONFIG"
  '';
}
