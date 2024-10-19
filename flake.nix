{
  description = "Eduroam as systemd service in NixOS.";

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
        # Provisioning installer package and NixOS integration.
        packages.eduroam-installer = pkgs.callPackage ./default.nix { };
        nixosModules.eduroam-installer = import ./eduroam-installer { };

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
