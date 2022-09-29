{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.GUI;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
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
          pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
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
          {
            name = "remote-containers";
            publisher = "ms-vscode-remote";
            version = "0.254.0";
            sha256 = "1bq4f26fqhvrr424dpy06x1wvi0ad34vmzdzn83wsq4rvm08h7hk";
          }
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
          {
            name = "theme-monokai-pro-vscode";
            publisher = "monokai";
            version = "1.1.21";
            sha256 = "16pznay32d9pd1gigcrzww1rnni0sq1r8hg28awvvw9wnqn0hlk4";
          }
          {
            name = "monokai-charcoal-high-contrast";
            publisher = "74th";
            version = "3.4.0";
            sha256 = "05y8dwqqmixy9k59xmdpwgjbvvc6w7lh8apgnijy0li0xrs11i9f";
          }
          {
            name = "material-theme";
            publisher = "zhuangtongfa";
            version = "3.15.5";
            sha256 = "0crrzpdy8fy4l1nim93qscmlpz2jhyb6hf0gh1rzqgfnk9w431xi";
          }
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
        ];
      };
    }
  ]);
}
