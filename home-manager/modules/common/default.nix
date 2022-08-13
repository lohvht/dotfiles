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
    ./gui.nix
  ];
  config = (lib.mkMerge [
    (lib.mkIf (gitCfg.username != null) {
      programs.git.userName = gitCfg.username;
    })
    (lib.mkIf (gitCfg.userEmail != null) {
      programs.git.userEmail = gitCfg.userEmail;
    })
    {
      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;
      # Allow installation of non-free pkgs
      nixpkgs.config.allowUnfree = true;
      # Allow allow fontconfig to discover fonts and configurations installed through home.packages and nix-env. 
      fonts.fontconfig.enable = true;

      home.sessionVariables = {
        EDITOR = if isGUIEnable then "code" else "vim";
        # colored GCC warnings and errors
        GCC_COLORS ="error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01";
      };
      home.sessionPath = [
        "${config.home.homeDirectory}/.local/bin"
      ];
      home.packages = [
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
        pkgs.zsh-powerlevel10k
        pkgs.meslo-lgs-nf # The Meslo Nerd Font patched for Powerlevel10k
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
        nxcd = "cd ${NXPKGS_CFG_PATH}";
        nxrp = "nix repl";
        nxclean = "nix-store --gc";
        nxcleandeep = "nix-collect-garbage -d";
        hmclean = "home-manager expire-generations now";
        hmls = ''awk '/^###### HOMECONFIG PROFILES START/{p=1;next};/^###### HOMECONFIG PROFILES END/{p=0};p' ~/.config/nixpkgs/flake.nix | awk -F'=' '{print $1}' | awk '{$1=$1;print}' '';
      };
      programs.man = { enable = true; generateCaches = true; };
      programs.direnv = { enable = true; enableBashIntegration = true; enableZshIntegration = true; nix-direnv.enable = true; };
      programs.git = {
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
      };      
    }
  ]);
}
