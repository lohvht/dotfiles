{ config, lib, pkgs, ... }@moduleargs:
let
  # utils
  stringifyZSHSetOptFn = zshShellOptions:
    let
      setOptCmdFn = v: if pkgs.lib.hasPrefix "-" v then "unsetopt" else "setopt";
    in
    pkgs.lib.concatStringsSep "\n" (
      map (v: "${setOptCmdFn v} ${pkgs.lib.removePrefix "-" v}") zshShellOptions
    );

  # Options
  zshShellOptions = [
    "-CASE_GLOB" # Case insensitive globbing
    "GLOB_STAR_SHORT" # Recursive globbing
    "INC_APPEND_HISTORY" # save commands are added to the history immediately, otherwise only when shell exits.
    "GLOB_DOTS" # Do not require a leading '.' in a filename to be matched explicitly
  ];

  zshSetOptsStr = stringifyZSHSetOptFn zshShellOptions;
  shell_function_str = import ./shell_functions.sh.nix moduleargs;
  shell_extracommoninit_str = import ./shell_extracommoninit.sh.nix moduleargs;
  shell_extracommon_str = import ./shell_extracommon.sh.nix moduleargs;
in
{
  config = (lib.mkMerge [
    {
      home.file.".p10k.zsh".text = builtins.readFile ./.p10k.zsh;
      home.packages = [
        pkgs.zsh-powerlevel10k
      ];
      programs.zsh = {
        enable = true;
        # if only directory path is entered, cd there.
        autocd = true; # i.e. setopt AUTO_CD
        history = {
          size = 1000000;
          save = 1000000;
          ignoreDups = true; # i.e. setopt HIST_IGNORE_DUPS
          ignoreSpace = true; # i.e. setopt HIST_IGNORE_SPACE
          expireDuplicatesFirst = true; # i.e. setopt HIST_EXPIRE_DUPS_FIRST
          extended = true; # i.e. setopt EXTENDED_HISTORY
          share = false; # i.e. setopt SHARE_HISTORY
        };

        enableAutosuggestions = true;
        enableCompletion = true;
        enableSyntaxHighlighting = true;

        sessionVariables = {
          DEFAULT_USER = "`whoami`";
          # Uncomment the following line if you want to change the command execution time
          # stamp shown in the history command output.
          # You can set one of the optional three formats:
          # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
          # or set a custom format using the strftime function format specifications,
          # see 'man strftime' for details.
          HIST_STAMPS = "%d/%m/%y %T";
          # # Set name of the theme to load --- if set to "random", it will
          # # load a random theme each time oh-my-zsh is loaded, in which case,
          # # to know which specific one was loaded, run: echo $RANDOM_THEME
          # # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
          # ZSH_THEME="powerlevel10k/powerlevel10k";

          # Set list of themes to pick from when loading at random
          # Setting this variable when ZSH_THEME=random will cause zsh to load
          # a theme from this variable instead of looking in $ZSH/themes/
          # If set to an empty array, this variable will have no effect.
          # # ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" );

          # Uncomment the following line to use case-sensitive completion.
          # CASE_SENSITIVE="true"

          # Uncomment the following line to use hyphen-insensitive completion.
          # Case-sensitive completion must be off. _ and - will be interchangeable.
          # HYPHEN_INSENSITIVE="true"

          # Uncomment the following line to disable bi-weekly auto-update checks.
          # DISABLE_AUTO_UPDATE="true"

          # Uncomment the following line to automatically update without prompting.
          # DISABLE_UPDATE_PROMPT="true"

          # Uncomment the following line to change how often to auto-update (in days).
          # export UPDATE_ZSH_DAYS=13

          # Uncomment the following line if pasting URLs and other text is messed up.
          # DISABLE_MAGIC_FUNCTIONS="true"

          # Uncomment the following line to disable colors in ls.
          # DISABLE_LS_COLORS="true"

          # Uncomment the following line to disable auto-setting terminal title.
          # DISABLE_AUTO_TITLE="true"

          # Uncomment the following line to enable command auto-correction.
          # ENABLE_CORRECTION="true"

          # Uncomment the following line to display red dots whilst waiting for completion.
          # Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
          # See https://github.com/ohmyzsh/ohmyzsh/issues/5765
          # COMPLETION_WAITING_DOTS="true"

          # Uncomment the following line if you want to disable marking untracked files
          # under VCS as dirty. This makes repository status check for large repositories
          # much, much faster.
          # DISABLE_UNTRACKED_FILES_DIRTY="true"

          # Would you like to use another custom folder than $ZSH/custom?
          # ZSH_CUSTOM=/path/to/new-custom-folder
        };

        oh-my-zsh = {
          enable = true;
          # Which plugins would you like to load?
          # Standard plugins can be found in $ZSH/plugins/
          # Custom plugins may be added to $ZSH_CUSTOM/plugins/
          # Example format: plugins=(rails git textmate ruby lighthouse)
          # Add wisely, as too many plugins slow down shell startup.
        };

        profileExtra = ''
          if [ -e ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh ]; then . ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
        '';

        initExtraFirst = ''
          ########## Module Common Init ExtraTop Start ##########
          # Extra Init Shell Commands
          ${shell_extracommoninit_str}

          # Powerline 10k theme init
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

          # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
          # Initialization code that may require console input (password prompts, [y/n]
          # confirmations, etc.) must go above this block; everything else may go below.
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
          ########## Module Common Init ExtraTop End ##########
        '';

        initExtra = ''
          ########## Module Common Init Extra Start ##########
          # Extra shell opts for zsh
          ${zshSetOptsStr}
          # Extra Shell Commands
          ${shell_extracommon_str}
          # Extra Shell Functions
          ${shell_function_str}

          # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
          ########## Module Common Init Extra End ##########
        '';
      };
    }
  ]);
}
