{ config, lib, options, pkgs, ... }:
{
  imports = [
    ./options.nix
  ];
  linuxInfo = {
    distro = "arch";
  };
  systemHardwareInfo = {
    cpuMake = "ryzen";
    gpus = [{ name = "Radeon RX 5700/5700 XT"; pcie_bus_id = "0b"; pcie_device_id = "00"; driver = "amdgpu"; }];
    networkInterface = "wlp4s0";
    disks = [{ name = "System"; mountedPath = "/"; }];
  };
  customHomeProfile = {
    GUI.enable = true;
    GUI.gaming.enable = true;
    golang.enable = true;
    python.enable = true;
    ruby.enable = true;
    node.enable = true;
    latex.enable = true;
    # NOTE: Replace the usernames here
    git.userEmail = "vic94loh@hotmail.com";
    git.username = "Victor Loh";
  };
}
