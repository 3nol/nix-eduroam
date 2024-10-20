{
  description = "Eduroam as systemd service for NixOS and HomeManager.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      in
      {
        # Provisioning installer package and integrations.
        packages.eduroam-installer = pkgs.callPackage ./eduroam-installer { };
        nixosModules.nix-eduroam = ./eduroam-service/for-os.nix;
        homeManagerModules.nix-eduroam = ./eduroam-service/for-hm.nix;

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
