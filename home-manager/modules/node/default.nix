{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.node;
  isGUIEnable = config.customHomeProfile.GUI.enable;
  NVM_DIR = "${config.home.homeDirectory}/.nvm";
  shell_extracommon_str = ''
    ########## Module Node Init Extra Start ##########
    # Init Node version manager (NVM) for nix
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    ########## Module Node Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.sessionVariables = { inherit NVM_DIR; };
      home.file."${NVM_DIR}" = {
        recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "nvm-sh";
          repo = "nvm";
          rev = "v0.39.1";
          sha256 = "0x5w4v9hpns1p60d21q9diyq3lykpk2dlpcczcwdd24q6hmx5a4f";
        };
      };
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
    }
    (lib.mkIf (isGUIEnable && cfg.includeFrontendTools) {
      programs.vscode = {
        extensions = [
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "pug";
            publisher = "amandeepmittal";
            version = "1.0.1";
            sha256 = "0041jnxirgibs75481hn6dk5kw2kc4yy82f5jlgv7l47hlmhqww4";
          }
          {
            name = "vscode-html-css";
            publisher = "ecmel";
            version = "1.13.1";
            sha256 = "0cdbkxry3rzffdlza2y157pvp947kfxz3nllm91diyi7725xq5w0";
          }
          {
            name = "vscode-scss";
            publisher = "mrmlnc";
            version = "0.10.0";
            sha256 = "08kdvg4p0aysf7wg1qfbri59cipllgf69ph1x7aksrwlwjmsps12";
          }
          {
            name = "volar";
            publisher = "vue";
            version = "0.40.4";
            sha256 = "1w6qnd6qy2lazvfpi2ybcpqyfgi77fdhrb9ywsa5992ycvg8kvzv";
          }
        ];
      };
    })
  ]);
}
