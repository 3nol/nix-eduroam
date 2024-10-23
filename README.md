# nix-eduroam

Eduroam installation as service for NixOS and HomeManager.

## What is this?

This repository provides a hacky `eduroam-installer` for downloading and running
the Python-based installation script for Linux systems.

Furthermore, this flake includes two integrations.
- A NixOS module called `nix-eduroam`, as part of `nixosModules`.
- A HomeManager module also called `nix-eduroam`, as part of `homeManagerModules`.

Both modules run the `eduroam-installer` as oneshot systemd service.

## How to integrate in my own config?

Three required and one optional config options can be set.
- `institution` : string, denoting institution name
- `username` : string, username within the institution
- `passwordCommand` : string, command which outputs the password to stdout
- `forceWPA` : boolean, optionally enforce not configuring [NetworkManager](https://wiki.archlinux.org/title/NetworkManager) but use [wpa_conf](https://wiki.archlinux.org/title/Wpa_supplicant)

See also their [source](https://github.com/3nol/nix-eduroam/blob/main/eduroam-service/options.nix) for more information.

**Important:**
When enabling `forceWPA`, your evaluated password will be stored in _cleartext_ in ~/.config!

If you are unsure what your exact institution name is, it has to be one of those.
```sh
curl --compressed 'https://discovery.eduroam.app/v1/discovery.json' | jq --raw-output '.instances[] | .name'
```

### NixOS Module

In case of the NixOS integration, this installer is run as root (i.e. as systemd OS service).
Using `<your system>`, you can integrate it in your NixOS modules as follows.
```nix
nix-eduroam.nixosModules."<your system>".nix-eduroam
```

Note that this might affect the password commands you want to evaluate, however,
`/run/current-system/sw` is added to the PATH, which should include _most_ binaries.

**Configuration:**
The root (same options as above) is `services.eduroam`.

### HomeManager Module

In case of the HomaManager intgration, this installer is run per user (i.e. as systemd user service).
Using `<your system>`, you can integrate it in your HomeManager imports as follows.
```nix
nix-eduroam.homeManagerModules."<your system>".nix-eduroam
```

Personally, I recommend using HomeManager, as the user-level service is sufficient.
Additionally, you are required to provide user-specific options anyway. To distribute 
this module across multiple users, you can add it to HomeManager's `sharedModules`.

**Configuration:**
The root (same options as above) is `home.eduroam`.
