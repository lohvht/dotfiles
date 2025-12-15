# Steam Deck specific setup

This folder contains several files and instructions needed to enable the
home manager setup for steam decks.

Since Steam deck's disk mounts are less straightforward, anything written
in the root partition is by overwritable.

Most of this guide is more or less lifted by the following article by
Determinate Systems on installing Nix on steam decks ([Link](https://determinate.systems/blog/nix-on-the-steam-deck/))

## Installation

1. Go to Desktop mode
2. To make things easier instead of relying on the virtual keyboard, do one of the following:
  - plug in a keyboard
  - go into a command line and run the following commands:
    ```bash
      passwd # Set a password for your deck user, if not already set
      sudo systemctl start sshd # Start SSHD so that we can SSH from another device with a proper keyboard
      ip a # Confirm the IP address to ssh t
    ```

    Then from a separate device run the following, where deck is the default user for steam decks.
    ```bash
    ssh deck@<IP ADDRESS>
    ```
3. Write the `.service` and `.mount` files into the respective folders as pointed out in the header
comments of each of the following files
4. Run the mount and install Nix, before starting the newly written services
    ```bash
      sudo mount --bind /home/nix /nix # Needs to bind this first, otherwise it will write to root partition,
      sh <(curl -L https://nixos.org/nix/install) --daemon
      sudo systemctl enable --now ensure-symlinked-units-resolve.service
    ```
5. Proceed with the installation as per the README in the root of the repository.
6. Restart shell or device

## NOTE: When there is sudden power loss in the steam deck and flushes weren't run properly

This is the recommendation from the above article when such cases happen:
```
If you cause a instant, hard, full power loss (such as Ctrl+C’ing the VM) before it can properly fsync(), you may see an error like error: expected string 'Derive(['. To resolve this error, run nix store gc. You can avoid this by running sync before killing the device.
```

TLDR: Run the following command:
```bash
nix store gc
```
