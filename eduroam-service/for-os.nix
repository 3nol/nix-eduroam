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
        serviceConfig = {
          Environment = [
            "EDUROAM_INSTITUTION=${lib.escapeShellArg cfg.institution}"
            "EDUROAM_USERNAME=${lib.escapeShellArg cfg.username}"
            "EDUROAM_PASSWORD_COMMAND=${lib.escapeShellArg cfg.passwordCommand}"
            "EDUROAM_FORCE_WPA=${lib.escapeShellArg (boolToIntString cfg.forceWPA)}"
          ];
          ExecStart = "${eduroam-installer}/bin/eduroam-installer";
        };
        wantedBy = [ "multi-user.target" ];
      };
  };
}
