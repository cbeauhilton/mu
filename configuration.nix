{
  config,
  pkgs,
  inputs,
  ...
}: let
  username = "beau";
in {
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./shared
    ./hosts
    ./secrets.nix
    ./audio.nix
    ./display.nix
    ./fonts.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      accept-flake-config = true;
      warn-dirty = false;
      auto-optimise-store = true;
      trusted-users = ["beau" "@wheel" "root"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };

  networking.hostName = "mu";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Chicago";
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

  security.sudo.wheelNeedsPassword = false;

  services.printing.enable = true;
  services.flatpak.enable = true;

  programs.nix-ld.enable = true;
  hardware.enableAllFirmware = true;


  environment.sessionVariables = {
    FLAKE = "/home/${username}/src/nixos";
  };

  hardware.uinput.enable = true; # req for xremap
  users.groups.uinput.members = ["${username}"]; # req for xremap
  users.groups.input.members = ["${username}"]; # req for xremap
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;
  environment.variables.EDITOR = "nvim";
  environment.variables.PYTHONPYCACHEPREFIX = "/tmp/pycache-dir";

  ### tailscale
  services.tailscale.enable = true;
  # always allow traffic from your Tailscale network
  networking.firewall.trustedInterfaces = ["tailscale0"];
  # allow the Tailscale UDP port through the firewall
  networking.firewall.allowedUDPPorts = [config.services.tailscale.port];

  programs.virt-manager.enable = true;
  virtualisation = {
    docker = {
      enable = true;
    };
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

  system.stateVersion = "23.05"; # don't change this
}
