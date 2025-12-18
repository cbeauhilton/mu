return {
  -- Configure HTML and CSS LSP servers
  -- vscode-langservers-extracted provides both html-lsp and css-lsp
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {
          -- HTML language server from vscode-langservers-extracted
          filetypes = { "html", "htm" },
        },
        cssls = {
          -- CSS language server from vscode-langservers-extracted
          filetypes = { "css", "scss", "less" },
        },
      },
    },
  },
}

