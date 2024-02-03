{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.databases.mariadb;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs.mariadb
      ];
    }
  ]);
}
