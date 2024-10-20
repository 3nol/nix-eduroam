{
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.writeShellApplication {
  name = "eduroam-installer";

  meta = with pkgs.lib; {
    description = "Python-based Eduroam installer as derivation.";
    homepage = "https://github.com/3nol/nix-eduroam";
    license = licenses.mit;
    maintainers = [ maintainers."3nol" ];
  };

  runtimeInputs = with pkgs; [
    coreutils
    curl
    jq
    (python3.withPackages (p: with p; [ dbus ]))
  ];

  text = builtins.readFile ./install.sh;
}
