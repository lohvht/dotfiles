# These contain the common shell parts that can be shared with both bash and zsh
config: lib: pkgs: extraArgs:
let
  cfgcommonlib = import ./lib/cfg_common_lib.nix;
  inherit (extraArgs) is_GUI extra_git_config;
in
[
  (cfgcommonlib.mkCfgCommon {
      shell_variables = {
        EDITOR = if is_GUI then "vim" else "code";
        # colored GCC warnings and errors
        GCC_COLORS ="error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01";
      };
      shell_paths = [
        "${config.home.homeDirectory}/.local/bin"
      ];
      home_packages = [
        pkgs.cacert
        pkgs.vim
        pkgs.which
        pkgs.gnumake
        pkgs.less
        pkgs.lesspipe
        pkgs.htop
        pkgs.gnugrep
        pkgs.ripgrep
        pkgs.wget
        pkgs.curl
        pkgs.nix-prefetch-git
        pkgs.jq
        pkgs.tmux
        # # Home Manager's way of installing fonts for home-manager
        # # TODO: Untested but looks okay
        # # https://discourse.nixos.org/t/home-manager-nerdfonts/11226
        # (pkgs.nerdfonts.override { fonts = [ "Hack Nerd Font" ]; })
      ];
      home_files = {
        ".vimrc".text = builtins.readFile ./.vimrc;
      };
      home_programs = {
        man = {
          enable = true;
          generateCaches = true;
        };
        direnv = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          nix-direnv = {
            enable = true;
          };
        };
        git = {
          enable = true;
          lfs.enable = true;
          aliases = {
            com = "commit ";
            coma = "commit --amend ";
            show = "show";
            add = "add ";
            mrg = "merge ";
            pull = "pull";
            push = "push";
            co = "checkout ";
            lg = "log";
            diff = "diff ";
            st = "status";
            dmas = "diff origin/master...";
            dmai = "diff origin/main...";
            rsl = "reset HEAD~1 --soft";
            rmrg = "reset --merge ORIG_HEAD";
            stal = "stash list";
            staa = "stash apply";
            stad = "stash drop";
            stas = "stash save ";
            sta = "stash ";
          };
        } // lib.optionalAttrs (extra_git_config != null) extra_git_config;
      } // lib.optionalAttrs is_GUI {
        vscode = {
          enable = true;
          package = pkgs.vscode;
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
      shell_aliases = {
        ls = "ls -GFh --color=auto";
        # some more ls aliases;
        ll = "ls -alF --color=auto";
        la = "ls -A --color=auto";
        l = "ls -CF --color=auto";
        lath = "ls -lath --color=auto";
        #dir = "dir --color=auto";
        #vdir = "vdir --color=auto";
        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";
        g = "git ";
        py = "python ";
        ########
        # Git related
        ########
        gcom = "git commit ";
        gcoma = "git commit --amend ";
        gshow = "git show";
        gadd = "git add ";
        gmrg = "git merge ";
        gpull = "git pull";
        gpush = "git push";
        gco = "git checkout ";
        glg = "git log";
        gdiff = "git diff ";
        gst = "git status";
        gdmas = "git diff origin/master...";
        gdmai = "git diff origin/main...";
        grsl = "git reset HEAD~1 --soft";
        grmrg = "git reset --merge ORIG_HEAD";
        gstal = "git stash list";
        gstaa = "git stash apply";
        gstad = "git stash drop";
        gstas = "git stash save ";
        gsta = "git stash ";
        ######
        # Port checking command
        ######
        grep-port-listen="lsof -i -P -n | grep LISTEN";
        #######
        # SSH config
        #######
        showssh="cat ~/.ssh/config| grep Host";
        # kubernetes
        k="kubectl ";
        # Nix aliases
        nxflup = "nix flake lock"; # Update all flake inputs
        nxflupi = "nix flake lock --update-input";
        nxcfgcd = "cd ~/.config/nixpkgs";
        nxrp = "nix repl";
      };
      shell_functions = [
        ''
        # Simple edit function
        function e() {
          # use $EDITOR, otherwise if not found fallback to vim
          local editor="${EDITOR:-vi}"
          $editor $@
        }
        ''
        ''
        function gf() {
          branch=$1;
          shift;
          git fetch origin -f "$branch":"$branch"
        }
        ''
        ''
        function gnb() {
          branch_to_checkout=$1;
          shift;
          git checkout "$branch_to_checkout" && git pull && git checkout -b $@
          echo "rest of args is: $@"
        }
        ''
        ''
        function gpretty() {
          # Pretty prints between 2 revisions e.g. tag_name against master
          prev_rev=$1;
          current_rev=$2;
          git log --pretty=format:%s%n%b%n----------- --merges --first-parent $prev_rev..$current_rev
        }
        ''
        ''
        function gprunelocal() {
          # Prunes local branches that have been orphaned (remote deleted etc.)
          # Does a dry run if no args specified, must include a yes to prune for real
          should_prune=$1
          if [[ $should_prune == 'YES' ]]
          then
            git remote prune origin
          else
            git remote prune origin --dry-run
          fi
        }
        ''
        ''
        ######
        # Rsync and SSH utils
        ######
        function rsynccp() {
          # Uses rsync with the following options -chavzP --stats to copy from remote to local
          # For explanation of what the flags do, check man rsync OR http://explainshell.com/explain?cmd=rsync+-chavzP+--stats+user%40remote.host%3A%2Fpath%2Fto%2Fcopy+%2Fpath%2Fto%2Flocal%2Fstorage
          if [[ $# -ne 2 ]]; then
            echo "2 args required: ssh-host@ssh-ip:/path/to/file/or/dir /path/to/destination"
            echo "You passed in $#"
            return 2
          fi
        
          rsync -chavzP --stats $1 $2
        }
        ''
        ''
        ## Nix functions
        function nxsh() {
          local restore=$PWD
          cd ~/.config/nixpkgs
          # nix develop $@
          nix-shell $@
          cd $restore
        }
        ''
      ];
      shell_extracommoninit = [
        ''
        # Load initial extra shell dotfiles
        for file in ~/.{rcextra}; do
          [ -r "$file" ] && [ -f "$file" ] && source "$file";
        done;
        ''
      ];
      shell_extracommon = [
        ''
        if [ -x /usr/bin/dircolors ]; then
          test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        fi
        ''
        ''
        # make less more friendly for non-text input files, see lesspipe(1)
        [ -x ${pkgs.lesspipe}/bin/lesspipe.sh ] && eval "$(SHELL=${pkgs.bash} ${pkgs.lesspipe}/bin/lesspipe.sh)"
        ''
      ];
  })
]