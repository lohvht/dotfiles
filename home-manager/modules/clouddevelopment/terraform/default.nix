{ config, lib, pkgs, ... }:
let
  isVSCodeEnable = config.customHomeProfile.GUI.enable && config.customHomeProfile.GUI.vscode.enable;
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
      home.shellAliases = {
        tf = "terraform";
        tg = "terragrunt";
      };
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initContent = shell_extracommon_str;
    }
    (lib.mkIf isVSCodeEnable {
      programs.vscode = {
        profiles.default.extensions = [
          pkgs.vscode-extensions.hashicorp.terraform
          pkgs.vscode-extensions.hashicorp.hcl
        ];
      };
    })
  ]);
}
