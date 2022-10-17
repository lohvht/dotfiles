{ config, lib, pkgs, ... }:
let
  cfglib = import ../../cfglib inputs;

  serviceFiles = [
    (mkSvcActiScHelper {
      serviceFile = "docker.socket";
      postServiceInstall = ''
        sudo groupadd docker
        sudo usermod -aG docker $USER
      '';
      preServiceUninstall = ''
        sudo usermod -G docker $USER
        sudo groupdel docker
      '';
    })
    (mkSvcActiScHelper { serviceFile = "docker.service"; })
  ];
  systemCtl = ;

    cfg = config.customHomeProfile.cloudDevelopment.docker;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs.docker
        pkgs.docker-compose
      ];
      home.shellAliases = { };
      home.activation.reloadDockerSystemd = lib.hm.dag.entryAfter [ "linkGeneration" ] (cfglib.serviceActivationScript serviceFiles);
    }
  ]);
}
