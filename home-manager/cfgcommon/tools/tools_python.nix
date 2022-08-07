config: lib: pkgs: extraArgs:
let
  cfgcommonlib = import ../lib/cfg_common_lib.nix;
  inherit (extraArgs) tools_python is_GUI;
in
lib.optionals (tools_python != null) [
  (cfgcommonlib.mkCfgCommon {
    shell_variables = {
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
      # TODO: explore using mach-nix for python development instead:
      #       May be worth the effort instead of manually using our custom pyenv overlay
      # https://github.com/DavHau/mach-nix/blob/5a51cd46a0c65dc7e70a9741264ec1268c00567b/examples.md#use-mach-nix-from-a-flake
      pkgs.pyenv # will install pyenv_postinit as well
      pkgs.custom_python310_with_defaults
      pkgs.python310Packages.virtualenvwrapper # can't install within custom_python310_with_defaults as nix will wrap it with something that cant be sourced
    ];
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
      # init pyenv shims & auto-completion
      . pyenv_postinit
      # init virtualenvwrapper
      . virtualenvwrapper.sh
      ''
      ''#### GENERATED SHELL SECTION FOR tools_python END ###''
    ];
  })
]
