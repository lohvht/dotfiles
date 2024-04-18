{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.databases.postgres;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs.postgresql
      ];
    }
  ]);
}
