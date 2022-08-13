# Options: https://rycee.gitlab.io/home-manager/options.html
{ config, lib, pkgs, ... }:
{
  imports = [
    # Add custom home-manager modules here
    ./modules
  ];
}