# Options: https://rycee.gitlab.io/home-manager/options.html
{ config, lib, pkgs, ... }:
{
  programs.home-manager.path = pkgs.lib.mkForce "${config.home.homeDirectory}/.config/nixpkgs/home-manager";
  imports = [
    # Add custom home-manager modules here
    ./modules
  ];
}
