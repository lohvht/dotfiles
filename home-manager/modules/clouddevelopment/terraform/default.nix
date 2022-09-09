{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.cloudDevelopment.terraform;
  shell_extracommon_str = ''
    ########## Module CloudDevelopment.terraform Init Extra Start ##########
    complete -o nospace -C ${pkgs.terraform}/bin/terraform terraform
    ########## Module CloudDevelopment.terraform Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs.terraform
        pkgs.terragrunt
      ];
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
    }
  ]);
}
