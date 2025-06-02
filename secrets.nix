{
  config,
  inputs,
  ...
}: let
  username = "beau";
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [
    "/home/${username}/.ssh/id_ed25519"
    "/home/${username}/.ssh/id_rsa"
    "/home/${username}/.ssh/id_ed25519_pve"
  ];
}
