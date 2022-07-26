{
  description = "lohvht's home-manager flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.homeManager.url = "github:nix-community/home-manager";
  inputs.homeManager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, homeManager }: {
    homeManagerConfigurations = {
      test = homeManager.lib.homeManagerConfiguration {
        configuration = { pkgs, lib, ... }: {
          imports = [ ./test/home.nix ];
          nixpkgs = {
            overlays = [ emacs.overlay ];
            config = { allowUnfree = true; };
          };
        };
        system = "x86_64-linux";
        homeDirectory = "/home/test";
        username = "test";
      };
    };
  };
}
