{
  description = "lohvht's home-manager flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    # Track channels with commits tested and built by hydra
    nixpkgs-stable.url = github:nixos/nixpkgs/nixos-22.05;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixos-unstable;
    # For darwin hosts: it can be helpful to track this darwin-specific stable
    # channel equivalent to the `nixos-*` channels for NixOS. For one, these
    # channels are more likely to provide cached binaries for darwin systems.
    # But, perhaps even more usefully, it provides a place for adding
    # darwin-specific overlays and packages which could otherwise cause build
    # failures on Linux systems.
    nixpkgs-darwin-stable.url = "github:NixOS/nixpkgs/nixpkgs-22.05-darwin";

    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
  };
  outputs = {
    self,
    flake-utils,
    nixpkgs-stable,
    nixpkgs-unstable,
    nixpkgs-darwin-stable,
    home-manager,
    ...
  }@flake_nix_inputs:
  let
    # TODO: If you want to use packages exported from other flakes, add their overlays here.
    # They will be added to your 'pkgs'
    default_overlays = {
      default = import ./pkgs/overlay.nix;
    };
    # makeHomeMgrConfig sets some example / sane defaults when creating
    # a homeManagerConfiguration
    # To override these defaults, simple pass in the relevant param names
    makeHomeMgrConfig = { extraSpecialArgs ? {}, ...}@args: home-manager.lib.homeManagerConfiguration ({
      system = flake-utils.lib.system.x86_64-linux;
      # Main configuration file
      configuration = import ./home-manager/home.nix;
      stateVersion = "22.05";
      extraModules = [
        # Add custom home-manager modules here
        ./home-manager/modules.nix
        # Adds overlays
        { nixpkgs.overlays = builtins.attrValues default_overlays; }
      ];
      extraSpecialArgs = {
        is_GUI = false;
        inherit flake_nix_inputs;
      } // extraSpecialArgs;
    } // builtins.removeAttrs args ["extraSpecialArgs"]);
  in
  rec {
    # Home configurations
    # Accessible via 'home-manager'
    homeConfigurations.linux_64 = makeHomeMgrConfig { # NOTE: REPLACE username / homeDirectory
      username = "test";
      homeDirectory = "/home/test";
    };
    homeConfigurations.linux_headless_64 = makeHomeMgrConfig { # NOTE: REPLACE username / homeDirectory
      username = "test";
      homeDirectory = "/home/test";
    };
    homeConfigurations.darwin_64 = makeHomeMgrConfig { # NOTE: REPLACE username / homeDirectory
      username = "test";
      homeDirectory = "/home/test";
      system = flake-utils.lib.system.x86_64-darwin;
    };

    # Packages
    # Accessible via 'nix build'
    packages = flake-utils.lib.eachSystemMap flake-utils.lib.defaultSystems (system:
      # Propagate nixpkgs-stable' packages, with our overlays applied
      import nixpkgs-stable { inherit system; overlays = builtins.attrValues default_overlays; }
    );

    # Devshell for bootstrapping
    # Accessible via 'nix develop'
    devShells = flake-utils.lib.eachSystemMap flake-utils.lib.defaultSystems (system: {
      default = import ./shell.nix { pkgs = packages.${system}; };
    });
  };
}
