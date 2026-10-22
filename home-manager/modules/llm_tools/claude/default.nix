{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.llmTools.claude;
  isVSCodeEnable = config.customHomeProfile.GUI.enable && config.customHomeProfile.GUI.vscode.enable;

  # Mirrors upstream's install.sh: each skill dir is linked from the pinned source,
  # into Claude's skills dir and the agent-neutral ~/.agents/skills.
  toolkit = cfg.agentToolkit;
  toolkitSrc = pkgs.agent-toolkit-src;
  toolkitSkills = lib.mapAttrs (name: _: "${toolkitSrc}/skills/${name}") (
    lib.filterAttrs (name: type: type == "directory" && !(builtins.elem name toolkit.excludedSkills))
      (builtins.readDir "${toolkitSrc}/skills")
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
        enableMcpIntegration = true;
        settings = {
          theme = "auto";
          includeCoAuthoredBy = false;
          permissions.defaultMode = "default";
          sandbox.autoAllowBashIfSandboxed = false;
          promptSuggestionEnabled = false;
        };
      };
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initContent = shell_extracommon_str;
    }
    (lib.mkIf toolkit.enable {
      programs.claude-code.skills = toolkitSkills;
      home.file = lib.mapAttrs' (name: src: lib.nameValuePair ".agents/skills/${name}" { source = src; }) toolkitSkills;
    })
    (lib.mkIf (toolkit.enable && toolkit.rules.enable) {
      programs.claude-code.rulesDir = "${toolkitSrc}/rules";
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
