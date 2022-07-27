# Dotfiles (Updated as of 26th July 2022)

## To Update Local Dotfiles / Installed Packages
Assuming if you have completed all of the __Getting Started__ instructions below,
you should be able to run the following command to apply the dotfiles / installed package changes.
```bash
nix build .#homeManagerConfigurations.$HOMECONFIG_NAME.activationPackage && ./result/activate

# OR

home-manager switch --flake .#$HOMECONFIG_NAME
```

## Getting Started (1) - Nix/Flakes/Home-Manager Installation

Install nix, there several recommendation that NixOS has, you can check here: https://nixos.org/download.html

Here is a general gist of the installation process:

Nix Installations comes in different flavours, *multi-user* installation and *single-user* installation.
```bash
# Multi-user installation
sh <(curl -L https://nixos.org/nix/install) --daemon

# Single user installation
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

The choice of installations determine how `nix` will be run. Under a *multi-user* installation, the nix store is owned by root and builds are done via special user accounts. Unprivileged users forward nix-commands as actions to the nix-daemon.

*Multi-user* installations have a few pros and cons over a *single-user* installation.

#### Pros
- Better build isolation (and that is what Nix is all about)
- Better security (a build can not write somewhere in your home)
- Sharing builds between users
#### Cons
- Requires `root` to run the daemon
- More involved installation (creation of `nixbld* users`, installing a `systemd` unit, ...
- Harder to uninstall

### Installation recommendations
#### Linux
- *multi-user* installation is recommended if you are on Linux running systemd, with SELinux disabled and you can authenticate with sudo.
- *single-user* is recommended otherwise. `/nix` will be owned by the invoking user. You should run this under your usual user account, not as `root`. The script will invoke `sudo` to create `/nix` if it doesn’t already exist.

#### Windows via Windows Subsystem for Linux (WSL2)
- *single-user* installation is recommended

#### MacOS
- *multi-user* installation is recommended

### Checking Nix Installation
```bash
$ nix-env --version
nix-env (Nix) 2.3.15
```

### Nix Flakes Installation
Nix Flakes allows us to specify our dependencies in a declarative way

Ensure that `nix >= 2.4`, then add this line in the config path `~/.config/nix/nix.conf`
```conf
experimental-features = nix-command flakes
```

Restart the nix-daemon
```bash
# On linux
sudo systemctl restart nix-daemon.service

# On MacOS
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon
```
More recent installations of nix should already come with flakes installed. To verify, check with the following command:

```bash
nix flake --help
```

### home-manager installation
Add the following Home Manager channel.
```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```

Run the Home Manager installation command and create the first Home Manager generation:
```bash
NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH} nix-shell '<home-manager>' -A install
```

## Getting Started (2) - Git Clone

```bash
git clone git@github.com:lohvht/dotfiles.git ~/.config/nixpkgs
```

## Updating nix / nix packages / flake lockfile
https://nixos.org/manual/nix/stable/installation/upgrading.html

### Nix Updating
For updating nix itself, these are the commands to run:
Multi-user Nix users on macOS can upgrade Nix by running:
```
sudo -i sh -c 'nix-channel --update && nix-env -iA nixpkgs.nix && launchctl remove org.nixos.nix-daemon && launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist'
```

Single-user installations of Nix should run this:
```
nix-channel --update; nix-env -iA nixpkgs.nix nixpkgs.cacert
```

Multi-user Nix users on Linux should run this with sudo:
```
nix-channel --update; nix-env -iA nixpkgs.nix nixpkgs.cacert; systemctl daemon-reload; systemctl restart nix-daemon
```

### Nix Packages

TODO:

### Flake update lockfile
```bash
nix flake update ~/.config/nixpkgs
```

## More Examples (Check with these)
TODO: Remove this section when done
- Example 1 nixpkgs by jonringer: https://github.com/jonringer/nixpkgs-config/blob/cc2958b5e0c8147849c66b40b55bf27ff70c96de/home.nix
- Example2 nixpkgs by Misterio77: https://github.com/Misterio77/nix-starter-config/blob/main/flake.nix
- Some comments on how to pin to specific versions of packages: https://news.ycombinator.com/item?id=28593823
- Some examples on installing packages in home-manager specific to version: https://github.com/nix-community/home-manager/issues/2796
- To find specific versions https://lazamar.co.uk/nix-versions/
- Specific example on how to actually override a version of a package: https://github.com/NixOS/nixpkgs/issues/93327#issuecomment-825410447