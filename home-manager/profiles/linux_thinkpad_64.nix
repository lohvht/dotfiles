{ config, lib, options, pkgs, ... }:
{
  imports = [
    ./options.nix
  ];
  linuxInfo = {
    distro = "arch";
  };
  systemHardwareInfo = {
    cpuMake = "intel";
    gpus = [{ name = null; pcie_bus_id = "01"; pcie_device_id = "00"; driver = "nvidia"; }];
    networkInterface = "wlan0";
    disks = [
      { name = "System"; mountedPath = "/"; }
      # { name = "HDD1"; mountedPath = "${config.home.homeDirectory}/HDD/HDD1"; }
    ];
    batteries = [ "BAT0" ];
  };
  customHomeProfile = {
    systemCtlPath = "/usr/bin/systemctl";
    GUI = {
      enable = true;
      gaming = {
        enable = true;
        # animeGameLauncherRunnerName = "lutris-GE-Proton7-35-x86_64";
      };
      vscode = {
        enable = true;
        crashReporterUUID = "c3628cc0-4d73-4a3b-998a-f092d5815195";
      };
      communications.discord.enable = true;
      communications.thunderbird.enable = true;
      communications.slack.enable = true;
      nextcloudClient.enable = true;
      libreoffice.enable = true;
    };
    # cloudDevelopment.k8s.enable = true;
    # cloudDevelopment.terraform.enable = true;
    databases.mariadb.enable = true;
    corsairKeyboardMouseSupport.enable = false;
    # golang.enable = true;
    rust.enable = true;
    python.enable = true;
    # ruby.enable = true;
    # node.enable = true;
    latex.enable = true;
    passwordManagers.bitwarden.enable = true;
    blurayCd = {
      makemkv.enable = true;
      handbrake.enable = true;
    };
    musicCd.enable = true;
    # NOTE: Replace the usernames here
    git.userEmail = "vic94loh@hotmail.com";
    git.username = "Victor Loh";
  };
}
