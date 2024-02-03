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
        animeGameLauncherRunnerName = "lutris-GE-Proton7-35-x86_64";
      };
      vscode = {
        enable = true;
        crashReporterUUID = "13fcbd5c-0f51-4819-9701-70b7b4e5cf06";
      };
      communications.discord.enable = true;
      communications.thunderbird.enable = true;
      communications.slack.enable = true;
      nextcloudClient.enable = true;
    };
    # cloudDevelopment.k8s.enable = true;
    # cloudDevelopment.terraform.enable = true;
    databases.mariadb.enable = true;
    corsairKeyboardMouseSupport.enable = false;
    # golang.enable = true;
    rust.enable = true;
    # python.enable = true;
    # ruby.enable = true;
    # node.enable = true;
    latex.enable = true;
    passwordManagers.bitwarden.enable = true;
    blurayCd = {
      makemkv.enable = true;
      handbrake.enable = true;
      abcde.enable = true;
    };
    # NOTE: Replace the usernames here
    git.userEmail = "vic94loh@hotmail.com";
    git.username = "Victor Loh";
  };
}
