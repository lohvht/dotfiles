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
      # TODO: Attempt to try this number 3 option out in WSL as WSLg exists:
      # https://stackoverflow.com/questions/72011852/how-to-setup-windows-subsystem-linux-wsl-2-with-vscodium-on-windows-10
      home.sessionVariables = {
        DONT_PROMPT_WSL_INSTALL = "1";
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
          "update.mode" = "none";
          "editor.rulers" = [ 72 80 100 120 140 160 ];
          "explorer.confirmDelete" = false;
          "terminal.integrated.fontFamily" = "MesloLGS NF";
          "terminal.integrated.fontSize" = 12;
          "workbench.colorTheme" = "monokai-charcoal (white)";
          "terminal.integrated.enableMultiLinePasteWarning" = false;
          # "workbench.iconTheme" = "Monokai Pro (Filter Spectrum) Icons";
          # "workbench.colorTheme" = "Monokai Pro (Filter Spectrum)";
          "search.followSymlinks" = false;
          "todohighlight.keywords" = [
            {
              "text" = "TODO:";
              "backgroundColor" = "teal";
              "color" = "black";
              "overviewRulerColor" = "teal";
              "fontWeight" = "bold";
            }
            {
              "text" = "NOTE:";
              "backgroundColor" = "purple";
              "color" = "white";
              "overviewRulerColor" = "purple";
              "fontWeight" = "bold";
            }
            {
              "text" = "HACK:";
              "backgroundColor" = "red";
              "color" = "white";
              "overviewRulerColor" = "red";
              "fontWeight" = "bold";
            }
            {
              "text" = "FIXME:";
              "backgroundColor" = "deeppink";
              "color" = "white";
              "overviewRulerColor" = "deeppink";
              "fontWeight" = "bold";
            }
          ];
          "workbench.colorCustomizations" = { };
          "editor.tokenColorCustomizations" = {
            "comments" = "#278a06";
          };
          "search.searchOnType" = false;
          "diffEditor.ignoreTrimWhitespace" = false;
          "nginx-conf-hint.syntax" = "sublime";
          "debug.allowBreakpointsEverywhere" = true;
          "files.insertFinalNewline" = true;
          "coverage-gutters.coverageFileNames" = [
            "coverage/tests.lcov"
            "lcov.info"
            "cov.xml"
            "coverage.xml"
            "jacoco.xml"
            "coverage.cobertura.xml"
          ];
          "editor.codeActionsOnSave" = {
            # Shellcheck
            "source.fixAll.shellcheck" = "explicit";
          };
          "shellcheck.run" = "onSave";
          "git.inputValidation" = true;
          "editor.formatOnSaveMode" = "file";
        };
        extensions = [
          pkgs.vscode-extensions.ms-vscode.live-server
          pkgs.vscode-extensions.eamodio.gitlens
          pkgs.vscode-extensions.ms-azuretools.vscode-docker
          pkgs.vscode-extensions.ms-vscode.cpptools
          pkgs.vscode-extensions.tomoki1207.pdf
          pkgs.vscode-extensions.mikestead.dotenv
          pkgs.vscode-extensions.mechatroner.rainbow-csv
          pkgs.vscode-extensions.jnoortheen.nix-ide
          pkgs.vscode-extensions.ibm.output-colorizer
          pkgs.vscode-extensions.tamasfe.even-better-toml
          pkgs.vscode-extensions.sanaajani.taskrunnercode
          pkgs.vscode-extensions.mkhl.direnv
          pkgs.vscode-extensions.ms-vscode.hexeditor
          pkgs.vscode-extensions.zxh404.vscode-proto3
          pkgs.vscode-extensions.vadimcn.vscode-lldb
          pkgs.vscode-extensions.timonwong.shellcheck
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          # TODO: Replace the whole of pkgs.vscode-utils.extensionsFromVscodeMarketplace
          # block + extensions above with this:
          # https://github.com/nix-community/nix-vscode-extensions
          # {
          #   publisher = "eamodio";
          #   name = "gitlens";
          #   version = "2023.3.1705";
          #   sha256 = "06qb0c3c6nh8c4qvjcm0kr5nn3xj2qq1kbwmjlyvy67w9hzmir7p";
          # }
          # NOTE: We can use the shell function `get_vsixpkg $publisher $extension_name` to easily get the required updated
          # version as well as the required SHA info.
          {
            name = "code-gnu-global";
            publisher = "austin";
            version = "0.2.2";
            sha256 = "1fz89m6ja25aif6wszg9h2fh5vajk6bj3lp1mh0l2b04nw2mzhd5";
          }
          (mkOpenVSXExt {
            publisher = "jeanp413";
            name = "open-remote-ssh";
            version = "0.0.46";
            sha256 = "0hrxdivwspg8xyf3g08rnhwa2m91v5pr7clp9yd4aicw3psrx007";
          })
          {
            publisher = "ryanluker";
            name = "vscode-coverage-gutters";
            version = "2.11.1";
            sha256 = "122558k6jkxmhahh8cs3qjznadydwm5286m02bg5q0k4j0bk9vrm";
          }
          {
            publisher = "jgclark";
            name = "vscode-todo-highlight";
            version = "2.0.4";
            sha256 = "18zm1w4ziq3i7fn2rcd095va7nqnbdmsvr82lj27s33zrd2wwzzr";
          }
          {
            name = "monokai-charcoal-high-contrast";
            publisher = "74th";
            version = "3.4.0";
            sha256 = "05y8dwqqmixy9k59xmdpwgjbvvc6w7lh8apgnijy0li0xrs11i9f";
          }
          {
            publisher = "ahmadalli";
            name = "vscode-nginx-conf";
            version = "0.3.5";
            sha256 = "10f5b14hlkz9gm11vxcqj6mw6nwz2lynh4z5nz2skkgn04qns0pa";
          }
        ];
      };
    }
  ]);
}
