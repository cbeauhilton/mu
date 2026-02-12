{
  config,
  lib,
  pkgs,
  ...
}: {
  options.work.gcloud.enable = lib.mkEnableOption "Google Cloud work configuration";

  config = lib.mkIf config.work.gcloud.enable {
    home.packages = with pkgs; [
      google-cloud-sdk
    ];

    sops.secrets.gcloud_service_account_json = {};

    home.sessionVariables = {
      GOOGLE_APPLICATION_CREDENTIALS =
        config.sops.secrets.gcloud_service_account_json.path;
    };
  };
}
