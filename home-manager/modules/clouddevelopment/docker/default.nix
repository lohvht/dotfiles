{ config, lib, pkgs, ... }@inputs:
let
  cfglib = import ../../cfglib inputs;

  serviceFiles = [
    (cfglib.mkSvcActiScHelper {
      serviceFile = "docker.service";
      preServiceInstall = ''
        $DRY_RUN_CMD sudo groupadd docker || true
        $DRY_RUN_CMD sudo usermod -aG docker ${config.home.username}
      '';
      preServiceUninstall = ''
        $DRY_RUN_CMD sudo gpasswd -d ${config.home.username} docker
        $DRY_RUN_CMD sudo groupdel docker || true
      '';
    })
    (cfglib.mkSvcActiScHelper { serviceFile = "docker.socket"; })
  ];
  cfg = config.customHomeProfile.cloudDevelopment.docker;
in
{
  config = (lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [
        pkgs.docker
        pkgs.docker-compose
      ];
      home.shellAliases = {
        docker-compose = "docker compose";
      };
    })
    {
      home.activation.reloadDockerSystemd = lib.hm.dag.entryAfter [ "linkGeneration" ] (cfglib.serviceActivationScript serviceFiles);
    }
  ]);
}
