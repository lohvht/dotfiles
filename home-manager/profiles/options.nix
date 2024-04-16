{ config, lib, options, pkgs, ... }:
{
  options.linuxInfo = {
    distro = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "arch" "ubuntu" ]);
      # TODO: only support arch for now
      example = "arch";
      description = "which distro the current linux is running on";
    };
  };
  options.systemHardwareInfo = {
    cpuMake = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "ryzen" "intel" ]);
      default = null;
      description = "What make is the CPU, e.g. amd Ryzen series, or intel etc.";
    };
    gpus = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = ''
        list of attrs set containing the following keys: `name`, `pcie_bus_id`, `pcie_device_id`, `driver`

        `name`
          The name of the GPU, for display purposes.
          example:
            name = "Radeon RX 5700/5700 XT";

        `pcie_device_id`
        `pcie_bus_id`
          The PCIE details for the given GPU, can get this value via `lspci | grep VGA`, where if the first thing in the line is the PCIE slot number
            e.g.
            $ lspci | grep VGA
            0b:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Navi 10 [Radeon RX 5600 OEM/5600 XT / 5700/5700 XT] (rev c1)
          Where 0b:00.0 is of the form `[domain:]bus:device.function`, thus the bus ID is `0b`, and the device ID is `00` in this case
          example:
            pcie_device_id = "0b";
            pcie_bus_id = = "00";

        `driver`
          What driver the GPU is running on, this determines the range of tools to use to query / finetune the given GPU.
          enum:
            ["amdgpu" "nouveau" "nvidia"]
          example:
            driver = "amdgpu";
      '';
    };
    networkInterface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "wlp4s0";
      description = "What is the network interface used";
    };
    disks = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = ''
        list of attrs set containing the following keys: `name`, `mountedPath`, `devicePath`.

        `name`
          The name of the Disk, for display purposes.
          example:
            name = "System";

        `mountedPath`
          Where this disk was mounted.
          example:
            mountedPath = "/";

        `devicePath`
          Actual device path TODO: NOT IN USE YET.
          example:
            devicePath = "/dev/nvme0n1p1";
      '';
    };
  };
  options.customHomeProfile = {
    sslCertsFile = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      description = "The SSL certs path to use";
    };
    systemCtlPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "systemctl path";
    };
    GUI = {
      enable = lib.mkEnableOption "check if we should include GUI options for home manager profiles";
      gaming = {
        enable = lib.mkEnableOption "check if we include gaming related options";
        animeGameLauncherRunnerName = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "The runner name for anime game launcher";
        };
      };
      vscode = {
        enable = lib.mkEnableOption "check if vscode should be used and the default editor should be set to code";
        crashReporterUUID = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "The crash reporter UUID to set. if not set, default to a default hardcoded one. You should override this option by generating a UUID via `uuidgen`";
        };
      };
      communications = {
        ms_teams.enable = lib.mkEnableOption "install Microsoft Teams";
        zoom.enable = lib.mkEnableOption "install zoom";
        discord.enable = lib.mkEnableOption "install discord";
        thunderbird.enable = lib.mkEnableOption "install thunderbird email client";
        slack.enable = lib.mkEnableOption "Install slack";
      };
      nextcloudClient.enable = lib.mkEnableOption "install nextcloud client";
      development = {
        apiClient.enable = lib.mkEnableOption "install an API client, the current client used is `bruno`";
      };
    };
    corsairKeyboardMouseSupport.enable = lib.mkEnableOption ''
      if true, adds corsair keyboard and mouse support

      TODO: Maybe use home manager's systemd support? need to check if the daemon can be run in userspace first
      May need to set the systemctl path, like mentioned here: https://github.com/nix-community/home-manager/blob/master/modules/systemd.nix#L113-L115      

      Take note that whenever this is first enabled, the daemon must also be started and enabled for the driver to work:
        sudo systemctl enable $HOME/.nix-profile/lib/systemd/system/ckb-next-daemon.service && sudo systemctl start ckb-next-daemon

      After running the abe command, go ahead and start the cbk-next command to open up the settings.

      Similarly when setting it to false, you should also stop and remove the ckb daemon
        sudo systemctl disable ckb-next-daemon && sudo systemctl stop ckb-next-daemon
        
    '';
    git = {
      username = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The git username to use. if null, dont set any";
      };
      userEmail = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The git email to use. if null, dont set any";
      };
    };
    golang.enable = lib.mkEnableOption "enable golang configuration";
    latex.enable = lib.mkEnableOption "enable latex configuration";
    node = {
      enable = lib.mkEnableOption "enable node configuration";
      includeFrontendTools = lib.mkEnableOption "Add in vscode frontend tools";
    };
    python.enable = lib.mkEnableOption "enable python configuration";
    rust.enable = lib.mkEnableOption "enable rust configuration";
    ruby.enable = lib.mkEnableOption "enable ruby configuration";
    cloudProviders = {
      aws = {
        enable = lib.mkEnableOption "enable AWS CLI integration";
      };
    };
    databases = {
      mariadb.enable = lib.mkEnableOption "Add MariaDB to config. Mostly used to allow access to a MariaDB/MySQL client";
    };
    blurayCd = {
      makemkv.enable = lib.mkEnableOption ''
        enable makemkv that rips to mkv. May require that the `sg` kernel
        module is loaded, for certain drives

        dynamically via
        `modprobe sg`

        or via the command below, followed by a restart of the system
        `echo sg > /etc/modules-load.d/sg.conf`

        makemkv has a free trial over their beta every 30 days, check back
        here if it expires:
        https://forum.makemkv.com/forum/viewtopic.php?f=5&t=1053

        For more info regarding this, read the FAQ about BETA and permanent keys
        https://forum.makemkv.com/forum/viewtopic.php?f=1&t=20579
      '';
      handbrake.enable = lib.mkEnableOption "enable transcoder tools";
      abcde.enable = lib.mkEnableOption "enable audio CD ripping tool abcde";
    };
    cloudDevelopment = {
      k8s = {
        enable = lib.mkEnableOption "enable tools used for k8s development";
        argocd.enable = lib.mkEnableOption "Add argocd tools";
      };
      docker.enable = lib.mkEnableOption "enable tools used for docker installation";
      terraform.enable = lib.mkEnableOption "enable tools used for terraform development";
    };
    passwordManagers = {
      _1password.enable = lib.mkEnableOption "enable 1password";
      bitwarden.enable = lib.mkEnableOption "enable bitwarden";
    };
  };
}
