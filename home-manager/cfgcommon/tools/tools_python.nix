config: lib: pkgs: extraArgs:
let
  cfgcommonlib = import ../lib/cfg_common_lib.nix;
  inherit (extraArgs) tools_python is_GUI;
  PYENV_ROOT = "${config.home.homeDirectory}/.pyenv";
in
lib.optionals (tools_python != null) [
  (cfgcommonlib.mkCfgCommon {
    shell_paths = [
      "${PYENV_ROOT}/bin"
    ];
    shell_variables = {
      inherit PYENV_ROOT;
      # directory for virtualenvs created using virtualenvwrapper
      WORKON_HOME = "${config.home.homeDirectory}/.virtualenvs";
      # use the same directory for virtualenvs as virtualenvwrapper
      PIP_VIRTUALENV_BASE = "$WORKON_HOME";
      # makes pip detect an active virtualenv and install to it
      PIP_RESPECT_VIRTUALENV = true;
      PYTHONDONTWRITEBYTECODE = 1;
    };
    home_packages = [
      pkgs.python3
      pkgs.python3Packages.pip
      pkgs.python3Packages.virtualenv
      pkgs.python3Packages.virtualenvwrapper
    ];
    home_files = {
      "${PYENV_ROOT}" = {
        recursive = true;
        source = pkgs.fetchFromGitHub {
          owner = "pyenv";
          repo = "pyenv";
          rev = "v2.3.3";
          sha256 = "0a50nk6nmn19yxf5qxmc332wfbsvyn1yxhvn4imqy181fkwq2wlg";
        };
      };
    };
    home_programs = {
    } // lib.optionalAttrs is_GUI {
      vscode = {
        userSettings = {
          "python.languageServer" = "Pylance";
          "files.exclude" = {
              "**/*.pyc" = true;
          };
          "workbench.editorAssociations" = {
              "*.ipynb" = "jupyter-notebook";
          };
          "notebook.cellToolbarLocation" = {
              "default" = "right";
              "jupyter-notebook" = "left";
          };
        };
        extensions = [
          pkgs.vscode-extensions.ms-python.python
          pkgs.vscode-extensions.ms-python.vscode-pylance
          pkgs.vscode-extensions.ms-toolsai.jupyter
          pkgs.vscode-extensions.ms-toolsai.jupyter-keymap
          pkgs.vscode-extensions.ms-toolsai.jupyter-renderers
        ];
      };
    };
    shell_aliases = {
      #######
      # pyenv virtualenvs
      #######
      pyls="pyenv versions"; # check pythons installed
      pylsav="pyenv install -l | less"; # check available pythons to install
      py-version-install="pyenv install ";
      py-version-uninstall="pyenv uninstall ";
    };
    shell_functions = [
      ''
      function pymakevenv() {
        mkvirtualenv --python=`pyenv root`/versions/$1/bin/python $2
        echo "rest of args is: $@"
      }
      # lsvirtualenv
      # rmvirtualenv {venv_name}
      # workon {venv_name}
      # deactivate
      ''
    ];
    shell_extracommoninit = [
      ''#### GENERATED SHELL SECTION FOR tools_python START ###''
      ''
      if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init -)"
      fi
      # init virtualenvwrapper
      . virtualenvwrapper.sh
      ''
      ''#### GENERATED SHELL SECTION FOR tools_python END ###''
    ];
  })
]
