return {
  -- Configure nvim-lspconfig general options
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Disable inline hints by default
      inlay_hints = {
        enabled = false,
      },
    },
  },
}

