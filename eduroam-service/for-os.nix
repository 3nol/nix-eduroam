{ eduroam-installer, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  boolToIntString = value: builtins.toString (if value then 1 else 0);
in
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
        environment = {
          EDUROAM_INSTITUTION = "${lib.escapeShellArg cfg.institution}";
          EDUROAM_USERNAME = "${lib.escapeShellArg cfg.username}";
          EDUROAM_PASSWORD_COMMAND = "${lib.escapeShellArg cfg.passwordCommand}";
          EDUROAM_FORCE_WPA = "${lib.escapeShellArg (boolToIntString cfg.forceWPA)}";
        };
        serviceConfig.ExecStart = "${eduroam-installer}/bin/eduroam-installer";

        wantedBy = [ "multi-user.target" ];

        # So that arbitrary password commands can be evaluated.
        path = [ "/run/current-system/sw" ];
      };
  };
}
