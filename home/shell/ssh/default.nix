{
  programs.ssh = {
    enable = true;
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
    '';
  };
}
