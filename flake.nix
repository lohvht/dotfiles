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

    nixgl.url = "github:guibou/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  outputs =
    { self
    , flake-utils
    , # nixpkgs-stable,
      nixpkgs-unstable
    , # nixpkgs-darwin-stable,
      home-manager
    , nur
    , nixgl
    , ...
    }:
    let
      # NOTE: If you want to use packages exported from other flakes, add their overlays here.
      # They will be added to your 'pkgs'
      default_overlays = {
        nur = nur.overlay;
        nixgl = nixgl.overlay;
        default = import ./overlays;
      };
      mkHomeMgrCfg = homeProfileName: { system ? flake-utils.lib.system.x86_64-linux
                                      ,
                                      }@args:
        nixpkgs-unstable.lib.nameValuePair homeProfileName (
          home-manager.lib.homeManagerConfiguration ({
            # Using $USER and $HOME may be impure but it works generally as a sane default.
            # If needed, users should replace them with args passed in
            username = builtins.getEnv "USER";
            homeDirectory = /. + builtins.getEnv "HOME";
            system = system;
            pkgs = nixpkgs-unstable.legacyPackages.${system};
            configuration = import ./home-manager/home.nix;
            extraModules = [
              ./home-manager/profiles/${homeProfileName}.nix
              # Adds overlays
              { nixpkgs.overlays = builtins.attrValues default_overlays; }
            ];
          } // builtins.removeAttrs args [ "system" ])
        );
      # Formatter, in the form of formatter.<system> = pkgs.<system>
      fm = flake-utils.lib.eachSystem flake-utils.lib.defaultSystems (system: {
        default = nixpkgs-unstable.legacyPackages.${system}.nixpkgs-fmt;
      });
    in
    rec {
      formatter = fm.default;
      # Home configurations
      # Accessible via 'home-manager', profile names correspond to filenames in ./home-manager/profile
      homeConfigurations = nixpkgs-unstable.lib.mapAttrs' mkHomeMgrCfg {
        # NOTE: REPLACE username / homeDirectory if needed
        ###### HOMECONFIG PROFILES START
        linux_64 = { };
        linux_headless_64 = { };
        darwin_64 = { system = flake-utils.lib.system.x86_64-darwin; };
        linux_gaming_64 = { };
        ###### HOMECONFIG PROFILES END
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
