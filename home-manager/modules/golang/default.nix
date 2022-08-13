{ config, lib, pkgs, ... }:
let
  isGUIEnable = config.customHomeProfile.GUI.enable;
  cfg = config.customHomeProfile.golang;

  GOPATH = "${config.home.homeDirectory}/go";
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.sessionPath = [
        # # golang's default `go install` bin path. Usually this will be `$HOME/go`
        "${GOPATH}/bin"
        "${config.home.homeDirectory}/.local/go/bin"
      ];
      home.packages = [
        pkgs.golangci-lint
      ];
      home.sessionVariables = {
        inherit GOPATH;
      };
      programs.go = {
        # There may be some issues with `go` using certain types of compilation
        # such as using cgo or comoiling with static compiles
        # Can check here for more info: in https://nixos.wiki/wiki/Go
        # TODO: write something that can overcome this should the need arise
        enable = true;
        package = pkgs.go;
      };
    }
    (lib.mkIf isGUIEnable {
      programs.vscode = {
        userSettings = {
          "go.formatTool" = "goimports";
          "go.useLanguageServer" = true;
          "go.toolsManagement.autoUpdate" = true;
          "[go]" = {
            "editor.snippetSuggestions" = "none";
            "editor.formatOnSave" = true;
            "editor.codeActionsOnSave" = {
              "source.organizeImports" = true;
            };
          };
          "go.lintOnSave" = "package";
          "go.lintTool" ="golangci-lint";
          "go.lintFlags" = [
            "--fast"
          ];
          "go.autocompleteUnimportedPackages" = true;
          "gopls" = {
            "usePlaceholders" = true; # add parameter placeholders when completing a function
            # "local" = "git.example.com";
            # Experimental settings
            "completeUnimported" = true; # autocomplete unimported packages
            "deepCompletion" = true;     # enable deep completion
          };
          # "go.toolsEnvVars" = {
          #     "GOOS" = "linux"
          # };
          "go.delveConfig" = {
            "dlvLoadConfig" = {
              "maxStringLen" = 4096;
            };
            "apiVersion" = 2;
          };
        };
        extensions = [
          pkgs.vscode-extensions.golang.go
        ];
      };
    })
  ]);
}
