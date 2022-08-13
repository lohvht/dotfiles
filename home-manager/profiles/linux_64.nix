{ config, lib, options, pkgs, ... }:
{
  imports = [
    ./options.nix
  ];
  customHomeProfile = {
    GUI.enable = true;
    golang.enable = true;
    python.enable = true;
    node.enable = true;
    latex.enable = true;
  };
}
