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
            rev = "a632465cf4007d0a5b419ed5c5a7bd87349d7b14";
            sha256 = "0ganmwf37lblm1zlwb7r20bph68qwbnms85hrdzbcc0fihkjjpra";
          };
        };
        "${RBENV_ROOT}/plugins/ruby-build" = {
          recursive = true;
          source = pkgs.fetchFromGitHub {
            owner = "rbenv";
            repo = "ruby-build";
            rev = "v20230330";
            sha256 = "0axkp07xapakkb1lc5yiqq5hr5kjwbyvwyrh6ygx889zlipsxznj";
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
      programs.zsh.initExtra = shell_extracommon_str;
    }
    (lib.mkIf isVSCodeEnable {
      programs.vscode = {
        profiles.default.userSettings = {
          "ruby.useBundler" = true; #run non-lint commands with bundle exec
          "solargraph.useBundler" = false;
          "ruby.useLanguageServer" = true; # use the internal language server (see below)
          "ruby.intellisense" = "rubyLocate";
        };
        profiles.default.extensions = [
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
            version = "0.2.6";
            sha256 = "16nmbg3p1z1mr3027m46j8m09g1l3w2d529g27aydw5i1v6d84f4";
          }
          {
            publisher = "castwide";
            name = "solargraph";
            version = "0.24.0";
            sha256 = "0pcd4gwzg4rla5mz6kj4dqq30pyvsv6290an15yr89wxwcvk6qzf";
          }
          {
            name = "vscode-ruby";
            publisher = "wingrunr21";
            version = "0.28.0";
            sha256 = "1gab5cka87zw7i324rz9gmv423rf5sylsq1q1dhfkizmrpwzaxqz";
          }
          # {
          #   name = "ruby";
          #   publisher = "rebornix";
          #   version = "0.28.1";
          #   sha256 = "179g7nc6mf5rkha75v7rmb3vl8x4zc6qk1m0wn4pgylkxnzis18w";
          # }
        ];
      };
    })
  ]);
}
