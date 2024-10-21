{ eduroam-installer, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    services.eduroam = import ./options.nix {
      inherit lib;
      module = "NixOS";
    };
  };

  config = lib.mkIf config.services.eduroam.enable {

    # NixOS config for system-level installer.
    systemd.services.eduroam-installer =
      let
        cfg = config.services.eduroam;
      in
      {
        description = "Eduroam Installer";
        unitConfig.Type = "oneshot";
        serviceConfig = {
          Environment = [
            "EDUROAM_INSTITUTION=${cfg.institution}"
            "EDUROAM_USERNAME=${cfg.username}"
            "EDUROAM_PASSWORD_COMMAND=${cfg.passwordCommand}"
            "EDUROAM_FORCE_WPA=${if cfg.forceWPA then 1 else 0}"
          ];
          ExecStart = "${eduroam-installer}/bin/eduroam-installer";
        };
        wantedBy = [ "multi-user.target" ];
      };
  };
}
