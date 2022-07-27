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
  }@flake-nix-inputs:
  {
    homeManagerConfigurations.darwin_64 = home-manager.lib.homeManagerConfiguration {
      username = "test";
      homeDirectory = "/home/test";
      system = flake-utils.lib.x86_64-darwin;
      # Main configuration file
      configuration = ./homes/home.nix;
      extraSpecialArgs = {
        is-headless: false;
        inherit flake-nix-inputs;
      };
      # # NOTE: uncomment these extra params
      # # check https://github.com/nix-community/home-manager/blob/release-22.05/flake.nix#L44
      # for the actual params accepted by home-manager.lib.homeManagerConfiguration
      # extraModules ? [ ]
      # pkgs ? builtins.getAttr system nixpkgs.outputs.legacyPackages
      # lib ? pkgs.lib
      # check ? true
      # stateVersion ? "20.09"
    };
  };
}
