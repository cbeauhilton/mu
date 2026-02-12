{lib, ...}: {
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        forwardAgent = false;
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        extraOptions = {
          AddKeysToAgent = "yes";
          StrictHostKeyChecking = "no";
        };
      };

      "ssh.dev.azure.com" = {
        user = "git";
        identityFile = "~/.ssh/id_rsa";
        identitiesOnly = true;
      };

      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };

      vultr = {
        hostname = "100.89.237.126";
        user = "beau";
      };

      pve = {
        hostname = "pve";
        user = "root";
      };

      pve-terraform = {
        hostname = "pve";
        user = "terraform";
        identityFile = "~/.ssh/id_ed25519_pve";
        identitiesOnly = true;
      };

      hl15 = {
        hostname = "10.0.0.42";
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };

      hl15-ts = {
        hostname = "100.122.210.6";
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };

      caddy-jump = {
        hostname = "10.0.0.150";
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
      };

      "forgejo.lab.beauhilton.com" = lib.hm.dag.entryBefore ["*.lab.beauhilton.com"] {
        hostname = "forgejo.lab.beauhilton.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
      };

      "*.lab.beauhilton.com" = {
        user = "beau";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
        proxyJump = "caddy-jump";
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
      };
    };
  };
}
