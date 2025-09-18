{
  programs.ssh = {
    enable = true;
    # enableDefaultConfig = false;
    extraConfig = ''
      AddKeysToAgent yes
      Host *
        StrictHostKeyChecking no

      Host ssh.dev.azure.com
        IdentityFile ~/.ssh/id_rsa
        IdentitiesOnly yes

      Host github.com
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes

      Host vultr
        HostName 100.89.237.126
        User beau

      Host pve
        HostName pve
        User root

      Host pve
        User terraform
        IdentityFile ~/.ssh/id_ed25519_pve
        IdentitiesOnly yes
    '';
  };
}
