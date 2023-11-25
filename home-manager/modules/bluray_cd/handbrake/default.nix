{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.blurayCd.handbrake;
  shell_extracommon_str = ''
    ########## Module blurayCd.handbrake Init Extra Start ##########
    ########## Module blurayCd.handbrake Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs.handbrake
      ];
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
    }
  ]);
}
