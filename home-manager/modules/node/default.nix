{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.node;
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
  ]);
}
