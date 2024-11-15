{
  config,
  pkgs,
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
    bc
    imv
    pavucontrol
    delta
    ncdu
    ripgrep
    fd
    nil
    alejandra
    xdragon
  ];

  home.sessionVariables = {
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
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
}
