# lazyvim-nix configuration
# Using github:pfassina/lazyvim-nix for declarative LazyVim
{
  inputs,
  pkgs,
  theme,
  ...
}: let
  # Build tree-sitter-datastar
  tree-sitter-datastar = pkgs.callPackage ./tree-sitter-datastar.nix {};

  # Colorscheme configuration based on theme
  isSelenized = builtins.hasAttr "variant" theme.nvim && theme.nvim.plugin == "selenized";
  isGruvbox = theme.nvim.plugin == "gruvbox";
in {
  imports = [inputs.lazyvim.homeManagerModules.default];

  # Install datastar tree-sitter parser and queries
  home.file = {
    ".local/share/nvim/tree-sitter-datastar/parser/datastar.so".source = "${tree-sitter-datastar}/parser/datastar.so";
    ".local/share/nvim/tree-sitter-datastar/queries/datastar".source = "${tree-sitter-datastar}/queries/datastar";
  };

  programs.lazyvim = {
    enable = true;

    # Core dependencies (LSPs, formatters, etc.)
    installCoreDependencies = true;

    # Custom options (runs before plugins load - don't set colorscheme here)
    config.options = ''
      vim.g.lazyvim_picker = "snacks"
      -- Disable diagnostics by default (toggle with <leader>ud)
      vim.diagnostic.enable(false)
      -- Colorscheme variant (matches terminal/stylix: ${theme.name})
      ${
        if theme.nvim.variant != null
        then ''vim.g.selenized_variant = "${theme.nvim.variant}"''
        else "-- no variant needed for ${theme.name}"
      }
    '';

    # Extra packages for tools not mapped by lazyvim-nix
    extraPackages = with pkgs; [
      vscode-langservers-extracted # jsonls, html, css, eslint
      templ # templ templating language
      tailwindcss-language-server # tailwindcss LSP
      emmet-language-server # emmet for html/templ
      nodePackages.prettier # formatter
    ];

    # Language extras (matching old config)
    extras = {
      lang = {
        typescript = {
          enable = true;
          installDependencies = true;
        };
        haskell.enable = true;
        nix = {
          enable = true;
          installDependencies = true;
        };
        git.enable = true;
        python = {
          enable = true;
          installDependencies = true;
        };
        json.enable = true;
        go = {
          enable = true;
          installDependencies = true;
        };
        rust = {
          enable = true;
          installDependencies = true;
        };
        markdown = {
          enable = true;
          installDependencies = true;
        };
        clangd = {
          enable = true;
          installDependencies = true;
        };
        tailwind.enable = true;
      };
      coding = {
        mini-surround.enable = true;
      };
    };

    # Custom plugins
    plugins = {
      # Colorscheme plugins - both included so switching is just a config change
      gruvbox = ''
        return {
          "ellisonleao/gruvbox.nvim",
          lazy = ${
          if isGruvbox
          then "false"
          else "true"
        },
          priority = 1000,
          opts = {
            contrast = "hard",
          },
          config = function(_, opts)
            require("gruvbox").setup(opts)
            vim.cmd.colorscheme("gruvbox")
          end,
        }
      '';

      selenized = ''
        return {
          "selenized.nvim",
          dir = "${pkgs.vimPlugins.selenized-nvim}",
          lazy = ${
          if isSelenized
          then "false"
          else "true"
        },
          priority = 1000,
          config = function()
            vim.cmd.colorscheme("selenized")
          end,
        }
      '';

      claudecode = ''
        return {
          "coder/claudecode.nvim",
          dependencies = { "folke/snacks.nvim" },
          config = true,
          keys = {
            { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
            { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
          },
        }
      '';

      # Datastar tree-sitter support (built via nix, no manual steps needed)
      datastar = ''
        return {
          {
            "nvim-treesitter/nvim-treesitter",
            init = function()
              -- Add nix-managed datastar parser
              local datastar_path = vim.fn.expand("~/.local/share/nvim/tree-sitter-datastar")
              if vim.fn.isdirectory(datastar_path) == 1 then
                vim.opt.runtimepath:append(datastar_path)
                local parser_file = datastar_path .. "/parser/datastar.so"
                if vim.fn.filereadable(parser_file) == 1 then
                  vim.treesitter.language.add("datastar", { path = parser_file })
                end
              end
            end,
          },
        }
      '';

      # Templ support with emmet and tailwindcss
      templ = ''
        return {
          -- Templ treesitter
          {
            "nvim-treesitter/nvim-treesitter",
            opts = function(_, opts)
              if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, { "templ" })
              end
            end,
          },
          -- Templ LSP
          {
            "neovim/nvim-lspconfig",
            opts = {
              servers = {
                templ = {},
                tailwindcss = {
                  filetypes_include = { "templ" },
                },
                html = {
                  filetypes = { "html", "templ" },
                },
                emmet_language_server = {
                  filetypes = { "html", "css", "templ" },
                },
                gopls = {
                  settings = {
                    gopls = {
                      buildFlags = { "-tags=dev" },
                    },
                  },
                },
              },
            },
          },
          -- Associate templ files
          {
            "joerdav/templ.vim",
            ft = "templ",
          },
        }
      '';

      # Disable inlay hints by default (toggle with <leader>uh)
      lsp-defaults = ''
        return {
          {
            "neovim/nvim-lspconfig",
            opts = {
              inlay_hints = { enabled = false },
            },
          },
        }
      '';
    };
  };
}
