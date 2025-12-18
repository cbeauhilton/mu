return {
  -- Mason is disabled - using NixOS-native LSP servers instead
  -- pyrefly is installed via NixOS packages (see home.nix)
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "mason-org/mason.nvim", enabled = false },
}
