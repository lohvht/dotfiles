{ config, lib, options, pkgs, ... }:
{
  imports = [
    ./options.nix
  ];
  customHomeProfile = {
    GUI.enable = true;
    GUI.gaming.enable = true;
    golang.enable = true;
    python.enable = true;
    node.enable = true;
    latex.enable = true;
    # NOTE: Replace the usernames here
    git.userEmail = "vic94loh@hotmail.com";
    git.username = "Victor Loh";
  };
}
