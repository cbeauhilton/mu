return {
  -- Configure Python LSP (pyrefly) - NixOS-native setup
  -- pyrefly is installed via NixOS packages in home.nix
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyrefly = {
          -- Explicitly use system-installed pyrefly (from NixOS)
          -- This ensures it works properly in NixOS without Mason
          cmd = { "pyrefly", "lsp" },
          -- Pyrefly settings (pyrefly uses pyproject.toml or pyrefly.toml for configuration)
          settings = {},
        },
      },
    },
  },
}

