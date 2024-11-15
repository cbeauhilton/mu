{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap-flake.url = "github:xremap/nix-flake";
    nur.url = "github:nix-community/nur";
    ags.url = "github:aylur/ags";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland";
    hyprgrass = { # swipe gestures for workspaces
      url = "github:horriblename/hyprgrass";
      inputs.hyprland.follows = "hyprland";
    };
    Hyprspace = { # workspace overview feature
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprsplit = { # dwm-like workspace manager - breaks sometimes
      url = "github:shezdy/hyprsplit";
      inputs.hyprland.follows = "hyprland";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        inputs.nur.overlay
      ];
      config = {
        allowUnfree = true;
      };
    };
    username = "beau";
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs pkgs;};
        modules = [
          ./configuration.nix

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs pkgs;};
            home-manager.users.beau.imports = [
              ./home.nix
            ];
          }
        ];
      };
    };
  };
}
