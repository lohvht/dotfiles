config: lib: pkgs: extraArgs:
let
  cfgcommonlib = import ../lib/cfg_common_lib.nix;
  inherit (extraArgs) tools_node;
  NVM_DIR = "${config.home.homeDirectory}/.nvm";
in
lib.optionals (tools_node != null) [
  (cfgcommonlib.mkCfgCommon {
    shell_variables = {
      inherit NVM_DIR; 
    };
    home_files = {
      "${NVM_DIR}" = {
        recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "nvm-sh";
          repo = "nvm";
          rev = "v0.39.1";
          sha256 = "0x5w4v9hpns1p60d21q9diyq3lykpk2dlpcczcwdd24q6hmx5a4f";
        };
      };
    };

    shell_extracommon = [
      ''#### GENERATED SHELL SECTION FOR tools_node START ###''
      ''
      # Init Node version manager (NVM) for nix
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
      ''
      ''#### GENERATED SHELL SECTION FOR tools_node END ###''
    ];
  })
]
