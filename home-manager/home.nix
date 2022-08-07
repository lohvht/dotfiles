# Options: https://rycee.gitlab.io/home-manager/options.html
{
  config,
  lib,
  pkgs,
  specialArgs, # passed in via extraSpecialArgs
  ...
}:
let
  inherit (lib) mkIf;

  extraArgs = {
    is_GUI = false;
    # Extra git config in the form that home-manager's programs.git.* can accept
    # See following for more info: https://rycee.gitlab.io/home-manager/options.html#opt-programs.git.enable
    extra_git_config = null;
    # Extra tools to install, if not specified will remain as null
    tools_golang = null;
    tools_python = null;
    tools_node = null;
    tools_rust = null;
    tools_latex = null;
  } // specialArgs;

  cfgcommonlib = import ./cfgcommon/lib/cfg_common_lib.nix;
  cfgcmn = import ./cfgcommon config lib pkgs extraArgs;
  inherit (cfgcmn) shell_variables shell_paths shell_aliases home_packages home_files home_programs;
  
  final_home_programs = cfgcommonlib.recursiveUpdateMergeAttrs [
    {
      # Let Home Manager install and manage itself.
      home-manager.enable = true;
    }
    home_programs
  ];
in
{
  # Allow installation of non-free pkgs
  nixpkgs.config.allowUnfree = true;

  # Allow allow fontconfig to discover fonts and configurations installed through home.packages and nix-env. 
  fonts.fontconfig.enable = true;

  home.sessionVariables = shell_variables;
  home.sessionPath = shell_paths;
  home.shellAliases = shell_aliases;
  home.packages = home_packages;
  home.file = home_files;
  programs = final_home_programs;
}