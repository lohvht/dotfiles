{
  description = "lohvht's home-manager flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    # # Track channels with commits tested and built by hydra
    # nixpkgs-stable.url = github:nixos/nixpkgs/nixos-22.05;
    nixpkgs-unstable.url = github:nixos/nixpkgs/nixpkgs-unstable;
    # # For darwin hosts: it can be helpful to track this darwin-specific stable
    # # channel equivalent to the `nixos-*` channels for NixOS. For one, these
    # # channels are more likely to provide cached binaries for darwin systems.
    # # But, perhaps even more usefully, it provides a place for adding
    # # darwin-specific overlays and packages which could otherwise cause build
    # # failures on Linux systems.
    # nixpkgs-darwin-stable.url = "github:NixOS/nixpkgs/nixpkgs-22.05-darwin";

    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
  };
  outputs = {
    self,
    flake-utils,
    # nixpkgs-stable,
    nixpkgs-unstable,
    # nixpkgs-darwin-stable,
    home-manager,
    ...
  }:
  let
    # TODO: If you want to use packages exported from other flakes, add their overlays here.
    # They will be added to your 'pkgs'
    default_overlays = {
      default = import ./overlays;
    };
    # makeHomeMgrConfig sets some example / sane defaults when creating
    # a homeManagerConfiguration
    # To override these defaults, simple pass in the relevant param names
    makeHomeMgrConfig = {
      system ? flake-utils.lib.system.x86_64-linux,
      extraSpecialArgs ? {},
      ...
    }@args: home-manager.lib.homeManagerConfiguration ({
      # Using $USER and $HOME may be impure but it works generally as a sane default.
      # If needed, users should replace them with args passed in
      username = builtins.getEnv "USER";
      homeDirectory = /. + builtins.getEnv "HOME";
      system = system;
      pkgs = nixpkgs-unstable.legacyPackages.${system};
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
      } // extraSpecialArgs;
    } // builtins.removeAttrs args ["extraSpecialArgs" "system"]);
  in
  rec {
    # Home configurations
    # Accessible via 'home-manager'
    homeConfigurations.linux_64 = makeHomeMgrConfig rec { # NOTE: REPLACE username / homeDirectory if needed
      # system = flake-utils.lib.system.x86_64-linux;
      # pkgs = nixpkgs-stable.legacyPackages.${system};
      extraSpecialArgs = {
        is_GUI = true;
      };
    };
    homeConfigurations.linux_headless_64 = makeHomeMgrConfig rec { # NOTE: REPLACE username / homeDirectory if needed
      # system = flake-utils.lib.system.x86_64-linux;
      # pkgs = nixpkgs-stable.legacyPackages.${system};
      extraSpecialArgs = {
        extra_git_config = {
          # NOTE: Replace the usernames here
          userEmail = "example@example.com";
          userName = "Example Name";
        };
        tools_golang = {};
        tools_python = {};
        tools_node = {};
        # tools_rust = {}; # TODO: Rust installation not ready yet
        tools_latex = {};
      };
    };
    homeConfigurations.darwin_64 = makeHomeMgrConfig rec { # NOTE: REPLACE username / homeDirectory if needed
      system = flake-utils.lib.system.x86_64-darwin;
      pkgs = nixpkgs-unstable.legacyPackages.${system};
      # pkgs = nixpkgs-darwin-stable.legacyPackages.${system};
      extraSpecialArgs = {
        is_GUI = true;
      };
    };

    # Packages
    # Accessible via 'nix build'
    packages = flake-utils.lib.eachSystemMap flake-utils.lib.defaultSystems (system:
      # Propagate nixpkgs-unstable' packages, with our overlays applied
      import nixpkgs-unstable { inherit system; overlays = builtins.attrValues default_overlays; }
    );

    # Devshell for bootstrapping
    # Accessible via 'nix develop'
    devShells = flake-utils.lib.eachSystemMap flake-utils.lib.defaultSystems (system: {
      default = import ./shell.nix { pkgs = packages.${system}; };
    });
  };
}
