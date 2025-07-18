{
  description = "Eduroam installation service for NixOS and HomeManager.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:

    flake-utils.lib.eachDefaultSystemPassThrough (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        eduroam-installer = pkgs.callPackage ./eduroam-installer { };
        eduroam-service =
          module: import (./eduroam-service + "/${module}.nix") { inherit eduroam-installer; };
      in
      {
        # Provisioning integrations for installer service.
        nixosModules.default = eduroam-service "for-os";
        homeManagerModules.default = eduroam-service "for-hm";

        # Shell with same dependencies.
        devShells."${system}".default = pkgs.mkShell {
          buildInputs = with pkgs; [
            coreutils
            curl
            jq
            (python3.withPackages (p: with p; [ dbus-python ]))
          ];
        };
      }
    );
}
