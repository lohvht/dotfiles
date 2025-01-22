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
        PIP_RESPECT_VIRTUALENV = "true";
        VIRTUALENVWRAPPER_PYTHON = "${pkgs.python3}/bin/python";
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
      programs.zsh.oh-my-zsh.plugins = [
        # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/virtualenv
        "virtualenv"
        # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/virtualenvwrapper
        "virtualenvwrapper"
      ];
    }
    (lib.mkIf isVSCodeEnable {
      programs.vscode = {
        userSettings = {
          "files.exclude"."**/*.pyc" = true;
          "workbench.editorAssociations"."*.ipynb" = "jupyter-notebook";
          "notebook.cellToolbarLocation" = {
            "default" = "right";
            "jupyter-notebook" = "left";
          };
          "[python]" = {
            "editor.codeActionsOnSave" = {
              "source.organizeImports" = "explicit";
            };
            "editor.insertSpaces" = true;
          };
        };
        extensions = [
          pkgs.vscode-extensions.ms-toolsai.jupyter
          pkgs.vscode-extensions.ms-toolsai.jupyter-renderers
          # pkgs.vscode-extensions.ms-python.isort
          # pkgs.vscode-extensions.ms-python.black-formatter
          # pkgs.vscode-extensions.ms-python.python
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            publisher = "ms-python";
            name = "isort";
            version = "2023.13.13171013";
            sha256 = "1dsw2kb8klq84f2gn7v6fhj2w80idx1glcnszasgwmngfa5ps5ah";
          }
          {
            publisher = "ms-python";
            name = "black-formatter";
            version = "2024.5.13171011";
            sha256 = "1c9ss4qs12clv783sxsrs11ayj0h2ymp08czcl72h0p363dlk92q";
          }
          {
            publisher = "ms-python";
            name = "python";
            version = "2024.23.2025011501";
            sha256 = "1wh8lzq6r4si74jkbgz57njh6m88hvrvxa45wxr7i1ajfzynif4h";
          }
          {
            publisher = "ms-python";
            name = "mypy-type-checker";
            version = "2024.1.13171012";
            sha256 = "0dslmrhp7flmp6kd69zmpimmayd0n8r5k74c0v81rb1v3wnblvhz";
          }
          {
            publisher = "ms-python";
            name = "pylint";
            version = "2024.1.13511018";
            sha256 = "0hb4zhzp8bk0d8188nc0qa0jlf8frxslm6ayg0bk95ml6xmkbw9a";
          }
          {
            publisher = "ms-python";
            name = "flake8";
            version = "2023.13.13171014";
            sha256 = "1ia5v90z3p6hzxx4apdvr6czdgg0v0f7fbmahp8702czr9q1p6ax";
          }
        ];
      };
    })
  ]);
}
