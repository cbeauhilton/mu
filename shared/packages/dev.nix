# Development tools
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bun
    devenv
    docker
    docker-compose
    gcc # C compiler for nvim-treesitter
    go
    golangci-lint
    golangci-lint-langserver
    gotools
    go-task
    lazydocker
    libgcc
    natscli
    nats-top
    neovim
    nodejs # Required for pnpm/npm packages (MCP servers, etc)
    openssl
    pnpm
    postgresql
    rustup
    sqlite
    sqlite-interactive
    templ
    tenv
    terraform
    tree-sitter # CLI for nvim-treesitter
    uv
    zig
  ];
}
