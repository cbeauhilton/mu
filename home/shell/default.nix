{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./atuin
    #./bat
    #./direnv
    #./lf
    #./newsboat
    #./ov
    # ./starship
    #./terminals
    ./ssh
    ./zsh
    ./yazi
  ];

  home.packages = with pkgs; [
    # imv
    alejandra
    bc
    delta
    fd
    ncdu
    nil
    ov
    pavucontrol
    ripgrep
    xdragon
    ansible
    ansible-lint
    terraform-providers.ansible
    ansible-language-server
    python312Packages.ansible-vault-rw
    whois
  ];

  home.sessionVariables = {
    # XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "ghostty";
    BAT_PAGER = "ov -F -H3";
    DELTA_PAGER = "ov --section-delimiter '^(commit|added:|removed:|renamed:|Δ)' --section-header --pattern '•'";
    MANPAGER = "ov";
    PSQL_PAGER = "ov -F -C -d '|' -H1 --column-rainbow";
  };

  home.shellAliases = {
    ivm = "vim";
    v = "vim";
    vim = "nvim";
    g = "git";
    mkdir = "mkdir -p";
  };
  programs.imv = {
    enable = true;
    settings = {};
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    config = {
      global.warn_timeout = "0";
    };
  };
}
