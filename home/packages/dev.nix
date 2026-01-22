# Development tools for home-manager
{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    ansible
    ansible-lint
    python312Packages.ansible-vault-rw
    terraform-providers.nbering_ansible
    watchman
  ];
}
