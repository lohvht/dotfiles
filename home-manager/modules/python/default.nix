{ config, lib, pkgs, ... }:
let
  isVSCodeEnable = config.customHomeProfile.GUI.enable && config.customHomeProfile.GUI.vscode.enable;
  cfg = config.customHomeProfile.python;

  venvwrapper = pkgs.python3Packages.virtualenvwrapper;
  virtualenv_wrapper_path_modification_removed = pkgs.runCommand "${venvwrapper.name}-wrapper" { } ''
    mkdir $out
    # ln -s ${venvwrapper}/* $out
    # rm $out/bin
    mkdir $out/bin
    for bin in ${venvwrapper}/bin/virtualenvwrapper.sh ${venvwrapper}/bin/virtualenvwrapper_lazy.sh; do
      wrapped_bin="$out/bin/$(basename $bin)"
      grep -v '^export PATH=' "$bin" > $wrapped_bin
      chmod +x $wrapped_bin
    done
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.sessionPath = [
      ];
      home.sessionVariables = {
        # directory for virtualenvs created using virtualenvwrapper
        WORKON_HOME = "${config.home.homeDirectory}/.virtualenvs";
        # # use the same directory for virtualenvs as virtualenvwrapper
        # PIP_VIRTUALENV_BASE = "$WORKON_HOME";
        # makes pip detect an active virtualenv and install to it
        PIP_RESPECT_VIRTUALENV = "true";
        VIRTUALENVWRAPPER_PYTHON = "${pkgs.python3}/bin/python";
        VIRTUALENVWRAPPER_VIRTUALENV = "${pkgs.virtualenv}/bin/virtualenv";
        PYTHONDONTWRITEBYTECODE = 1;
      };
      home.packages = [
        pkgs.uv
        virtualenv_wrapper_path_modification_removed
      ];
      home.shellAliases = {
      };
      programs.zsh.oh-my-zsh.plugins = [
        # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/virtualenv
        "virtualenv"
        # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/virtualenvwrapper
        # NOTE: This will also do the virtualenvwrapper init required.
        "virtualenvwrapper"
        # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/uv
        "uv"
      ];
    }
    (lib.mkIf isVSCodeEnable {
      programs.vscode = {
        profiles.default.userSettings = {
          "files.exclude"."**/*.pyc" = true;
          "[python]" = {
            "editor.codeActionsOnSave" = {
              "source.organizeImports" = "explicit";
            };
            "editor.insertSpaces" = true;
          };
        };
        profiles.default.extensions = [
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-toolsai.jupyter
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-toolsai.jupyter-renderers
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-python.isort
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-python.black-formatter
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-python.python
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-python.mypy-type-checker
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-python.pylint
          pkgs.nix-vscode-extensions.vscode-marketplace.ms-python.flake8
        ];
      };
    })
  ]);
}
