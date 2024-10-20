{
  description = "Eduroam as systemd service for NixOS and HomeManager.";

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

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Provisioning installer package and integrations.
        packages.eduroam-installer = pkgs.callPackage ./eduroam-installer { };
        nixosModules.nix-eduroam = ./eduroam-service;

        # NixShell with same dependencies.
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            coreutils
            curl
            jq
            (python3.withPackages (p: with p; [ dbus ]))
          ];
        };
      }
    );
}
