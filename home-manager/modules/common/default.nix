{ config, lib, pkgs, ... }@inputs:
let
  cfglib = import ../cfglib inputs;

  gitCfg = config.customHomeProfile.git;
  isVSCodeEnable = config.customHomeProfile.GUI.enable && config.customHomeProfile.GUI.vscode.enable;
  isCorsairKBMSupportEnable = config.customHomeProfile.corsairKeyboardMouseSupport.enable;
  NXPKGS_CFG_PATH = "~/.config/nixpkgs";
in
{
  imports = [
    ./shell_bash.nix
    ./shell_zsh.nix
  ];
  config = (lib.mkMerge [
    (lib.mkIf (gitCfg.username != null) {
      programs.git.userName = gitCfg.username;
    })
    (lib.mkIf (gitCfg.userEmail != null) {
      programs.git.userEmail = gitCfg.userEmail;
    })
    (lib.mkIf pkgs.stdenv.isLinux {
      # Make it easier for generic non-nixos linuxes
      targets.genericLinux.enable = true;
    })
    (lib.mkIf (pkgs.stdenv.isLinux && isCorsairKBMSupportEnable) {
      home.packages = [
        pkgs.ckb-next
      ];
    })
    {
      warnings = if cfglib.systemCtlPathInfo.isDefined then [ ] else [
        ''
          You have not provided a path to the systemctl for the given user. Given that this home-manager
          installation is mainly for non-NixOS modules, it is advised to set this value. You may
          get the path to systemctl via `which systemctl`
          
          A default value of ${cfglib.systemCtlPathInfo.path} will be used instead.
        ''
      ];
    }
    {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
      # Allow allow fontconfig to discover fonts and configurations installed through home.packages and nix-env. 
      fonts.fontconfig.enable = true;

      home.sessionVariables = {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        EDITOR = if isVSCodeEnable then "code --wait --new-window" else "vim";
        # colored GCC warnings and errors
        GCC_COLORS = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01";
      };
      home.sessionPath = [
        "${config.home.homeDirectory}/.local/bin"
      ];
      systemd.user.systemctlPath = cfglib.systemCtlPathInfo.path;
      home.packages = [
        pkgs.bitwarden-cli # password manager CLI
        pkgs._1password # 1password password manager cli
        pkgs.glibcLocales # Locales!
        pkgs.file # Determine file type.
        pkgs.which # Show full path of shell commands.
        pkgs.cron # Daemon to execute scheduled commands.
        pkgs.moreutils # Collection of useful tools that aren't coreutils. https://joeyh.name/code/moreutils/
        pkgs.tree # List directory contents in tree-like format.
        pkgs.bmon # Bandwidth monitor and rate estimator.
        pkgs.bind # DNS server (provides `dig`)
        pkgs.tcpdump # Dump traffic on a network.
        pkgs.ncdu # ncurses disk usage.
        pkgs.smartmontools # Hard-drive health monitoring via `smartctl` or `smartd`
        pkgs.unzip # uncompress `.zip` files.
        pkgs.zip # compress `.zip` files.
        pkgs.pre-commit # precommit hooks
        pkgs.git-crypt # git-crypt, for file level encryption
        pkgs.git-extras # extra functionality for git, such as adding co-authorship to last commit, repo summary etc etc
        pkgs.openvpn3
        pkgs.openconnect
        pkgs.global

        # Man pages
        pkgs.man
        pkgs.man-pages
        pkgs.man-pages-posix
        pkgs.stdman
        pkgs.cacert # A bundle of X.509 certificates of public Certificate Authorities (CA)
        pkgs.vim # vim
        pkgs.gnumake
        pkgs.less
        pkgs.lesspipe
        pkgs.htop # Interactive process viewer.
        pkgs.iotop # Top-like I/O monitor.
        pkgs.powertop # Power consumption and management diagnosis tool.
        pkgs.lshw # List hardware.
        pkgs.usbutils # Tools for working with usb devices (`lsusb`, etc.)
        pkgs.inetutils # Collection of common network programs, ping, ifconfig, hostname, traceroute etc
        pkgs.psmisc # Collection of utilities using proc filesystem (`pstree`, `killall`, etc.)
        pkgs.gnugrep
        pkgs.ripgrep
        pkgs.wget # Non-interactive network downloader.
        pkgs.curl
        pkgs.nix-prefetch-git
        pkgs.jq
        pkgs.tmux
        pkgs.zsh-powerlevel10k
        pkgs.meslo-lgs-nf # The Meslo Nerd Font patched for Powerlevel10k
        # More fonts
        pkgs.meslo-lg
        pkgs.source-code-pro
        pkgs.source-sans-pro
        pkgs.source-serif-pro
        pkgs.font-awesome_5
        pkgs.inconsolata
        pkgs.siji
        pkgs.material-icons
        pkgs.powerline-fonts
        pkgs.roboto
        pkgs.roboto-mono
        pkgs.roboto-slab
      ];
      home.file.".vimrc".text = builtins.readFile ./.vimrc;
      home.shellAliases = {
        # TODO: lohvht@21sept2022: Create either an alias or a shell function to handle help with all of my aliases
        #                          either by printing out to stdout / creating a man page etc etc
        #                          The sheer number of aliases/shell functions that I have are getting too much for me
        #                          to remember potentially useful commands that I might have forgotten.
        #                          If a tool is to be written for this, make sure to split the shell function into categories
        #                          i.e. git related, python related, general,,, 
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
        docker-compose = "docker compose";
        ########
        # Git related
        ########
        gcom = "git commit ";
        gcoma = "git commit --amend ";
        gshow = "git show";
        gadd = "git add ";
        gmrg = "git merge ";
        grb = "git rebase ";
        grbi = "git rebase -i ";
        gpull = "git pull";
        gpullrb = "git pull --rebase";
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
        gstam = "git stash save "; # i.e git stash with a message
        gstams = "git stash save --staged "; # i.e. git stash all staged files with a message
        gsta = "git stash ";
        gstas = "git stash --staged"; # i.e. git stash all staged files
        # TODO: Expand this coauthor to include reading from a list of registered co-authors, so that we can add by alias instead of
        #       always specifying a username / email
        gca = "git coauthor"; # git coauthor <username> <email>
        ######
        # Port checking command
        ######
        grep-port-listen = "lsof -i -P -n | grep LISTEN";
        #######
        # SSH config
        #######
        showssh = "cat ~/.ssh/config| grep Host";
        # Nix aliases
        nxcd = "cd ${NXPKGS_CFG_PATH}";
        nxe = "e ${NXPKGS_CFG_PATH}";
        nxrp = "nix repl";
        nxclean = "nix-store --gc";
        nxcleandeep = "nix-collect-garbage -d";
        hmgens = "home-manager generations";
        hmls = ''awk '/^        ###### HOMECONFIG PROFILES START/{p=1;next};/^        ###### HOMECONFIG PROFILES END/{p=0};p' ${NXPKGS_CFG_PATH}/flake.nix | awk -F'=' '{print $1}' | awk '{$1=$1;print}' '';
      };
      programs.man = { enable = true; generateCaches = true; };
      programs.direnv = { enable = true; enableBashIntegration = true; enableZshIntegration = true; nix-direnv.enable = true; };
      programs.git = {
        # TODO: Add fancy git related stuff such as contributors tag, pre-commit hooks etc 
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
          stam = "stash save ";
          stams = "stash save --staged ";
          sta = "stash ";
          stas = "stash --staged";
          rb = "rebase ";
          rbi = "rebase -i ";
          pullrb = "pull --rebase";
          ca = "coauthor";
        };
        extraConfig = {
          init.defaultBranch = "main";
        };
      };
    }
  ]);
}
