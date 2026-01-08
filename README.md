# NixOS Configuration

Personal NixOS flake with home-manager integration.

## Structure

```
.
├── flake.nix                 # Entry point, defines hosts
├── hosts/
│   ├── common.nix            # Shared NixOS config
│   └── mu/                   # Host: ThinkPad X1 Carbon
│       ├── configuration.nix # Host entry point
│       ├── default.nix       # Power/hardware settings
│       ├── display.nix       # Hyprland system config
│       └── hardware-configuration.nix
├── home/
│   ├── common.nix            # Shared home-manager config
│   ├── hosts/
│   │   └── mu.nix            # Host-specific home config
│   ├── packages/             # Categorized package lists (alphabetized)
│   ├── secrets/              # sops-nix home-manager integration
│   └── ...                   # Module directories (browsers, desktop, dev, etc.)
├── shared/
│   ├── packages/             # System packages (categorized)
│   └── networking/           # Network configs (iwd, networkmanager)
├── lib/
│   └── monitors.nix          # Monitor definitions per host
├── overlays/
│   └── default.nix           # Overlay aggregator
└── secrets/
    └── secrets.yaml          # Encrypted secrets (sops)
```

## Quick Commands

```bash
# Rebuild and switch
nh os switch

# Edit secrets
sops secrets/secrets.yaml

# Check before committing (runs automatically via pre-commit)
alejandra .       # Format
statix check      # Lint
deadnix -e        # Find unused code

# Update flake inputs
nix flake update
```

## Adding a New Host

### 1. NixOS Configuration

Create `hosts/<hostname>/configuration.nix`:

```nix
{pkgs, ...}: {
  imports = [
    ../common.nix
    ./default.nix              # Host-specific settings
    ./hardware-configuration.nix
  ];

  networking.hostName = "<hostname>";
  time.timeZone = "America/Chicago";
  boot.kernelPackages = pkgs.linuxPackages_zen;
  system.stateVersion = "24.05";
}
```

### 2. Home-Manager Configuration

Create `home/hosts/<hostname>.nix`:

```nix
{...}: {
  imports = [../common.nix];

  # Enable modules for this host
  browsers.chrome-debug.enable = true;
  media.music.enable = true;

  home = {
    username = "<user>";
    stateVersion = "24.05";
  };
}
```

### 3. Add to flake.nix

```nix
nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };
  modules = [
    ./hosts/<hostname>/configuration.nix
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs pkgs;
          monitors = monitorsLib.hosts.<hostname>;
          inherit monitorsLib;
        };
        users.<user>.imports = [./home/hosts/<hostname>.nix];
      };
    }
  ];
};
```

### 4. Add Monitors (if needed)

In `lib/monitors.nix`, add to `hosts`:

```nix
hosts = {
  <hostname> = {
    primary = mkMonitor {
      description = "Monitor description from hyprctl monitors all";
      resolution = "2560x1440";
      refreshRate = 144;
      position = "0x0";
      scale = 1;
    };
  };
};
```

## Optional Modules

Enable in `home/hosts/<hostname>.nix`:

| Module | Description |
|--------|-------------|
| `browsers.chrome-debug.enable` | Chrome with remote debugging (port 9222) |
| `media.music.enable` | Mopidy + ncmpcpp |
| `work.azure.enable` | Azure CLI tools |

## Secrets

Managed via sops-nix. Secrets are encrypted with age.

```bash
# Edit secrets
sops secrets/secrets.yaml

# Available secrets (check secrets/secrets.yaml for full list)
# - naviterm_password
# - subidy_password
# - aon_lan_password
# - anthropic_api_key
# - etc.
```

Home-manager secrets are defined in `home/secrets/default.nix` and use templates for config files that need secrets substituted at activation time.

## Package Organization

Packages are split into categorized, alphabetized files:

**System packages** (`shared/packages/`):
- `cli.nix` - CLI tools
- `desktop.nix` - Desktop apps
- `dev.nix` - Development tools

**Home packages** (`home/packages/`):
- `cli.nix`, `compression.nix`, `desktop.nix`, `dev.nix`
- `fonts.nix`, `media.nix`, `monitoring.nix`, `network.nix`
