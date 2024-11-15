# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./hardware-configuration.nix
  ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/beau/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [
    "/home/beau/.ssh/id_ed25519"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  networking.hostName = "nixos"; # Define your hostname.
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

  services.xserver.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.sudo.wheelNeedsPassword = false;
  console = {
    useXkbConfig = true; # use xkbOptions in tty.
  };

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
    xkb.options = "caps:escape";
  };
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  security.rtkit.enable = true;
  programs.nix-ld.enable = true;
  # programs.nix-ld = {
  #   libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
  # };

  programs.virt-manager.enable = true;
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  hardware.uinput.enable = true; # req for xremap
  users.groups.uinput.members = ["beau"]; # req for xremap
  users.groups.input.members = ["beau"]; # req for xremap # services.libinput.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.beau = {
    isNormalUser = true;
    description = "beau";
    extraGroups = ["networkmanager" "wheel" "audio" "pipewire" "libvirtd"];
    # dconf.settings = {
    #   "org/virt-manager/virt-manager/connections" = {
    #     autoconnect = [ "qemu:///system" ];
    #     uris = [ "qemu:///system" ];
    #   };
    # };
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "beau";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  environment.variables.EDITOR = "nvim";
  environment.sessionVariables = {
    FLAKE = "/home/beau/src/nixos";
    NIXOS_OZONE_WL = "1";
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sops
    code-cursor
    networkmanagerapplet
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

  fonts.fontDir.enable = true;
  fonts.fontconfig = {
    defaultFonts = {
      serif = ["IBM Plex Serif"];
      sansSerif = ["IBM Plex Sans"];
      monospace = ["BlexMono"];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
