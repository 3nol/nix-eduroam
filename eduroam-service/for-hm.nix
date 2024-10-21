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
    home.eduroam = import ./options.nix {
      inherit lib;
      module = "HomeManager";
    };
  };

  config = lib.mkIf config.home.eduroam.enable {

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
            "EDUROAM_FORCE_WPA=${boolToIntString cfg.forceWPA}"
          ];
          ExecStart = "${eduroam-installer}/bin/eduroam-installer";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
  };
}
