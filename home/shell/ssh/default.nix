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

      Host proxmox
        HostName 10.0.0.42
        User root
        IdentityFile ~/.ssh/id_ed25519_pve
        IdentitiesOnly yes

      Host forgejo.lab.beauhilton.com
        HostName forgejo.lab.beauhilton.com
        User git
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
        StrictHostKeyChecking no
    '';
  };
}
