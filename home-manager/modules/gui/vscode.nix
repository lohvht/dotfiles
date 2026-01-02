{ config, lib, pkgs, ... }@inputs:
let
  guilib = import ./lib.nix inputs;
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
  vscode_pkg = pkgs.vscodium;
  code_wrapper = ''
    #!${pkgs.bash}/bin/bash
    exec ${vscode_pkg}/bin/codium "$@" --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime
  '';
  shell_extracommon_str = ''
    ########## Module VsCode Init Extra Start ##########
    if [ "$TERM_PROGRAM" = "vscode" ]; then
      if [ -n "$ZSH_VERSION" ]; then
        . "$(code --locate-shell-integration-path zsh)"
      elif [ -n "$BASH_VERSION" ]; then
        . "$(code --locate-shell-integration-path bash)"
      else
        . "$(code --locate-shell-integration-path bash)"
      fi
    fi
    ########## Module VsCode Init Extra End ##########
  '';
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
      } // guilib.desktopWrap {
        actions = {
          new-empty-window = {
            exec = "${vscode_pkg}/bin/codium %F --new-window --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime";
            icon = "vscodium";
            name = "New Empty Window";
          };
        };
        categories = [ "Utility" "TextEditor" "Development" "IDE" ];
        comment = "Code Editing. Redefined.";
        exec = "${vscode_pkg}/bin/codium %F --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime";
        genericName = "Text Editor";
        icon = "vscodium";
        keywords = [ "vscode" ];
        startupWMClass = "vscodium";
        mimeTypes = [
          "text/plain"
          "inode/directory"
        ];
        name = "codium";
        desktopName = "VSCode";
        startupNotify = true;
        type = "Application";
      };
    })
    {
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initContent = shell_extracommon_str;
      home.file = {
        ".local/bin/update_installed_exts.sh".source = pkgs.fetchFromGitHub
          {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "8f868e154ca265e38481ab15d28429f7ff72e0e4";
            sha256 = "0qma806bpd99glhjl3zwdkaydi44nrhjg51n6n4siqkfq0kk96v7";
          } + "/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh";
        ".local/bin/code" = {
          text = code_wrapper;
          executable = true;
        };
        ".local/bin/codium" = {
          text = code_wrapper;
          executable = true;
        };
      };
      # TODO: Attempt to try this number 3 option out in WSL as WSLg exists:
      # https://stackoverflow.com/questions/72011852/how-to-setup-windows-subsystem-linux-wsl-2-with-vscodium-on-windows-10
      home.sessionVariables = {
        DONT_PROMPT_WSL_INSTALL = "1";
      };
      programs.vscode = {
        enable = true;
        package = vscode_pkg;
        mutableExtensionsDir = true;
        profiles.default.keybindings = [
          { key = "ctrl+alt+up"; command = "editor.action.insertCursorAbove"; when = "editorTextFocus"; }
          { key = "ctrl+alt+down"; command = "editor.action.insertCursorBelow"; when = "editorTextFocus"; }
        ] ++ (if pkgs.stdenv.isDarwin then [
          { key = "shift+cmd+/"; command = "editor.action.goToImplementation"; when = ""; }
        ] else [
          { key = "shift+ctrl+/"; command = "editor.action.goToImplementation"; when = ""; }
        ]);
        profiles.default.userSettings = {
          "window.title" = "\${activeEditorMedium}\${separator}\${rootName}";
          "workbench.editor.labelFormat" = "medium";
          "remote.SSH.useFlock" = false;
          "remote.SSH.localServerDownload" = "always";
          "terminal.integrated.shellIntegration.enabled" = false;
          "update.mode" = "none";
          "extensions.autoUpdate" = false;
          "editor.rulers" = [ 72 80 100 120 140 160 ];
          "explorer.confirmDelete" = false;
          "terminal.integrated.fontFamily" = "MesloLGS NF";
          "terminal.integrated.fontSize" = 12;
          "workbench.colorTheme" = "monokai-charcoal (white)";
          "terminal.integrated.enableMultiLinePasteWarning" = "never";
          # "workbench.iconTheme" = "Monokai Pro (Filter Spectrum) Icons";
          # "workbench.colorTheme" = "Monokai Pro (Filter Spectrum)";
          "search.followSymlinks" = false;
          "git.enableCommitSigning" = true;
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
          "todohighlight.include" = [
            "**/*.js"
            "**/*.jsx"
            "**/*.ts"
            "**/*.tsx"
            "**/*.html"
            "**/*.css"
            "**/*.scss"
            "**/*.php"
            "**/*.rb"
            "**/*.txt"
            "**/*.mdown"
            "**/*.py"
            "**/*.rs"
            "**/*.go"
            "**/*.md"
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
        };
        profiles.default.extensions = [
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-vscode.live-server
          pkgs.nix-vscode-extensions.vscode-marketplace.eamodio.gitlens
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-azuretools.vscode-docker
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-vscode.cpptools
          pkgs.nix-vscode-extensions.vscode-marketplace.tomoki1207.pdf
          pkgs.nix-vscode-extensions.vscode-marketplace.mikestead.dotenv
          pkgs.nix-vscode-extensions.vscode-marketplace.mechatroner.rainbow-csv
          pkgs.nix-vscode-extensions.vscode-marketplace.jnoortheen.nix-ide
          pkgs.nix-vscode-extensions.vscode-marketplace.ibm.output-colorizer
          pkgs.nix-vscode-extensions.vscode-marketplace.tamasfe.even-better-toml
          pkgs.nix-vscode-extensions.vscode-marketplace.sanaajani.taskrunnercode
          pkgs.nix-vscode-extensions.vscode-marketplace.mkhl.direnv
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-vscode.hexeditor
          pkgs.nix-vscode-extensions.vscode-marketplace.zxh404.vscode-proto3
          # pkgs.nix-vscode-extensions.vscode-marketplace.vadimcn.vscode-lldb
          pkgs.nix-vscode-extensions.vscode-marketplace.timonwong.shellcheck
          pkgs.nix-vscode-extensions.vscode-marketplace.usernamehw.errorlens
          pkgs.nix-vscode-extensions.vscode-marketplace.austin.code-gnu-global
          pkgs.nix-vscode-extensions.open-vsx.jeanp413.open-remote-ssh
          pkgs.nix-vscode-extensions.open-vsx.wayou.vscode-todo-highlight
          pkgs.nix-vscode-extensions.vscode-marketplace.ryanluker.vscode-coverage-gutters
          pkgs.nix-vscode-extensions.vscode-marketplace."74th".monokai-charcoal-high-contrast
          pkgs.nix-vscode-extensions.vscode-marketplace.ahmadalli.vscode-nginx-conf
        ];
      };
    }
  ]);
}
