{config, ...}: {
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
      TERMINAL =
        if config.custom.ghostty.enable
        then "ghostty"
        else "foot";
      BAT_PAGER = "ov -F -H3";
      DELTA_PAGER = "ov --section-delimiter '^(commit|added:|removed:|renamed:|Δ)' --section-header --pattern '•'";
      MANPAGER = "ov";
      PSQL_PAGER = "ov -F -C -d '|' -H1 --column-rainbow";

      # Keep apps from polluting ~
      GOPATH = "$HOME/.local/share/go";
      GOMODCACHE = "$HOME/.cache/go-mod";
      PPROF_TMPDIR = "$HOME/.cache/pprof";
      PEX_ROOT = "$HOME/.cache/pex";
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

  # Home directory cleanup
  systemd.user.services.clean-home = {
    Unit.Description = "Clean home directory - move unlisted items to exhaust";
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.local/bin/clean_home --force --verbose";
    };
  };

  systemd.user.timers.clean-home = {
    Unit.Description = "Weekly home directory cleanup";
    Timer = {
      OnCalendar = "Sun *-*-* 10:00:00";
      Persistent = true;
    };
    Install.WantedBy = ["timers.target"];
  };
}
