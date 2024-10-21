{
  description = "Eduroam installation as service for NixOS and HomeManager.";

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
      in
      {
        # Provisioning integrations for installer service.
        packages.eduroam-installer = eduroam-installer;
        nixosModules.nix-eduroam = import ./eduroam-service/for-os.nix { inherit eduroam-installer; };
        homeManagerModules.nix-eduroam = import ./eduroam-service/for-hm.nix { inherit eduroam-installer; };

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
