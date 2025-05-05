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

  argocd_competions_str = ''
    ########## Module CloudDevelopment.K8S.Argocd Init Extra Start ##########
    if [ -n "$ZSH_VERSION" ]; then
      source <(kubectl argo rollouts completion zsh)
      source <(argocd completion zsh)
    elif [ -n "$BASH_VERSION" ]; then
      # NOTE: we may need to run the following `source /usr/share/bash-completion/bash_completion` 
      source <(kubectl argo rollouts completion bash)
      source <(argocd completion bash)
    else
      source <(kubectl argo rollouts completion bash)
      source <(argocd completion bash)
    fi
    ########## Module CloudDevelopment.K8S Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs.kubectl
        pkgs.kind
        pkgs.kubernetes-helm
        pkgs.trivy # container scanner
        pkgs.grype # container scanner
        pkgs.kustomize
      ];
      home.shellAliases = {
        # kubernetes
        k = "kubectl";
      };
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initContent = shell_extracommon_str;
    }
    (lib.mkIf cfg.argocd.enable {
      home.packages = [
        pkgs.argocd
        pkgs.argo-rollouts
      ];
      programs.bash.initExtra = argocd_competions_str;
      programs.zsh.initContent = argocd_competions_str;
    })

  ]);
}
