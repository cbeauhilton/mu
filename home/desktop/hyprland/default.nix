{
  pkgs,
  inputs,
  monitors,
  monitorsLib,
  ...
}: let
  scripts = import ./scripts {inherit pkgs inputs monitors;};
  terminal = "foot";
  browser = "firefox";
in {
  home.packages = with pkgs; [
    wl-clipboard
    grim
    slurp
    brightnessctl
    inputs.hyprland-contrib.packages.x86_64-linux.grimblast
    neofetch
    waypaper
    wdisplays
    swaybg # waypaper needs a backend, swaybg seems to work the best
    pipes # terminal screensaver. For fun.
    asciiquarium-transparent # another
    jq # for the toggleLaptopScreen script, just in case it's not already installed
    scripts.screenshotClaudeScript # screenshot tool for Claude
  ];

  # make stuff work on wayland
  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  services.mako = {
    enable = true;
  };
  services.hypridle = {
    enable = true;
    settings = {
      listener = [
        {
          timeout = 120;
          on-timeout = "hyprctl dispatch dpms off"; # just turns off the screen - save the OLED
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    plugins = [
      inputs.hyprsplit.packages.${pkgs.system}.hyprsplit
      inputs.hyprgrass.packages.${pkgs.system}.default
    ];
    settings = {
      exec-once = ''${scripts.startupScript}/bin/start'';
      input = {
        follow_mouse = 1;
        natural_scroll = false;
        touchpad.natural_scroll = true;
      };
      # Monitor config from lib/monitors.nix - run `hyprctl monitors all` to see descriptions
      monitor = monitorsLib.toHyprlandConfig monitors;
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
        active_opacity = 1.0;
        inactive_opacity = 0.9;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          new_optimizations = true;
        };
        shadow = {
          enabled = false; # default: true
          range = 4; # default: 4
          render_power = 3; # default: 3
          color = "rgba(1a1a1aee)";
        };
      };
      master = {
        new_status = "master";
        orientation = "left";
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

      workspace = [
        "w[t1], gapsout:0, gapsin:0"
        "w[tg1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
      ];

      windowrule = [
        # Rules for tiled workspaces (w[t1])
        "border_size 0, match:workspace w[t1], match:float 0"
        "rounding 0, match:workspace w[t1], match:float 0"

        # Rules for tiled group workspaces (w[tg1])
        "border_size 0, match:workspace w[tg1], match:float 0"
        "rounding 0, match:workspace w[tg1], match:float 0"

        # Rules for fullscreen workspaces (f[1])
        "border_size 0, match:workspace f[1], match:float 0"
        "rounding 0, match:workspace f[1], match:float 0"

        # Clipse window rules
        "float on, match:class (clipse)"
        "size 622 652, match:class (clipse)"

        # Showmethekey rules
        "float on, match:class ^(showmethekey-gtk)$"
        "pin on, match:class ^(showmethekey-gtk)$"
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
        "$mainMod, return, exec, ${terminal}"
        "$mainMod SHIFT, return, exec, ${scripts.terminalHere}/bin/terminal-here"
        "SHIFT CTRL, return, exec, ${terminal}" # in case, for whatever reason, SUPER isn't recognized

        "$mainMod, q, killactive,"
        "$mainMod SHIFT, q, exit,"
        "SHIFT CTRL, q, exit," # in case, for whatever reason, SUPER isn't recognized

        # TUIs
        "$mainMod, b, exec, ${terminal} -e bluetui"
        "$mainMod, d, exec, ${terminal} -e lazydocker"
        "$mainMod, i, exec, ${terminal} -e btop"
        "$mainMod, m, exec, ${terminal} -e naviterm"
        "$mainMod, r, exec, ${terminal} -e yazi"
        "$mainMod, v, exec, ${terminal} -e clipse"
        "$mainMod SHIFT, w, exec, ${terminal} -e impala"
        "$mainMod, space, exec, rofi -show drun"

        # GUIs
        "$mainMod, w, exec, ${browser}"
        # "$mainMod, g, exec, flatpak run com.heroicgameslauncher.hgl"
        # "$mainMod SHIFT, r, exec, thunar"

        # webapps
        "$mainMod SHIFT, m, exec, ${browser} --new-window https://music.beauslab.casa"
        "$mainMod, a, exec, ${browser} --new-window https://claude.ai"
        "$mainMod SHIFT, a, exec, ${browser} --new-window https://ha.pve.flowergarden.beauhilton.com"
        "$mainMod, c, exec, ${browser} --new-window https://calendar.google.com"
        "$mainMod, e, exec, ${browser} --new-window https://gmail.com"
        "$mainMod SHIFT, e, exec, ${browser} --new-window https://app.fastmail.com"
        "$mainMod, u, exec, ${browser} --new-window https://unifi.ui.com"

        # grimblast's "copysave" both saves a file in the home directory and copies to clipboard
        "$mainMod SHIFT, c, exec, ${scripts.screenshotAreaScript}/bin/screenshot-area"
        "$mainMod SHIFT, x, exec, ${scripts.screenshotActiveScript}/bin/screenshot-active"
        "$mainMod SHIFT, z, exec, ${scripts.screenshotOutputScript}/bin/screenshot-output"

        "$mainMod SHIFT, r, exec, ${scripts.screenRecordScript}/bin/screen-record"

        # notification management
        "$mainMod, n, exec, makoctl dismiss"
        "$mainMod SHIFT, n, exec, makoctl restore"
        "$mainMod CTRL, n, exec, makoctl dismiss --all"

        # tiling mgmt
        "$mainMod, f, fullscreen, 1"
        "$mainMod SHIFT, f, fullscreen, 0"
        "$mainMod, t, togglefloating,"
        # "$mainMod CTRL, t, togglespecialworkspace, magic" # idk why, this borks things
        ## DWM-style focus movement (only prev and next, no left and right)
        "$mainMod, k, layoutmsg, cycleprev"
        "$mainMod, j, layoutmsg, cyclenext"

        ## swap window with mainMod + shift + vim keys
        "$mainMod SHIFT, k, layoutmsg, swapprev"
        "$mainMod SHIFT, j, layoutmsg, swapnext"
        "$mainMod SHIFT, h, swapwindow, l"
        "$mainMod SHIFT, l, swapwindow, r"
        "$mainMod SHIFT, u, layoutmsg, orientationcycle left top"

        # workspace mgmt
        ## Switch workspaces with mainMod + [0-9]
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

        ## scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, split:workspace, e+1"
        "$mainMod, mouse_up, split:workspace, e-1"

        ## move active window to a workspace with mainMod + SHIFT + [0-9]
        ### "movetoworkspacesilent" means "don't autoswitch to the workspace you just moved the active window to"
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

        # monitor mgmt
        "$mainMod, bracketleft, focusmonitor, -1"
        "$mainMod, bracketright, focusmonitor, +1"

        ## move window to monitor
        "$mainMod SHIFT, bracketleft, movewindow, mon:-1"
        "$mainMod SHIFT, bracketright, movewindow, mon:+1"

        ## toggle laptop screen (OLED)
        "$mainMod, o, exec, ${scripts.toggleLaptopScreen}/bin/toggle-laptop-screen"

        ## toggle volume/mute
        "$mainMod, Home, exec, ${scripts.volumeScript}/bin/volume mute"

        ## clip clipboard to discord knowledge base
        "$mainMod SHIFT, d, exec, ${scripts.discordClipScript}/bin/discord-clip"
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

        "$mainMod, Page_Up, exec, ${scripts.volumeScript}/bin/volume raise"
        "$mainMod, Page_Down, exec, ${scripts.volumeScript}/bin/volume lower"

        ", XF86AudioRaiseVolume, exec, ${scripts.volumeScript}/bin/volume raise"
        ", XF86AudioLowerVolume, exec, ${scripts.volumeScript}/bin/volume lower"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
    };
  };
}
