{
  config,
  pkgs,
  ...
}: {
  # Neovim program configuration
  programs.neovim = {
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  # Neovim-related packages
  home.packages = with pkgs; [
    # LSP servers (NixOS-native, no Mason needed)
    pyrefly # Python LSP server
    gopls # Go LSP server
    rust-analyzer # Rust LSP server
    vscode-langservers-extracted # HTML, CSS, JSON LSP servers (includes vscode-html-language-server, vscode-css-language-server)
    # Note: nil (Nix LSP) is handled by LazyVim's lang.nix extra
    # Note: TypeScript/JavaScript is handled by LazyVim's lang.typescript extra

    # Treesitter parsers (NixOS-native)
    vimPlugins.nvim-treesitter-parsers.templ # Templ treesitter parser

    # LazyVim markdown extra dependencies
    markdownlint-cli2 # markdown linter for LazyVim markdown extra
    markdown-toc # markdown table of contents generator for LazyVim markdown extra
  ];
}
