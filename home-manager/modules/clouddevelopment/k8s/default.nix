{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.cloudDevelopment.k8s;
  shell_extracommon_str = ''
    ########## Module CloudDevelopment.K8S Init Extra Start ##########
    if [ -n "$ZSH_VERSION" ]; then
      source <(kubectl completion zsh)
      source <(kind completion zsh)
    elif [ -n "$BASH_VERSION" ]; then
      # NOTE: we may need to run the following `source /usr/share/bash-completion/bash_completion` 
      source <(kubectl completion bash)
      source <(kind completion bash)
    else
      source <(kubectl completion sh)
      source <(kind completion sh)
    fi
    complete -o default -F __start_kubectl k
    ########## Module CloudDevelopment.K8S Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs.kubectl
        pkgs.kind
      ];
      home.shellAliases = {
        # kubernetes
        k = "kubectl";
      };
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
    }
  ]);
}
