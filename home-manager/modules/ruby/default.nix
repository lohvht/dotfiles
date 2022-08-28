{ config, lib, pkgs, ... }:
let
  isGUIEnable = config.customHomeProfile.GUI.enable;
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
            rev = "v1.2.0";
            sha256 = "1mwvcs1kgqwnbmbljqi5a8acy2mxrlm2h86b2p0v995w8bj35xlv";
          };
        };
        "${RBENV_ROOT}/plugins/ruby-build" = {
          recursive = true;
          source = pkgs.fetchFromGitHub {
            owner = "rbenv";
            repo = "ruby-build";
            rev = "v20220825";
            sha256 = "0mlx6jbdi7jj453dslbvhfvf47yrvbmkx8xv80f594c0klx2pbgm";
          };
        };
      };
      home.shellAliases = {
        rbls = "rbenv versions"; # check ruby installed
        rblsav = "rbenv install -l | less"; # check available ruby to install
        rb-version-install = "rbenv install ";
        rb-version-uninstall = "rbenv uninstall ";
      };
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
    }
    (lib.mkIf isGUIEnable {
      programs.vscode = {
        userSettings = {
          "ruby.useBundler" = true; #run non-lint commands with bundle exec
          "ruby.useLanguageServer" = true; # use the internal language server (see below)
          "ruby.lint" = {
            rubocop.useBundler = true; # enable rubocop via bundler
            reek.useBundler = true; # enable reek via bundler
          };
          "ruby.format" = "rubocop"; # use rubocop for formatting
        };
        extensions = [
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "endwise";
            publisher = "kaiwood";
            version = "1.5.1";
            sha256 = "1dg096dnv3isyimp3r73ih25ya0yj0m1y9ryzrz40m0mbsk21mp4";
          }
          {
            name = "rails-db-schema";
            publisher = "aki77";
            version = "0.2.5";
            sha256 = "15l437ck4fvag40v91fr33z6ay0k8sq5pc1rci1gmg30fa86q3kn";
          }
          {
            name = "solargraph";
            publisher = "castwide";
            version = "0.23.0";
            sha256 = "0ivawyq16712j2q4wic3y42lbqfml5gs24glvlglpi0kcgnii96n";
          }
          {
            name = "vscode-ruby";
            publisher = "wingrunr21";
            version = "0.28.0";
            sha256 = "1gab5cka87zw7i324rz9gmv423rf5sylsq1q1dhfkizmrpwzaxqz";
          }
          {
            name = "ruby";
            publisher = "rebornix";
            version = "0.28.1";
            sha256 = "179g7nc6mf5rkha75v7rmb3vl8x4zc6qk1m0wn4pgylkxnzis18w";
          }
        ];
      };
    })
  ]);
}
