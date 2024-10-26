# nix-eduroam

Eduroam installation service for NixOS and HomeManager.

## What is this?

This repository provides a simple `eduroam-installer` that downloads and 
runs the Python-based Eduroam setup script for Linux systems.

Furthermore, this flake includes two integrations.
- A NixOS module called `nix-eduroam`, as part of `nixosModules`.
- A HomeManager module also called `nix-eduroam`, as part of `homeManagerModules`.

Both modules run the `eduroam-installer` as oneshot systemd service.

## How to integrate in my own config?

Three required and one optional config options can be set.
- `institution` : string, denoting institution name
- `username` : string, username within the institution
- `passwordCommand` : string, command which outputs the password to stdout
- `forceWPA` : boolean, optionally enforce not configuring [NetworkManager](https://wiki.archlinux.org/title/NetworkManager) but use [wpa_supplicant](https://wiki.archlinux.org/title/Wpa_supplicant)

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

In case of the HomaManager integration, this installer is run per user (i.e. as systemd user service).
Using `<your system>`, you can integrate it in your HomeManager imports as follows.
```nix
nix-eduroam.homeManagerModules."<your system>".nix-eduroam
```

Personally, I recommend using HomeManager, as the user-level service is sufficient.
Additionally, you are required to provide user-specific options anyway. HomeManager's `sharedModules` 
option allows you to distribute this module across multiple users on the same system.

**Configuration:**
The root (same options as above) is `home.eduroam`.

## FAQ

Some (what I think are) common questions.

### Why is a password command required?

This allows you to use a password manager or similar CLI tools. Thus, you do (and should) not specify
your Eduroam password in cleartext. But if this is want you want to do, go for `echo '<password>'`.

Unfortunately, there is no [sops-nix](https://github.com/Mic92/sops-nix) support (yet).

### Does this require an active internet connection?

Yes, it does. Two requests are necessary, (1) for determining the ID of your institution and (2) for
downloading the institution-specific installer.

You can still rebuild your system without an internet connection, and restart the failed service
called "eduroam-installer" after switching to your new system and establishing a connection.

### Why does rebuild and switch not rerun the installer?

This has to do with the systemd service being of type "oneshot". It will not restart if it was present
before and has run before. As a result, you will need to restart the service manually.
- For NixOS: `systemctl restart eduroam-installer`
- For HomeManager: `systemctl restart --user eduroam-installer`

You might want to clear the existing configuration data at `~/.config/cat_installer` before restarting.

### Why does the NixOS installer fail because it cannot find the password command?

Per default, systemd services (especially those running as root), are running in a sandboxed environment
with things not being available that you are normally used to in your shell.

The PATH contains `/run/current-system/sw/bin` for the NixOS module but that may not be enough in your case.
Currently, there are no convenient options for modifying the PATH. Instead, you would have to override 
[that field](https://github.com/3nol/nix-eduroam/blob/main/eduroam-service/for-os.nix#L40-L41) manually.
