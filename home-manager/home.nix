# Options: https://rycee.gitlab.io/home-manager/options.html
{
  config,
  lib,
  pkgs,
  specialArgs, # passed in via extraSpecialArgs
  ...
}:
let
  inherit (specialArgs) is_GUI flake_nix_inputs;
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux isDarwin;
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # Allow installation of non-free pkgs
  nixpkgs.config.allowUnfree = true;
}