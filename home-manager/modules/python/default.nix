{ config, lib, pkgs, ... }:
let
  isVSCodeEnable = config.customHomeProfile.GUI.enable && config.customHomeProfile.GUI.vscode.enable;
  cfg = config.customHomeProfile.python;

  PYENV_ROOT = "${config.home.homeDirectory}/.pyenv";
  shell_extracommon_str = ''
    ########## Module Python Init Extra Start ##########
    function pymakevenv() {
      mkvirtualenv --python=`pyenv root`/versions/$1/bin/python $2
      echo "rest of args is: $@"
    }
    # Other virtualenv commands
    # lsvirtualenv
    # rmvirtualenv {venv_name}
    # workon {venv_name}
    # deactivate

    # init virtualenvwrapper
    . virtualenvwrapper.sh
    if command -v pyenv 1>/dev/null 2>&1; then
      eval "$(pyenv init -)"
    fi
    ########## Module Python Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.sessionPath = [
        "${PYENV_ROOT}/bin"
      ];
      home.sessionVariables = {
        inherit PYENV_ROOT;
        # directory for virtualenvs created using virtualenvwrapper
        WORKON_HOME = "${config.home.homeDirectory}/.virtualenvs";
        # use the same directory for virtualenvs as virtualenvwrapper
        PIP_VIRTUALENV_BASE = "$WORKON_HOME";
        # makes pip detect an active virtualenv and install to it
        PIP_RESPECT_VIRTUALENV = true;
        PYTHONDONTWRITEBYTECODE = 1;
      };
      home.packages = [
        pkgs.python3
        pkgs.python3Packages.pip
        pkgs.python3Packages.virtualenv
        pkgs.python3Packages.virtualenvwrapper
      ];
      home.file."${PYENV_ROOT}" = {
        recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "pyenv";
          repo = "pyenv";
          rev = "v2.3.3";
          sha256 = "0a50nk6nmn19yxf5qxmc332wfbsvyn1yxhvn4imqy181fkwq2wlg";
        };
      };
      home.shellAliases = {
        #######
        # pyenv virtualenvs
        #######
        pyls = "pyenv versions"; # check pythons installed
        pylsav = "pyenv install -l | less"; # check available pythons to install
        py-version-install = "pyenv install ";
        py-version-uninstall = "pyenv uninstall ";
      };
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
    }
    (lib.mkIf isVSCodeEnable {
      programs.vscode = {
        userSettings = {
          "python.languageServer" = "Pylance";
          "files.exclude"."**/*.pyc" = true;
          "workbench.editorAssociations"."*.ipynb" = "jupyter-notebook";
          "notebook.cellToolbarLocation" = {
            "default" = "right";
            "jupyter-notebook" = "left";
          };
          "[python]" = {
            "editor.insertSpaces" = true;
            "editor.tabSize" = 2;
          };
        };
        extensions = [
          pkgs.vscode-extensions.ms-python.python
          pkgs.vscode-extensions.ms-python.vscode-pylance
          pkgs.vscode-extensions.ms-toolsai.jupyter
          pkgs.vscode-extensions.ms-toolsai.jupyter-renderers
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "jupyter-keymap";
            publisher = "ms-toolsai";
            version = "1.0.0";
            sha256 = "0wkwllghadil9hk6zamh9brhgn539yhz6dlr97bzf9szyd36dzv8";
          }
        ];
      };
    })
  ]);
}
