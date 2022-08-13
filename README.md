# Dotfiles

## To Update Local Dotfiles / Installed Packages
Assuming if you have completed all of the [__Getting Started__](#getting-started-1---nixflakeshome-manager-installation) instructions below,
you should be able to run the following command to apply the dotfiles / installed package changes.
```bash
home-manager switch --impure --flake .#$HOMECONFIG_NAME

# OR

nix build .#homeManagerConfigurations.$HOMECONFIG_NAME.activationPackage && ./result/activate

# OR After applying at least once, using the alias
hmapply $HOMECONFIG_NAME
```

To update the packages for home-manager, simply run the nix-channel update and flake-lock updates first, then run the home-manager switch command above.
```
nix-channel --update
nix flake update ~/.config/nixpkgs

# OR
nxup
```

To check the updated list of `$HOMECONFIG_NAME`, run the following command and use the name immediately after the `homeConfigurations.` prefix
```bash
$ awk '/^###### HOMECONFIG PROFILES START/{p=1;next};/^###### HOMECONFIG PROFILES END/{p=0};p' ~/.config/nixpkgs/flake.nix | awk -F'=' '{print $1}' | awk '{$1=$1;print}'
linux_64
linux_headless_64
darwin_64

# OR After applying at least once, using the alias
hmls
```


### NB: A word about the impurity and the `--impure`  flag
The above advocates for `--impure` purely because we are using our `$HOME` and `$USER` env vars to
switch the home-manager config. We could probably remove `--impure` if we set the `username` and `homeDirectory` for the respective  `homeConfigurations` available, or just define a new `homeConfiguration` that does not use those.

### NB2: Errors on first application

When applying the home-manager switch, occasionally Nix will fail to install the new home manager profile. Due to the a file conflict between `home-manager-path` and `nix`. An example of such a scenario here: https://github.com/nix-community/home-manager/issues/2995

A workaround is to set the priority of the corresponding `nix` package to be 0, taking higher priority
than `home-manager-path`

```
nix-env --set-flag priority 0 nix-2.10.3
```

## Rollbacks, cleanups and other miscelleanous ops info

### Rollbacks & Cleanups
Relevant Link: https://nix-community.github.io/home-manager/index.html#sec-usage-rollbacks

Home Manager as of time of writing does not support rollbacks explicitly but the following steps can
be used to help with this:
```bash
# 1. Run the following commands to see the generation you'll want to rollback to
$ home-manager generations
2022-07-31 11:44 : id 3 -> /nix/store/c4nxmvixgan6iw3h4qyb35mrllip4rzc-home-manager-generation
2022-07-30 23:54 : id 2 -> /nix/store/6ybk9xq9i44v9afy27wwjpk2wz92z0cr-home-manager-generation
2022-07-30 13:52 : id 1 -> /nix/store/qh89xz60pdiwizzr7q2mijm7iv8mh7dg-home-manager-generation

# 2. Copy the store path of the generation you'll like to rollback to and run its `activate` script
# For example if we want to rollback to generation 1
$ /nix/store/qh89xz60pdiwizzr7q2mijm7iv8mh7dg-home-manager-generation/activate
Starting home manager activation
```

Cleaning up unused nix stores can be done via the following:
```bash
# First cleanup home-generations, can replace `now` with relative days such as '-30days` etc
home-manager expire-generations now
# OR the folowing after applying once
hmclean


nix-store --gc
# Or the following after applying once
nxclean

# The following to erase every generation for nix-store
nix-collect-garbage -d
# Or the following after applying once
nxcleandeep
```

### Misc Info 1: Imperative Operations

Taken from: https://nixos.wiki/wiki/Nix#Imperative_Operations

nix environments also technically allow imperative operations, although the `home-manager switch .#$HOMECONFIG_NAME` should overwrite this

Below are some `nix-env` common commands used to run imperatively
```bash
nix search packagename # Searching for packages
nix-env -iA packagename # Installing a package, for example in `nix-shell`, you can run `nix-env -iA nixpkgs.custom_python310_with_defaults`
nix-env -q # List installed packages
nix-env -e packagename # Uninstall packages
nix-env -u # Upgrade packages
nix-env --list-generations # see nix-env generations
nix-env --delete-generations +3 # remove every generation except current + 2 older
nix-env --delete-generations old # remove all old generations
nix-channel --list # list all installed channels
nix-channel --update # update all nix channels
nix-channel --remove channelname # remove channel
nix-channel --add CHANNEL_URL channel_name # add a new channel to track, e.g. nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
```

### Misc Info 2: Temporary Shell

Sometimes you'll want to try out temporary builds and not overwrite the current system, in this case
nix allows us to drop into a temporary `shell` environment via `nix-shell`.

To drop into this `shell`, with the project's overlays applied, do the following:
```bash
# cd into the nixpkgs path (i.e. ~/.config/nixpkgs), the path for this repo
cd ~/.config/nixpkgs

# drop into the environment, this should take a while if its your first time as
# the store will take a while to fetch / build
# the packages required
nix-shell --pure
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

Clone the repository to the following path `~/.config/nixpkgs`.
```bash
git clone git@github.com:lohvht/dotfiles.git ~/.config/nixpkgs
```

After that, proceed with the `home-manager switch` instruction at the [start of the document](#to-update-local-dotfiles--installed-packages)

## Getting Started (3) - Non nix/home-manager related settings

This repository consists of packages and dotfiles installations that can only be done at the `$HOME` level, as this is not a `NixOS` module.

While certain tools and packages (such as some language support for Python/Golang/Rust etc) can be installed here, others tools may require installation at a system level, such as via either your native package manager or manual installation.

Below in the following section are some of the starting points for some tools that I use
### Docker installation
Install docker desktop here: https://docs.docker.com/get-docker/

### Change Default Shell
1. Add the full path of the desired shell to the end of the `/etc/shells` file

e.g.
```bash
echo '/home/myunixusername/.nix-profile/bin/zsh' >> /etc/shells
echo '/home/myunixusername/.nix-profile/bin/bash' >> /etc/shells
```

2. Change shell with the following
```bash
chsh -s ~/.nix-profile/bin/fish
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

### Flake update lockfile
```bash
nix flake update ~/.config/nixpkgs

# After first apply
nxup
```

## More Examples (Check with these)
TODO: Remove this section when done
- Example 1 nixpkgs by jonringer: https://github.com/jonringer/nixpkgs-config/blob/cc2958b5e0c8147849c66b40b55bf27ff70c96de/home.nix
- Example2 nixpkgs by Misterio77: https://github.com/Misterio77/nix-starter-config/blob/main/flake.nix
- Some comments on how to pin to specific versions of packages: https://news.ycombinator.com/item?id=28593823
- Some examples on installing packages in home-manager specific to version: https://github.com/nix-community/home-manager/issues/2796
- To find specific versions https://lazamar.co.uk/nix-versions/
- Specific example on how to actually override a version of a package: https://github.com/NixOS/nixpkgs/issues/93327#issuecomment-825410447