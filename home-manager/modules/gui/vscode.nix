{ config, lib, pkgs, ... }:
let
  # utility for openvsx extensions
  mkOpenVSXExt = { publisher, name, version, sha256 }: {
    inherit name publisher version;
    vsix = builtins.fetchurl {
      inherit sha256;
      url = "https://open-vsx.org/api/${publisher}/${name}/${version}/file/${publisher}.${name}-${version}.vsix";
      name = "${publisher}-${name}.zip";
    };
  };

  # configuration
  isVSCodeEnable = config.customHomeProfile.GUI.enable && config.customHomeProfile.GUI.vscode.enable;
  cfg = config.customHomeProfile.GUI.vscode;
  crUUID = if cfg.crashReporterUUID == null then "473f1188-f798-49bf-91b2-a80a8ab1a498" else cfg.crashReporterUUID;
in
{
  config = lib.mkIf isVSCodeEnable (lib.mkMerge [
    {
      warnings = if cfg.crashReporterUUID != null then [ ] else [
        ''
          You have not provided a UUID for customHomeProfile.GUI.vscode.crashReporterUUID
          While a default value will be provided, it is advised to specify a generated UUID value.
          You may generate one via `uuidgen`.
        ''
      ];
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      home.file = {
        ".local/share/applications/Codium.desktop" = {
          text = ''
            [Desktop Entry]
            Actions=new-empty-window
            Categories=Utility;TextEditor;Development;IDE
            Comment=Code Editing. Redefined.
            Exec=codium %F
            GenericName=Text Editor
            Icon=${pkgs.vscodium}/share/pixmaps/code.png
            Keywords=vscode
            MimeType=text/plain;inode/directory
            Name=VSCodium
            StartupNotify=true
            StartupWMClass=vscodium
            Type=Application
            Version=1.4

            [Desktop Action new-empty-window]
            Exec=codium --new-window %F
            Icon=${pkgs.vscodium}/share/pixmaps/code.png
            Name=New Empty Window
          '';
          executable = true;
        };
        ".vscode-oss/argv.json" = {
          text = ''
            // This configuration file allows you to pass permanent command line arguments to VS Code.
            // Only a subset of arguments is currently supported to reduce the likelihood of breaking
            // the installation.
            //
            // PLEASE DO NOT CHANGE WITHOUT UNDERSTANDING THE IMPACT
            //
            // NOTE: Changing this file requires a restart of VS Code.
            {
              // Use software rendering instead of hardware accelerated rendering.
              // This can help in cases where you see rendering issues in VS Code.
              // "disable-hardware-acceleration": true,

              // Allows to disable crash reporting.
              // Should restart the app if the value is changed.
              "enable-crash-reporter": false,

              // Unique id used for correlating crash reports sent from this instance.
              // Do not edit this value.
              "crash-reporter-id": "${crUUID}",
              "enable-proposed-api": [
                  "jeanp413.open-remote-ssh",
              ]
            }
          '';
        };
      };
    })
    {
      programs.bash.initExtra = ''
        ########## VSCODE GUI INTEGRATION START ##########
        [[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"
        ########## VSCODE GUI INTEGRATION END ##########
      '';
      programs.zsh.initExtra = ''
        ########## VSCODE GUI INTEGRATION START ##########
        [[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"
        ########## VSCODE GUI INTEGRATION END ##########
      '';
      home.file = {
        ".local/bin/update_installed_exts.sh".source = pkgs.fetchFromGitHub
          {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "8f868e154ca265e38481ab15d28429f7ff72e0e4";
            sha256 = "0qma806bpd99glhjl3zwdkaydi44nrhjg51n6n4siqkfq0kk96v7";
          } + "/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh";
        ".local/bin/code".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.vscodium}/bin/codium";
      };
      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;
        mutableExtensionsDir = true;
        keybindings = [
          { key = "ctrl+alt+up"; command = "editor.action.insertCursorAbove"; when = "editorTextFocus"; }
          { key = "ctrl+alt+down"; command = "editor.action.insertCursorBelow"; when = "editorTextFocus"; }
        ] ++ (if pkgs.stdenv.isDarwin then [
          { key = "shift+cmd+/"; command = "editor.action.goToImplementation"; when = ""; }
        ] else [
          { key = "shift+ctrl+/"; command = "editor.action.goToImplementation"; when = ""; }
        ]);
        userSettings = {
          "window.title" = "\${activeEditorMedium}\${separator}\${rootName}";
          "workbench.editor.labelFormat" = "medium";
          "remote.SSH.useFlock" = false;
          "remote.SSH.localServerDownload" = "always";
          "terminal.integrated.shellIntegration.enabled" = false;
          "workbench.settings.editor" = "json";
          "update.mode" = "none";
          "editor.rulers" = [ 72 80 100 120 140 160 ];
          "editor.tabSize" = 2;
          "explorer.confirmDelete" = false;
          "terminal.integrated.fontFamily" = "MesloLGS NF";
          "terminal.integrated.fontSize" = 12;
          "workbench.colorTheme" = "monokai-charcoal (white)";
          # "workbench.iconTheme" = "Monokai Pro (Filter Spectrum) Icons";
          # "workbench.colorTheme" = "Monokai Pro (Filter Spectrum)";
          "search.followSymlinks" = false;
          "todohighlight.keywords" = [
            {
              "text" = "TODO:";
              "backgroundColor" = "teal";
              "color" = "black";
              "overviewRulerColor" = "teal";
            }
            {
              "text" = "NOTE:";
              "backgroundColor" = "purple";
              "color" = "white";
              "overviewRulerColor" = "purple";
            }
          ];
          "workbench.colorCustomizations" = { };
          "editor.tokenColorCustomizations" = {
            "comments" = "#278a06";
          };
          "search.searchOnType" = false;
          "diffEditor.ignoreTrimWhitespace" = false;
          "cmake.configureOnOpen" = true;
          "nginx-conf-hint.syntax" = "sublime";
        };
        extensions = [
          pkgs.vscode-extensions.eamodio.gitlens
          pkgs.vscode-extensions.ms-azuretools.vscode-docker
          pkgs.vscode-extensions.ms-vscode.cpptools
          pkgs.vscode-extensions.tyriar.sort-lines
          pkgs.vscode-extensions.zxh404.vscode-proto3
          pkgs.vscode-extensions.tomoki1207.pdf
          pkgs.vscode-extensions.mikestead.dotenv
          pkgs.vscode-extensions.mechatroner.rainbow-csv
          pkgs.vscode-extensions.jnoortheen.nix-ide
          pkgs.vscode-extensions.ibm.output-colorizer
          pkgs.vscode-extensions.formulahendry.auto-rename-tag
          # NOTE: Incompatible with vscodium
          # pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
          pkgs.vscode-extensions.sanaajani.taskrunnercode
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          # NOTE: We can use the shell function `get_vsixpkg $publisher $extension_name` to easily get the required updated
          # version as well as the required SHA info.
          {
            name = "code-gnu-global";
            publisher = "austin";
            version = "0.2.2";
            sha256 = "1fz89m6ja25aif6wszg9h2fh5vajk6bj3lp1mh0l2b04nw2mzhd5";
          }
          # NOTE: Incompatible with vscodium
          # {
          #   name = "remote-containers";
          #   publisher = "ms-vscode-remote";
          #   version = "0.254.0";
          #   sha256 = "1bq4f26fqhvrr424dpy06x1wvi0ad34vmzdzn83wsq4rvm08h7hk";
          # }
          (mkOpenVSXExt {
            name = "open-remote-ssh";
            publisher = "jeanp413";
            version = "0.0.16";
            sha256 = "0m1ypf8crdmyf9qzm0904sz7rgb9xd4l4hyna9y9zfw6cq82cbd3";
          })
          {
            name = "doxdocgen";
            publisher = "cschlosser";
            version = "1.4.0";
            sha256 = "1d95znf2vsdzv9jqiigh9zm62dp4m9jz3qcfaxn0n0pvalbiyw92";
          }
          {
            name = "Doxygen";
            publisher = "bbenoist";
            version = "1.0.0";
            sha256 = "0kclb60mnaj3c5lmpwmhkbnx4g8gr4wy66lkcklkwm555nkgw48n";
          }
          {
            name = "vscode-todo-highlight";
            publisher = "jgclark";
            version = "2.0.4";
            sha256 = "18zm1w4ziq3i7fn2rcd095va7nqnbdmsvr82lj27s33zrd2wwzzr";
          }
          {
            name = "change-case";
            publisher = "wmaurer";
            version = "1.0.0";
            sha256 = "0dxsdahyivx1ghxs6l9b93filfm8vl5q2sa4g21fiklgdnaf7pxl";
          }
          {
            name = "cmake-tools";
            publisher = "ms-vscode";
            version = "1.13.8";
            sha256 = "1lak94fr48gqsfz9355pgwr8b1scngjk6byi737q3k1sgjxbz6cl";
          }
          {
            name = "cmake";
            publisher = "twxs";
            version = "0.0.17";
            sha256 = "11hzjd0gxkq37689rrr2aszxng5l9fwpgs9nnglq3zhfa1msyn08";
          }
          # {
          #   name = "theme-monokai-pro-vscode";
          #   publisher = "monokai";
          #   version = "1.1.21";
          #   sha256 = "16pznay32d9pd1gigcrzww1rnni0sq1r8hg28awvvw9wnqn0hlk4";
          # }
          {
            name = "monokai-charcoal-high-contrast";
            publisher = "74th";
            version = "3.4.0";
            sha256 = "05y8dwqqmixy9k59xmdpwgjbvvc6w7lh8apgnijy0li0xrs11i9f";
          }
          # {
          #   name = "material-theme";
          #   publisher = "zhuangtongfa";
          #   version = "3.15.5";
          #   sha256 = "0crrzpdy8fy4l1nim93qscmlpz2jhyb6hf0gh1rzqgfnk9w431xi";
          # }
          {
            publisher = "bcanzanella";
            name = "openmatchingfiles";
            version = "0.5.2";
            sha256 = "0wpv77jir5k77ml0x1y21gk4kxk53vnkxrqg4v35clhdhszzh6fq";
          }
          {
            name = "vscode-direnv";
            publisher = "Rubymaniac";
            version = "0.0.2";
            sha256 = "1gml41bc77qlydnvk1rkaiv95rwprzqgj895kxllqy4ps8ly6nsd";
          }
          {
            name = "vscode-nginx-conf";
            publisher = "ahmadalli";
            version = "0.1.3";
            sha256 = "10z0him4kl9q6h1nip7d3dp9nv0a1dkh3x6zqc6nilfw959v3358";
          }

        ];
      };
    }
  ]);
}
