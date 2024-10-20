{
  config,
  lib,
  pkgs,
  ...
}:
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
            "EDUROAM_FORCE_WPA=${if cfg.forceWPA then 1 else 0}"
          ];
          ExecStart = "${pkgs.eduroam-installer}/bin/eduroam-installer";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
  };
}
