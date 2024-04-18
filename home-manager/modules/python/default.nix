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
          pkgs.vscode-extensions.ms-python.isort
          pkgs.vscode-extensions.ms-python.black-formatter
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            publisher = "ms-python";
            name = "python";
            version = "2023.23.13391009";
            sha256 = "0kk3kgzq7nh5b7h3a4jvsvj66279ad44jgwdzxnw05lljhar3afa";
          }
          {
            publisher = "ms-pyright";
            name = "pyright";
            version = "1.1.339";
            sha256 = "0mkaywrbxg437pfbawkg0al1c9b9z6mzjg9kanz93blaf0md2pdw";
          }
          {
            publisher = "ms-python";
            name = "mypy-type-checker";
            version = "2023.9.10961015";
            sha256 = "0ndpgshv22f8cm5j741mqrlw6iksc6ny2qsb469v3wg4ga5dw5c3";
          }
          {
            name = "jupyter-keymap";
            publisher = "ms-toolsai";
            version = "1.0.0";
            sha256 = "0wkwllghadil9hk6zamh9brhgn539yhz6dlr97bzf9szyd36dzv8";
          }
          {
            publisher = "ms-python";
            name = "pylint";
            version = "2023.11.13201006";
            sha256 = "11j7aff4y69pvb2r9m5777qbsf0sq1v8ydc8i56nf762lf6hzhkx";
          }
          {
            publisher = "ms-python";
            name = "flake8";
            version = "2023.11.13331010";
            sha256 = "1i99mrkm4b9gdwb78c1ibygj7dqn27hsx7100y3s8n7k8wgs0f48";
          }
        ];
      };
    })
  ]);
}
