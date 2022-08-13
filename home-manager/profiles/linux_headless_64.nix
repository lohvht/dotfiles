{ config, lib, options, pkgs, ... }:
{
  imports = [
    ./options.nix
  ];
  customHomeProfile = {
    GUI.enable = false;
    golang.enable = true;
    python.enable = true;
    node.enable = true;
    latex.enable = true;
    # NOTE: Replace the usernames here
    git.userEmail = "example@example.com";
    git.username = "Example Name";
  };
}
