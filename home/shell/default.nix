{...}: {
  imports = [
    ./atuin
    ./ssh
    ./zsh
    ./yazi
  ];

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "firefox";
      TERMINAL = "ghostty";
      BAT_PAGER = "ov -F -H3";
      DELTA_PAGER = "ov --section-delimiter '^(commit|added:|removed:|renamed:|Δ)' --section-header --pattern '•'";
      MANPAGER = "ov";
      PSQL_PAGER = "ov -F -C -d '|' -H1 --column-rainbow";
    };
    shellAliases = {
      ivm = "vim";
      v = "vim";
      vim = "nvim";
      g = "git";
      mkdir = "mkdir -p";
    };
  };

  programs = {
    nh.enable = true;
    imv = {
      enable = true;
      settings = {};
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      config.global.warn_timeout = "0";
    };
  };
}
