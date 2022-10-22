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
    disks = [
      { name = "System"; mountedPath = "/"; }
      { name = "HDD1"; mountedPath = "${config.home.homeDirectory}/HDD/HDD1"; }
    ];
  };
  customHomeProfile = {
    systemCtlPath = "/usr/bin/systemctl";
    GUI = {
      enable = true;
      gaming = {
        enable = true;
        animeGameLauncherRunnerName = "lutris-GE-Proton7-31-x86_64";
      };
      vscode = {
        enable = true;
        crashReporterUUID = "13fcbd5c-0f51-4819-9701-70b7b4e5cf06";
      };
      nextcloudClient.enable = true;
    };
    corsairKeyboardMouseSupport.enable = true;
    golang.enable = true;
    python.enable = true;
    # ruby.enable = true;
    # node.enable = true;
    latex.enable = true;
    # NOTE: Replace the usernames here
    git.userEmail = "vic94loh@hotmail.com";
    git.username = "Victor Loh";
  };
}
