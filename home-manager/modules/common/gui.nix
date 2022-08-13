{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.GUI;
in
{
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      mutableExtensionsDir = true;
      keybindings = if pkgs.stdenv.isDarwin then [
        { key = "shift+cmd+/"; command = "editor.action.goToImplementation"; when = "";}
      ] else [
        { key = "shift+ctrl+/"; command = "editor.action.goToImplementation"; when = "";}
      ];
      userSettings = {
        "workbench.settings.editor" = "json";
        "update.mode" = "none";
        "editor.rulers" = [ 72 80 100 120 140 160];
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
        "workbench.colorCustomizations" = {};
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
        pkgs.vscode-extensions.ms-vscode-remote.remote-containers
        pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
        pkgs.vscode-extensions.ms-vscode-remote.remote-ssh-edit
        pkgs.vscode-extensions.ms-vscode-remote.vscode-remote-extensionpack
        pkgs.vscode-extensions.ms-vscode.cpptools
        pkgs.vscode-extensions.ms-vscode.cmake-tools
        pkgs.vscode-extensions.Tyriar.sort-lines
        pkgs.vscode-extensions.zxh404.vscode-proto3
        pkgs.vscode-extensions.twxs.cmake
        pkgs.vscode-extensions.wayou.vscode-todo-highlight
        pkgs.vscode-extensions.wmaurer.change-case
        pkgs.vscode-extensions.tomoki1207.pdf
        pkgs.vscode-extensions.mtxr.sqltools
        pkgs.vscode-extensions.monokai.theme-monokai-pro-vscode
        pkgs.vscode-extensions.mikestead.dotenv
        pkgs.vscode-extensions.mechatroner.rainbow-csv
        pkgs.vscode-extensions.bcanzanella.openmatchingfiles
      ];
    };
  };
}