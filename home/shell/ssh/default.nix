{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      AddKeysToAgent yes
      Host *
        StrictHostKeyChecking no
    '';
  };
}
