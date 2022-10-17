{ config, lib, options, pkgs, ... }:
{
  imports = [
    ./options.nix
  ];
  linuxInfo = {
    distro = "ubuntu";
  };
  customHomeProfile = {
    systemCtlPath = "/usr/bin/systemctl";
    GUI.enable = false;
    golang.enable = true;
    python.enable = true;
    cloudDevelopment = {
      docker.enable = true;
      terraform.enable = true;
    };
    # NOTE: Replace the usernames here
    git.userEmail = "vic94loh@hotmail.com";
    git.username = "Victor Loh";
  };
}
