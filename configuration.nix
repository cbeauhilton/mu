{
  config,
  pkgs,
  inputs,
  ...
}: let
  username = "beau";
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./hardware-configuration.nix
  ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [
    "/home/${username}/.ssh/id_ed25519"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  networking.hostName = "mu"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    xkb.options = "caps:escape";
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  console = {
    useXkbConfig = true; # use xkbOptions in tty.
  };
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.sudo.wheelNeedsPassword = false;

  # Enable Display Manager
  # might switch to this at some point but need to figure out the keyring stuff
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
  #       user = "greeter";
  #     };
  #   };
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  programs.nix-ld.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  hardware = {
    graphics.enable = true;
  };
  # programs.nix-ld = {
  #   libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
  # };

  # hyprland
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
    };

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  security.rtkit.enable = true;
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.default;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };
  # tell Electron/Chromium to run on Wayland
  environment.variables.NIXOS_OZONE_WL = "1";

  environment.sessionVariables = {
    FLAKE = "/home/${username}/src/nixos";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  hardware.uinput.enable = true; # req for xremap
  users.groups.uinput.members = ["${username}"]; # req for xremap
  users.groups.input.members = ["${username}"]; # req for xremap # services.libinput.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = ["networkmanager" "wheel" "audio" "pipewire" "libvirtd"];
  };

  # Enable automatic login for the user.
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "${username}";
    };
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.variables.EDITOR = "nvim";
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # greetd.tuigreet
    sops
    networkmanagerapplet
    libgcc
    zig
    rustup
    neovim
    bun
    wget
    curl
    alacritty
    alejandra
    vlc
    mpv
    nh
    git
    bitwarden-cli
  ];

  ### tailscale
  services.tailscale.enable = true;
  # always allow traffic from your Tailscale network
  networking.firewall.trustedInterfaces = ["tailscale0"];
  # allow the Tailscale UDP port through the firewall
  networking.firewall.allowedUDPPorts = [config.services.tailscale.port];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "IBMPlexMono"
        "Hack"
        "FiraCode"
      ];
    })
    ibm-plex
  ];

  programs.virt-manager.enable = true;
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [pkgs.OVMFFull.fd];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  services.flatpak.enable = true;
  fonts.fontDir.enable = true;
  fonts.fontconfig = {
    defaultFonts = {
      serif = ["IBM Plex Serif"];
      sansSerif = ["IBM Plex Sans"];
      monospace = ["BlexMono"];
    };
  };

  system.stateVersion = "23.05"; # don't change this
}
