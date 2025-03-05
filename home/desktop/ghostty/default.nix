{ config, pkgs, inputs, ... }:

{
  programs.ghostty = {
    enable = true;
    installVimSyntax = true;
    installBatSyntax = true;
    enableZshIntegration = true;
    settings = {
      # font-family = "JetBrains Mono";
      # font-size = 11;
      theme = "catppuccin-mocha";
      # keybind = [ 
      #   "ctrl+shift+c=copy"
      #   "ctrl+shift+v=paste"
      #   "ctrl+shift+n=new-window"
      #   "ctrl+shift+q=quit"
      # ];
    };
  };
}
