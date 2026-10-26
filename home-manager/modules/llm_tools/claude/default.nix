{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.llmTools.claude;
  isVSCodeEnable = config.customHomeProfile.GUI.enable && config.customHomeProfile.GUI.vscode.enable;

  # Mirrors upstream's install.sh: each skill dir is linked from the pinned source,
  # into Claude's skills dir and the agent-neutral ~/.agents/skills.
  agentToolkitCfg = config.customHomeProfile.llmTools.agentToolkit;
  toolkitSrc = pkgs.agent-toolkit-src;
  toolkitSkills = lib.mapAttrs (name: _: "${toolkitSrc}/skills/${name}") (
    lib.filterAttrs (name: type: type == "directory" && !(builtins.elem name agentToolkitCfg.excludedSkills))
      (builtins.readDir "${toolkitSrc}/skills")
  );
  toolkitRules = lib.mapAttrs (name: _: "${toolkitSrc}/rules/${name}") (
    lib.filterAttrs (name: type: type == "regular" && !(builtins.elem name agentToolkitCfg.excludedRules))
      (builtins.readDir "${toolkitSrc}/rules")
  );

  shell_extracommon_str = ''
    ########## Module llmTools.claude Init Extra Start ##########
    ########## Module llmTools.claude Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.claude-code = {
        enable = true;
      };
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initContent = shell_extracommon_str;
    }
    (lib.mkIf (!cfg.noOverrideSettings) {
      programs.claude-code = {
        enableMcpIntegration = true;
        settings = {
          theme = "auto";
          includeCoAuthoredBy = false;
          permissions.defaultMode = "default";
          sandbox.autoAllowBashIfSandboxed = false;
          promptSuggestionEnabled = false;
        };
      };
    })
    (lib.mkIf agentToolkitCfg.enable {
      programs.claude-code.skills = toolkitSkills;
    })
    (lib.mkIf (agentToolkitCfg.enable && agentToolkitCfg.rules.enable) {
      programs.claude-code.rules = toolkitRules;
    })
    (lib.mkIf isVSCodeEnable {
      programs.vscodium = {
        profiles.default.extensions = [
          pkgs.nix-vscode-extensions.vscode-marketplace.anthropic.claude-code
        ];
      };
    })
  ]);
}
