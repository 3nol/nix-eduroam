{
  description = "Eduroam installation service for NixOS and HomeManager.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        eduroam-installer = pkgs.callPackage ./eduroam-installer { };
        eduroam-service =
          module: import (./eduroam-service + "/${module}.nix") { inherit eduroam-installer; };
      in
      {
        # Provisioning integrations for installer service.
        packages.eduroam-installer = eduroam-installer;
        nixosModules.nix-eduroam = eduroam-service "for-os";
        homeManagerModules.nix-eduroam = eduroam-service "for-hm";

        # NixShell with same dependencies.
        devShells.default = pkgs.mkShell {
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
