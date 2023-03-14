{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.cloudProviders.aws;
  shell_extracommon_str = ''
    ########## Module CloudProviders.AWS Init Extra Start ##########
    complete -C '${pkgs.awscli2}/bin/aws_completer' aws
    ########## Module CloudProviders.AWS Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs.awscli2
        pkgs.aws-vault
        pkgs.aws-iam-authenticator
        pkgs.ssm-session-manager-plugin
        pkgs.eksctl
      ];
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
    }
  ]);
}


