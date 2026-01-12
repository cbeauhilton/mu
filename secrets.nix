{inputs, ...}: let
  username = "beau";
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age = {
      keyFile = "/home/${username}/.config/sops/age/keys.txt";
      sshKeyPaths = [
        "/home/${username}/.ssh/id_ed25519"
        "/home/${username}/.ssh/id_ed25519_pve"
      ];
    };
  };
}
