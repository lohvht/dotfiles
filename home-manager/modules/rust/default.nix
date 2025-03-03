{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.rust;
  isVSCodeEnable = config.customHomeProfile.GUI.enable && config.customHomeProfile.GUI.vscode.enable;

  shell_extracommon_str = ''
    ########## Module Rust Init Extra Start ##########
    # NOTE: may not be needed, nix seems to handle this for us.
    # if [ -n "$ZSH_VERSION" ]; then
    #   source <(rustup completions zsh)
    #   source <(rustup completions zsh cargo)
    # elif [ -n "$BASH_VERSION" ]; then
    #   # NOTE: we may need to run the following `source /usr/share/bash-completion/bash_completion` 
    #   source <(rustup completions bash)
    #   source <(rustup completions bash cargo)
    # fi

    if ! command -v 'rustc' &>/dev/null; then
      echo "No existing rust installation is found (i.e. rustc). Please run `rustup show` to see if you have any rust toolchain installed"
      echo "Else, please go ahead and run `rustup install <CHANNEL_NAME>`, where CHANNEL_NAME can be `stable`, `nightly`, `1.30.0` etc"
      echo "If a rust installation is already installed, please run `rustup check` & `rustup update` to check and update the channels"
      echo "then go ahead and run `rustup default <CHANNEL_NAME>` to set those as the default"
    fi
    ########## Module Rust Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
      home.sessionPath = [
        "${config.home.homeDirectory}/.cargo/bin"
      ];
      home.packages = [
        pkgs.rustup
      ];
    }
    (lib.mkIf isVSCodeEnable {
      programs.vscode = {
        profiles.default.userSettings = {
          "rust-analyzer.imports.granularity.enforce" = true;
          "rust-analyzer.cargo.autoreload" = true;
          "rust-analyzer.check.command" = "clippy";
          "[rust]" = {
            "editor.codeActionsOnSave" = {
              "source.organizeImports" = "explicit";
            };
            "editor.formatOnSave" = true;
          };
        };
        profiles.default.extensions = [
          # NOTE: If vscode extension has errors, check Output > Rust Analyzer Language Server
          # chances are the error will be there. You'll probably just need to add the rust-src
          # component for the actual `rust-analyzer` via
          # `rustup component add rust-src`
          # as highlighted here: https://rust-analyzer.github.io/manual.html#installation
          pkgs.vscode-extensions.rust-lang.rust-analyzer
        ];
      };
    })
  ]);
}
