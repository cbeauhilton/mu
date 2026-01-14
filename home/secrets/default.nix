# Home-manager secrets management via sops-nix
{
  inputs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Define secrets that will be available as files
    secrets = {
      naviterm_password = {};
      subidy_password = {};
      karakeep_api_key = {};
    };

    # Templates for config files that need secrets substituted
    templates = {
      "naviterm.ini" = {
        content = ''
          server_address=https://music.beauslab.casa
          user=admin
          password=${config.sops.placeholder.naviterm_password}
          server_auth=token
          primary_accent=yellow
          secondary_accent=gray
          home_list_size=30
          follow_cursor_queue=true
          draw_while_unfocused=false
          save_player_status=true
        '';
        path = "${config.home.homeDirectory}/.config/naviterm/naviterm.ini";
      };

      "mopidy-subidy.conf" = {
        content = ''
          [subidy]
          enabled = true
          url = https://music.beauslab.casa
          username = admin
          password = ${config.sops.placeholder.subidy_password}
          api_version = 1.16
        '';
        # This will be included via extraConfigFiles
      };
    };
  };
}
