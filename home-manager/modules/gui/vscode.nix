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
          "workbench.settings.editor" = "json";
          "update.mode" = "none";
          "editor.rulers" = [ 72 80 100 120 140 160 ];
          "editor.tabSize" = 2;
          "explorer.confirmDelete" = false;
          "terminal.integrated.fontFamily" = "MesloLGS NF";
          "terminal.integrated.fontSize" = 12;
          "workbench.iconTheme" = "Monokai Pro (Filter Spectrum) Icons";
          "workbench.colorTheme" = "Monokai Pro (Filter Spectrum)";
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
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          # NOTE: We can use the shell function `get_vsixpkg $publisher $extension_name` to easily get the required updated
          # version as well as the required SHA info.
          {
            publisher = "jgclark";
            name = "vscode-todo-highlight";
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
            version = "1.12.24";
            sha256 = "1dlg9yyvcf70k6ykvz0s7zlhm7qjvj6mv34bnl3gdwc1282rs42c";
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
