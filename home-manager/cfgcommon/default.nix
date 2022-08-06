config: lib: pkgs: extraArgs:
let
  cfgcommonlib = import ./lib/cfg_common_lib.nix;

  # Combine all the combined_cfgcommons
  combined_cfgcommons = cfgcommonlib.mergeCfgCommons (builtins.concatLists [
    import ./cfg_common_defaults.nix config lib pkgs extraArgs
    import ./tools/tools_golang.nix config lib pkgs extraArgs
    import ./tools/tools_latex.nix config lib pkgs extraArgs
    import ./tools/tools_node.nix config lib pkgs extraArgs
    import ./tools/tools_python.nix config lib pkgs extraArgs
    import ./tools/tools_rust.nix config lib pkgs extraArgs
  ]);

  # Will need to do some processing for some of combined config vars
  inherit (combined_cfgcommons) shell_functions;
  inherit (combined_cfgcommons) shell_extracommoninit;
  inherit (combined_cfgcommons) shell_extracommon;
  inherit (combined_cfgcommons) home_packages;
  inherit (combined_cfgcommons) home_programs;
  inherit (combined_cfgcommons) home_files;

  # Combined all the shell related variables
  # So that we can use it in shell settings
  shell_config = {
    shell_function_str = buitins.concatStringsSep "\n" shell_functions;
    shell_extracommon = buitins.concatStringsSep "\n" shell_extracommon;
    shell_extracommoninit = buitins.concatStringsSep "\n" shell_extracommoninit;
  };
  bash_cfg = import ../shell/bash pkgs extraArgs shell_config;
  zsh_cfg = import ../shell/zsh pkgs extraArgs shell_config;

  home_packages = home_packages ++ bash_cfg.home_packages ++ zsh_cfg.home_packages;
  home_programs = cfgcommonlib.recursiveUpdateMergeAttrs [home_programs bash_cfg.home_programs zsh_cfg.home_programs];
  home_files = cfgcommonlib.recursiveUpdateMergeAttrs [home_files bash_cfg.home_files zsh_cfg.home_files];
in
{
  inherit (combined_cfgcommons) shell_variables;
  inherit (combined_cfgcommons) shell_paths;
  inherit (combined_cfgcommons) shell_aliases;
  inherit home_packages;
  inherit home_files;
  inherit home_programs;
}
