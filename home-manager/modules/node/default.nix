{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.node;
  isVSCodeEnable = config.customHomeProfile.GUI.enable && config.customHomeProfile.GUI.vscode.enable;
  NVM_DIR = "${config.home.homeDirectory}/.nvm";
  shell_extracommon_str = ''
    ########## Module Node Init Extra Start ##########
    # Init Node version manager (NVM) for nix
    #
    # NVM lazy loading script
    #
    # NVM takes on average half of a second to load, which is more than whole prezto takes to load.
    # This can be noticed when you open a new shell.
    # To avoid this, we are creating placeholder function
    # for nvm, node, and all the node packages previously installed in the system
    # to only load nvm when it is needed.
    #
    # This code is based on the scripts:
    # * https://gist.github.com/rtfpessoa/811701ed8fa642f60e411aef04b2b64a
    # * https://www.reddit.com/r/node/comments/4tg5jg/lazy_load_nvm_for_faster_shell_start/d5ib9fs
    # * http://broken-by.me/lazy-load-nvm/
    # * https://github.com/creationix/nvm/issues/781#issuecomment-236350067
    #

    # Skip adding binaries if there is no node version installed yet
    if [ -d $NVM_DIR/versions/node ]; then
      NODE_GLOBALS=(`find $NVM_DIR/versions/node -maxdepth 3 \( -type l -o -type f \) -wholename '*/bin/*' | xargs -n1 basename | sort | uniq`)
    fi
    NODE_GLOBALS+=("nvm")
    load_nvm () {
      # Unset placeholder functions
      for cmd in "''${NODE_GLOBALS[@]}"; do unset -f ''${cmd} &>/dev/null; done

      # Load NVM
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

      # (Optional) Set the version of node to use from ~/.nvmrc if available
      nvm use 2> /dev/null 1>&2 || true

      # Do not reload nvm again
      export NVM_LOADED=1
    }
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    for cmd in "''${NODE_GLOBALS[@]}"; do
      # Skip defining the function if the binary is already in the PATH
      if ! which ''${cmd} &>/dev/null; then
        eval "''${cmd}() { unset -f ''${cmd} &>/dev/null; [ -z \''${NVM_LOADED+x} ] && load_nvm; ''${cmd} \$@; }"
      fi
    done
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
          rev = "v0.39.3";
          sha256 = "08anglj4vz7mkip1nwvhzva1ypqci5nz2bjc9sw902pm52yzslqj";
        };
      };
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
    }
    (lib.mkIf (isVSCodeEnable && cfg.includeFrontendTools) {
      programs.vscode = {
        profiles.default.extensions = [
          pkgs.vscode-extensions.ecmel.vscode-html-css
          pkgs.vscode-extensions.vue.volar
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        ];
      };
    })
  ]);
}
