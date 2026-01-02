{ config, lib, pkgs, ... }:
let
  isVSCodeEnable = config.customHomeProfile.GUI.enable && config.customHomeProfile.GUI.vscode.enable;
  cfg = config.customHomeProfile.ruby;

  RBENV_ROOT = "${config.home.homeDirectory}/.rbenv";
  shell_extracommon_str = ''
    ########## Module Ruby Init Extra Start ##########
    # Use these to check if the respective shells are run.
    # The respective $XXX_VERSION will be set by the respective shells when ran
    if [ -n "$ZSH_VERSION" ]; then
      eval "$(${RBENV_ROOT}/bin/rbenv init - zsh)"
    elif [ -n "$BASH_VERSION" ]; then
      eval "$(${RBENV_ROOT}/bin/rbenv init - bash)"
    else
      eval "$(${RBENV_ROOT}/bin/rbenv init - sh)"
    fi
    ########## Module Ruby Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.sessionPath = [
        "${RBENV_ROOT}/bin"
      ];
      home.sessionVariables = {
        inherit RBENV_ROOT;
      };
      home.file = {
        "${RBENV_ROOT}" = {
          recursive = true;
          source = pkgs.fetchFromGitHub {
            owner = "rbenv";
            repo = "rbenv";
            rev = "v1.3.2";
            hash = "sha256-vkwYl+cV5laDfevAHfju5G+STA3Y+wcMBtW1NWzJ4po=";
          };
        };
        "${RBENV_ROOT}/plugins/ruby-build" = {
          recursive = true;
          source = pkgs.fetchFromGitHub {
            owner = "rbenv";
            repo = "ruby-build";
            rev = "v20250908";
            sha256 = "sha256-jlRfdfAuS0f9ND+fykhF6gj7qOAfsd5SGfJboV9RVx0=";
          };
        };
      };
      home.shellAliases = {
        rb-binstubs = "bundle install --binstubs";
        rbls = "rbenv versions"; # check ruby installed
        rblsav = "rbenv install -l | less"; # check available ruby to install
        rb-version-install = "rbenv install ";
        rb-version-uninstall = "rbenv uninstall ";
      };
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initContent = shell_extracommon_str;
    }
    (lib.mkIf isVSCodeEnable {
      programs.vscode = {
        profiles.default.userSettings = {
          "[ruby]" = {
            "editor.defaultFormatter" = "Shopify.ruby-lsp";
            "editor.formatOnSave" = true;
            "editor.insertSpaces" = true;
            "editor.semanticHighlighting.enabled" = true;
          };
        };
        profiles.default.extensions = [
          pkgs.nix-vscode-extensions.vscode-marketplace.shopify.ruby-lsp
          pkgs.nix-vscode-extensions.vscode-marketplace.kaiwood.endwise
          pkgs.nix-vscode-extensions.vscode-marketplace.aki77.rails-db-schema
        ];
      };
    })
  ]);
}
