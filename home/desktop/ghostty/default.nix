{ config, pkgs, inputs, ... }:

{
  # Your existing home-manager configuration...
  
  # Enable Ghostty with Home Manager
  programs.ghostty = {
    enable = true;
    installVimSyntax = true;
    installBatSyntax = true;
    enableZshIntegration = true;
    
    settings = {
      # Example settings - customize these to your preferences
      # font-family = "JetBrains Mono";
      # font-size = 11;
      
      # Theme settings
      background = "#282c34";
      foreground = "#abb2bf";
      
      # Window settings
      window-padding-x = 10;
      window-padding-y = 10;
      confirm-close = false;
    };
    
    # Optional: Configure keybindings
    keybindings = {
      "ctrl+shift+c" = "copy";
      "ctrl+shift+v" = "paste";
      "ctrl+shift+n" = "new-window";
      "ctrl+shift+q" = "quit";
    };
  };
}
