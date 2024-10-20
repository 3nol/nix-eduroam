{
  config,
  lib,
  pkgs,
  ...
}:
{
  options =
    let
      mkEduroamOptions = module: {
        enable = lib.mkEnableOption "Install Eduroam using Python-based installer for ${module}.";

        institution = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Institution for which to install Eduroam.";
        };
        username = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Username for authentication.";
        };
        passwordCommand = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Command printing password for authentication to stdout.";
        };
        forceWPA = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Generate wpa_supplicant file without using NetworkManager.";
        };
      };
    in
    {
      services.eduroam = mkEduroamOptions "NixOS";
      home.eduroam = mkEduroamOptions "HomeManager";
    };

  config =
    (lib.mkIf config.services.eduroam.enable {

      # NixOS config for system-level installer.
      systemd.services.eduroam-installer =
        let
          cfg = config.services.eduroam;
        in
        {
          description = "Eduroam Installer";
          unitConfig = {
            Type = "oneshot";
          };
          serviceConfig = {
            Environment = [
              "EDUROAM_INSTITUTION=${cfg.institution}"
              "EDUROAM_USERNAME=${cfg.username}"
              "EDUROAM_PASSWORD_COMMAND=${cfg.passwordCommand}"
              "EDUROAM_FORCE_WPA=${if cfg.forceWPA then 1 else 0}"
            ];
            ExecStart = "${pkgs.eduroam-installer}/bin/eduroam-installer";
          };
          wantedBy = [ "multi-user.target" ];
        };
    })
    // (lib.mkIf config.home.eduroam.enable {

      # HomeManager config for user-level installer.
      systemd.user.services.eduroam-installer =
        let
          cfg = config.home.eduroam;
        in
        {
          Unit.Description = "Eduroam Installer";
          Service = {
            Type = "oneshot";
            Environment = [
              "EDUROAM_INSTITUTION=${cfg.institution}"
              "EDUROAM_USERNAME=${cfg.username}"
              "EDUROAM_PASSWORD_COMMAND=${cfg.passwordCommand}"
              "EDUROAM_FORCE_WPA=${if cfg.forceWPA then 1 else 0}"
            ];
            ExecStart = "${pkgs.eduroam-installer}/bin/eduroam-installer";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
    });
}
