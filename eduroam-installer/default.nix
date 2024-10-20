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
      services.user.eduroam = mkEduroamOptions "HomeManager";
    };

  config =
    (lib.mkIf services.eduroam.enable {

      # NixOS config for system-level installer.
      systemd.services.eduroam-installer = {
        description = "Eduroam Installer";
        unitConfig = {
          Type = "oneshot";
        };
        serviceConfig = {
          Environment = [
            "EDUROAM_INSTITUTION=${cfg.institution}"
            "EDUROAM_USERNAME=${cfg.username}"
            "EDUROAM_PASSWORD_COMMAND=${cfg.passwordCommand}"
            "EDUROAM_FORCE_WPA=${cfg.forceWPA}"
          ];
          ExecStart = "${pkgs.eduroam-installer}/bin/eduroam-installer.sh";
        };
        wantedBy = [ "multi-user.target" ];
      };
    })
    // (lib.mkIf services.user.eduroam.enable {

      # HomeManager config for user-level installer.
      systemd.user.services.eduroam-installer = {
        Unit.Description = "Eduroam Installer";
        Service = {
          Type = "oneshot";
          Environment = [
            "EDUROAM_INSTITUTION=${cfg.institution}"
            "EDUROAM_USERNAME=${cfg.username}"
            "EDUROAM_PASSWORD_COMMAND=${cfg.passwordCommand}"
            "EDUROAM_FORCE_WPA=${cfg.forceWPA}"
          ];
          ExecStart = "${pkgs.eduroam-installer}/bin/eduroam-installer.sh";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    });
}
