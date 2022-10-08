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
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
    }
    (lib.mkIf isVSCodeEnable {
      programs.vscode = {
        extensions = [
          pkgs.vscode-extensions.hashicorp.terraform
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "HCL";
            publisher = "HashiCorp";
            version = "0.2.1";
            sha256 = "15ydllrridf1kc7867h0r7ykc2mnn5d94d1nvklzx0nnkq64pl75";
          }
        ];
      };
    })
  ]);
}
