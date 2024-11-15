{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    defaultKeymap = "viins";
    history.save = 99999;
    shellAliases = {
      l = "eza";
      ls = "eza -lgh --group-directories-first --color always --icons --classify --time-style relative --created --changed --git-repos-no-status";
      tree = "eza --tree -alh --group-directories-first --color always --icons ";
      grep = "grep --color --ignore-case --line-number --context=3 ";
      g = "git";
      sgp = "sudo git push";
      gc = "git commit -m";
    };
    envExtra = ''
      export EDITOR="nvim"
      export VISUAL="nvim"
      export PAGER="ov"
      export OPENER="xdg-open"
      export TERMINAL="alacritty"
      export XCURSOR_THEME="Adwaita"
    '';
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.4.0";
          sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
        };
      }
    ];
  };
}
