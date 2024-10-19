{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.eduroam-installer;
in
with lib;
{
  options.networking.eduroam = {
    enable = mkEnableOption "Install Eduroam using Python-based installer for Linux.";

    institution = mkOptopn {
      type = types.str;
      default = "";
      description = "Institution for which to install Eduroam.";
    };
    username = mkOption {
      type = types.str;
      default = "";
      description = "Username for authentication.";
    };
    passwordCommand = mkOption {
      type = types.str;
      default = "";
      description = "Command printing password for authentication to stdout.";
    };
    forceWPA = mkOption {
      type = types.bool;
      default = false;
      description = "Generate wpa_supplicant file without using NetworkManager.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.eduroam-installer = {
      description = "Eduroam Installer";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.eduroam-installer}/bin/eduroam-installer.sh";
        Environment = [
          "EDUROAM_INSTITUTION=${cfg.institution}"
          "EDUROAM_USERNAME=${cfg.username}"
          "EDUROAM_PASSWORD_COMMAND=${cfg.passwordCommand}"
          "EDUROAM_FORCE_WPA=${cfg.forceWPA}"
        ];
      };
    };
  };
}
