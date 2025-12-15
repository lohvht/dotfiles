{ config, lib, options, pkgs, ... }:
{
  imports = [
    ./options.nix
  ];
  linuxInfo = {
    distro = "arch";
  };
  systemHardwareInfo = {
    cpuMake = null; # "ryzen";
    gpus = [
      # { name = null; pcie_bus_id = "01"; pcie_device_id = "00"; driver = "nvidia"; }
    ];
    networkInterface = "wlan0";
    disks = [
      { name = "Home"; mountedPath = "/home/deck"; }
      # { name = "HDD1"; mountedPath = "${config.home.homeDirectory}/HDD/HDD1"; }
    ];
    batteries = [ "BAT1" ];
  };
  customHomeProfile = {
    systemCtlPath = "/usr/bin/systemctl";
    GUI = {
      enable = true;
      gaming = {
        # enable = true;
        # animeGameLauncherRunnerName = "lutris-GE-Proton7-35-x86_64";
      };
      vscode = {
        enable = true;
        crashReporterUUID = "29af007d-1a2c-4099-9884-4ab5757e607c";
      };
      communications.discord.enable = true;
      communications.thunderbird.enable = true;
      # communications.slack.enable = false;
      nextcloudClient.enable = true;
      # libreoffice.enable = false;
    };
    # cloudDevelopment.k8s.enable = true;
    # cloudDevelopment.terraform.enable = true;
    # databases.mariadb.enable = true;
    # corsairKeyboardMouseSupport.enable = false;
    # golang.enable = true;
    # rust.enable = true;
    # python.enable = true;
    # ruby.enable = true;
    # node.enable = true;
    # latex.enable = true;
    passwordManagers.bitwarden.enable = true;
    # blurayCd = {
    #   makemkv.enable = true;
    #   handbrake.enable = true;
    # };
    # musicCd.enable = true;
    # NOTE: Replace the usernames here
    git.userEmail = "vic94loh@hotmail.com";
    git.username = "Victor Loh";
  };
}
