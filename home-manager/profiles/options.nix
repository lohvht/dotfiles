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
            pcie_bus_id = = "00";

        `devicePath`
          Actual device path TODO: NOT IN USE YET.
          enum:
            ["amdgpu" "nouveau" "nvidia"]
          example:
            devicePath = "/dev/nvme0n1p1";
      '';
    };
  };
  options.customHomeProfile = {
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
      nextcloudClient.enable = lib.mkEnableOption "check if we include gaming related options";
    };
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
    cloudDevelopment = {
      k8s = {
        enable = lib.mkEnableOption "enable tools used for cloud development";
      };
    };
  };
}
