config: lib: pkgs: extraArgs:
let
# TODO: Finish up this section
  cfgcommonlib = import ../lib/cfg_common_lib.nix;
  inherit (extraArgs) tools_rust;
in
lib.optionals (tools_rust != null) [
  (cfgcommonlib.mkCfgCommon {
    shell_extracommon = [
      ''#### GENERATED SHELL SECTION FOR tools_rust START ###''
      ''
      if [[ -r ${config.home.homeDirectory}/.cargo/env ]]; then
          source "${config.home.homeDirectory}/.cargo/env"
      else
          echo "WARNING: Can't find cargo env for rustup"
      fi
      ''
      ''#### GENERATED SHELL SECTION FOR tools_rust END ###''
    ];
  })
]