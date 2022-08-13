{ config, lib, options, pkgs, ... }:
{
  imports = [
    ./options.nix
  ];
  customHomeProfile = {
    GUI.enable = true;
  };
}
