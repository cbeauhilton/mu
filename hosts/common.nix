# Common NixOS configuration shared across all hosts
{
  config,
  pkgs,
  ...
}: let
  username = "beau";
in {
  imports = [
    ../audio.nix
    ../secrets.nix
    ../shared
    ../shared/fonts.nix
    ../shared/game.nix
    ../users.nix
    ../meshtastic.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      accept-flake-config = true;
      warn-dirty = false;
      auto-optimise-store = true;
      download-buffer-size = 500000000;
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

  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  security.sudo.wheelNeedsPassword = false;

  services = {
    flatpak.enable = true;
    fwupd.enable = true;
    tailscale.enable = true;
  };

  programs = {
    nix-ld.enable = true;
    zsh.enable = true;
    virt-manager.enable = true;
  };

  hardware = {
    enableAllFirmware = true;
    uinput.enable = true; # req for xremap
  };

  environment = {
    sessionVariables.FLAKE = "/home/${username}/src/nixos";
    variables = {
      EDITOR = "nvim";
      PYTHONPYCACHEPREFIX = "/tmp/pycache-dir";
    };
  };

  users = {
    groups = {
      uinput.members = [username]; # req for xremap
      input.members = [username]; # req for xremap
    };
    defaultUserShell = pkgs.zsh;
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = ["python3.13-ecdsa-0.19.1"];
  };

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
