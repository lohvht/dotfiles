{ config, lib, pkgs, ... }:
let
  gitCfg = config.customHomeProfile.git;
  isGUIEnable = config.customHomeProfile.GUI.enable;
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
    {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
      # Allow allow fontconfig to discover fonts and configurations installed through home.packages and nix-env. 
      fonts.fontconfig.enable = true;

      home.sessionVariables = {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        # TODO: solve this issue once and for all, codium is the free open source version of vscode that we'll install via this home-manager
        # installation, but for windows we still use `code` for convenience, need to find a way to check for WSL, else check for linux / darwin
        # EDITOR = if isGUIEnable then "codium" else "vim";
        # colored GCC warnings and errors
        GCC_COLORS = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01";
      };
      home.sessionPath = [
        "${config.home.homeDirectory}/.local/bin"
      ];
      home.packages = [
        pkgs.bitwarden-cli # password manager CLI
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
        # Man pages
        pkgs.man
        pkgs.man-pages
        pkgs.posix_man_pages
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
        gstas = "git stash save ";
        gsta = "git stash ";
        ######
        # Port checking command
        ######
        grep-port-listen = "lsof -i -P -n | grep LISTEN";
        #######
        # SSH config
        #######
        showssh = "cat ~/.ssh/config| grep Host";
        # kubernetes
        k = "kubectl ";
        # Nix aliases
        nxcd = "cd ${NXPKGS_CFG_PATH}";
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
          stas = "stash save ";
          sta = "stash ";
          rb = "rebase ";
          rbi = "rebase -i ";
          pullrb = "pull --rebase";
        };
        extraConfig = {
          init.defaultBranch = "main";
        };
      };
    }
  ]);
}
