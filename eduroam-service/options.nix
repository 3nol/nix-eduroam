{ lib, module, ... }:
{
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
}
