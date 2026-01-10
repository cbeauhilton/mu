# Overlay aggregator - collects all overlays for nixpkgs
{inputs}: [
  inputs.claude-code.overlays.default
  inputs.nur.overlays.default
  (import ./mcp-nats.nix)
]
