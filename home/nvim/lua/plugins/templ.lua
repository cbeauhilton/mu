return {
  -- Add templ treesitter parser for syntax highlighting
  -- The parser is provided by NixOS package: vimPlugins.nvim-treesitter-parsers.templ
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      -- Set filetype for .templ files
      vim.filetype.add({
        extension = {
          templ = "templ",
        },
      })

      -- Configure templ parser after treesitter is available
      -- The parser is provided by NixOS, but we need to configure it for nvim-treesitter
      -- See: https://github.com/vrischmann/tree-sitter-templ
      vim.defer_fn(function()
        local ok, parsers = pcall(require, "nvim-treesitter.parsers")
        if ok and parsers.get_parser_configs then
          local parser_config = parsers.get_parser_configs()
          parser_config.templ = {
            install_info = {
              url = "https://github.com/vrischmann/tree-sitter-templ",
              files = { "src/parser.c", "src/scanner.c" },
              branch = "main",
            },
            filetype = "templ",
          }
        end
      end, 100)
    end,
    opts = function(_, opts)
      -- Add templ to ensure_installed
      -- Note: The parser is provided by Nix, but we still need to tell treesitter about it
      vim.list_extend(opts.ensure_installed, {
        "templ",
      })
    end,
  },

  -- Configure templ LSP server
  -- templ is installed via NixOS packages in shared/packages/default.nix
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        templ = {
          -- Explicitly use system-installed templ (from NixOS)
          cmd = { "templ", "lsp" },
          filetypes = { "templ" },
          root_dir = require("lspconfig.util").root_pattern("go.mod", ".git"),
          settings = {},
        },
      },
    },
  },
}

