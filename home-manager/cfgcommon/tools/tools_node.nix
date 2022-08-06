config: lib: pkgs: extraArgs:
let
  cfgcommonlib = import ../lib/cfg_common_lib.nix
  inherit (extraArgs) tools_node;
in
lib.optionals tools_node != null [
  cfgcommonlib.mkCfgCommon {
    home_packages = [
      # Our custom node version manager, we will not use anything else but this to
      # install the actual versions of node/npm to use
      # Check this for more info: https://github.com/nvm-sh/nvm
      pkgs.nvm
    ];
    shell_extracommon = [
      ''#### GENERATED SHELL SECTION FOR tools_node START ###''
      ''
      # Init Node version manager (NVM) for nix
      . nvm_postinit
      ''
      ''#### GENERATED SHELL SECTION FOR tools_node END ###''
    ];
  }
]
