# Overlay aggregator - collects all overlays for nixpkgs
{inputs}: [
  inputs.claude-code.overlays.default
  inputs.nur.overlays.default
  (final: _prev: {serena = inputs.serena.packages.${final.system}.default;})
  (import ./mcp-nats.nix)
  (import ./selenized-nvim.nix)
]
