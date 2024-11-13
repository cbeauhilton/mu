{
  pkgs,
  lib,
  inputs,
  ...
}: let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.waybar}/bin/waybar &
    ${pkgs.swww}/bin/swww init &
    sleep 1
    ${pkgs.swww}/bin/swww img ${./wallpaper.jpeg} &
    ${pkgs.mako}/bin/mako &
    xremap --watch .config/xremap/config.yml &
  '';
in {
  # imports = [
  #   ../waybar
  # ];

  home.packages = with pkgs; [
    wl-clipboard
    grim
    slurp
    inputs.hyprland-contrib.packages.x86_64-linux.grimblast
    neofetch
    wofi-emoji
  ];

  programs.wofi = {
    enable = true;
    settings = {
      image_size = 48;
      columns = 3;
      allow_images = true;
      insensitive = true;
      run-always_parse_args = true;
      run-cache_file = "/dev/null";
      run-exec_search = true;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    plugins = [
      inputs.hyprsplit.packages.${pkgs.system}.hyprsplit
    ];
    xwayland.enable = true;
    settings = {
      exec-once = ''${startupScript}/bin/start'';
      input = {
        follow_mouse = 1;
      };
      monitor = [
        "DP-3,preferred,0x0,1,transform,1"
        "HDMI-A-1,preferred,1080x0,1"
      ];
      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "rgb(587744) rgb(128C21) 45deg";
        "col.inactive_border" = "rgba(585272aa)";
        layout = "master";
        resize_on_border = true;
      };
      decoration = {
        rounding = "10";
        # blur = [
        #   "enabled = true"
        # ];
        # "blur.size" = 3;
        # "blur.passes" = 1;
        # "blur.new_optimizations" = true;
        # drop_shadow = true;
        # shadow_range = 4;
        # shadow_render_power = 3;
        # "col.shadow" = "rgba(1a1a1aee)";
        active_opacity = 1.0;
        inactive_opacity = 0.9;
      };
      master = {
        new_status = "master";
        orientation = "left";
        # no_gaps_when_only = 1;
      };
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
      xwayland = {
        force_zero_scaling = true;
      };
      env = [
        "GDK_SCALE,2"
        "XCURSOR_SIZE,24"
      ];
      animations = {
        enabled = true;
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];
        animation = [
          "windows, 1, 6, wind, popin"
          "windowsIn, 1, 6, winIn, popin"
          "windowsOut, 1, 5, winOut, popin"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 30, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind, slidevert"
        ];
      };

      "$mainMod" = "SUPER";
      bind = [
        "$mainMod, return, exec, alacritty"
        "$mainMod, w, exec, firefox"
        "$mainMod, q, killactive,"
        "$mainMod SHIFT, q, exit,"
        "$mainMod, f, fullscreen, 1"
        "$mainMod SHIFT, f, fullscreen, 0"
        "$mainMod, d, exec, rofi -show drun"
        "$mainMod, r, exec, wezterm-gui start --always-new-process yazi"
        "$mainMod SHIFT, r, exec, thunar"
        "$mainMod, m, exec, wezterm-gui start --always-new-process ncmpcpp"
        "$mainMod, t, togglefloating,"
        "$mainMod CTRL, t, togglespecialworkspace, term"
        "$mainMod, Home, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        # grimblast's "copysave" both saves a file in the home directory and copies to clipboard
        "$mainMod SHIFT, c, exec, grimblast copysave area"
        "$mainMod SHIFT, x, exec, grimblast copysave active"
        "$mainMod SHIFT, z, exec, grimblast copysave output"

        # DWM-style focus movement (only prev and next, no left and right)
        "$mainMod, k, layoutmsg, cycleprev"
        "$mainMod, j, layoutmsg, cyclenext"

        # Swap window with mainMod + shift + vim keys
        "$mainMod SHIFT, k, layoutmsg, swapprev"
        "$mainMod SHIFT, j, layoutmsg, swapnext"
        "$mainMod SHIFT, h, swapwindow, l"
        "$mainMod SHIFT, l, swapwindow, r"
        "$mainMod SHIFT, u, layoutmsg, orientationcycle left top"

        # Grab rogue windows (e.g. after unplugging monitor)
        "$mainMod, G, split:grabroguewindows"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, split:workspace, 1"
        "$mainMod, 2, split:workspace, 2"
        "$mainMod, 3, split:workspace, 3"
        "$mainMod, 4, split:workspace, 4"
        "$mainMod, 5, split:workspace, 5"
        "$mainMod, 6, split:workspace, 6"
        "$mainMod, 7, split:workspace, 7"
        "$mainMod, 8, split:workspace, 8"
        "$mainMod, 9, split:workspace, 9"
        "$mainMod, 0, split:workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        # "movetoworkspacesilent" means "don't autoswitch to the workspace you just moved the active window to"
        "$mainMod SHIFT, 1, split:movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, split:movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, split:movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, split:movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, split:movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, split:movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, split:movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, split:movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, split:movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, split:movetoworkspacesilent, 10"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, split:workspace, e+1"
        "$mainMod, mouse_up, split:workspace, e-1"

        # focus monitor
        "$mainMod, bracketleft, focusmonitor, -1"
        "$mainMod, bracketright, focusmonitor, +1"

        # move window to monitor
        "$mainMod SHIFT, bracketleft, movewindow, mon:-1"
        "$mainMod SHIFT, bracketright, movewindow, mon:+1"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      binde = [
        # Resize left and right with mainMod + hl
        # Resize up and down with mainMod + arrow keys
        "$mainMod, l, resizeactive, 20 0"
        "$mainMod, h, resizeactive, -20 0"
        "$mainMod, up, resizeactive, 0 -20"
        "$mainMod, down, resizeactive, 0 20"
        "$mainMod, Page_Up, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        "$mainMod, Page_Down, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];
    };
  };
}
