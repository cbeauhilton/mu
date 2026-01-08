{
  description = "Nixos config flake";
  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://jupyterwith.cachix.org"
      "https://nix-community.cachix.org"
      "https://pre-commit-hooks.cachix.org"
      "https://hyprland.cachix.org"
      "https://devenv.cachix.org"
      "https://claude-code.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "jupyterwith.cachix.org-1:/kDy2B6YEhXGJuNguG1qyqIodMyO4w8KwWH4/vAc7CI="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
    trusted-users = [
      "root"
      "@wheel"
      "beau"
    ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap-flake.url = "github:xremap/nix-flake";
    nur.url = "github:nix-community/nur";
    ags.url = "github:aylur/ags";
    claude-code.url = "github:sadjow/claude-code-nix";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland";
    hyprgrass = {
      # swipe gestures for workspaces
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprsplit = {
      # dwm-like workspace manager - breaks sometimes
      url = "github:shezdy/hyprsplit";
      inputs.hyprland.follows = "hyprland";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    naviterm.url = "gitlab:detoxify92/naviterm";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = import ./overlays {inherit inputs;};
      config.allowUnfree = true;
    };

    pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
      src = ./.;
      hooks = {
        alejandra.enable = true;
        statix.enable = true;
        deadnix.enable = true;
      };
    };

    monitorsLib = import ./lib/monitors.nix {inherit (nixpkgs) lib;};
  in {
    checks.${system} = {
      inherit pre-commit-check;
    };

    devShells.${system}.default = pkgs.mkShell {
      inherit (pre-commit-check) shellHook;
      buildInputs = with pkgs; [
        alejandra
        statix
        deadnix
      ];
    };

    nixosConfigurations = {
      mu = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/mu/configuration.nix

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs pkgs;
                monitors = monitorsLib.hosts.mu;
                inherit monitorsLib;
              };
              users.beau.imports = [./home/hosts/mu.nix];
            };
          }
        ];
      };
    };
  };
}
