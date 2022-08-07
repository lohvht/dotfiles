# Returns the zsh programs used as well as the additional pkgs required for the zsh shell 
pkgs: extraArgs: { shell_function_str, shell_extracommon, shell_extracommoninit }:
let
  # utils
  stringifySetOptFn = shellOptions : let
    setOptCmdFn = v: if pkgs.lib.hasPrefix "-" v then "unsetopt" else "setopt";
  in pkgs.lib.concatStringsSep "\n" (
    map (v: "${setOptCmdFn v} ${pkgs.lib.removePrefix "-" v}") shellOptions
  );

  shellOptions = [
    "-CASE_GLOB"            # Case insensitive globbing
    "GLOB_STAR_SHORT"       # Recursive globbing
    "INC_APPEND_HISTORY"    # save commands are added to the history immediately, otherwise only when shell exits.
    "GLOB_DOTS"             # Do not require a leading '.' in a filename to be matched explicitly
  ];
  setOptsStr = stringifySetOptFn shellOptions;
in
{
  home_packages = [
    pkgs.zsh-powerlevel10k
    pkgs.meslo-lgs-nf # The Meslo Nerd Font patched for Powerlevel10k
  ];
  home_files = {
    ".p10k.zsh".text = builtins.readFile ./.p10k.zsh;
  };
  home_programs = {
    zsh = {
      enable = true;
      # if only directory path is entered, cd there.
      autocd = true; # i.e. setopt AUTO_CD
      history = {
        size                  = 1000000;
        save                  = 1000000;
        ignoreDups            = true;    # i.e. setopt HIST_IGNORE_DUPS
        ignoreSpace           = true;    # i.e. setopt HIST_IGNORE_SPACE
        expireDuplicatesFirst = true;    # i.e. setopt HIST_EXPIRE_DUPS_FIRST
        extended              = true;    # i.e. setopt EXTENDED_HISTORY
        share                 = true;    # i.e. setopt SHARE_HISTORY
      };

      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;

      oh-my-zsh = {
        enable = true;
        # Which plugins would you like to load?
        # Standard plugins can be found in $ZSH/plugins/
        # Custom plugins may be added to $ZSH_CUSTOM/plugins/
        # Example format: plugins=(rails git textmate ruby lighthouse)
        # Add wisely, as too many plugins slow down shell startup.
        plugins = [
          # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/virtualenv
          "virtualenv"
          # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/virtualenvwrapper
          "virtualenvwrapper"
        ];
      };

      sessionVariables = {
        DEFAULT_USER = "`whoami`";
        # Uncomment the following line if you want to change the command execution time
        # stamp shown in the history command output.
        # You can set one of the optional three formats:
        # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
        # or set a custom format using the strftime function format specifications,
        # see 'man strftime' for details.
        HIST_STAMPS="%d/%m/%y %T";
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

      initExtraFirst = ''
        # Extra Init Shell Commands
        ${shell_extracommoninit}

        # Powerline 10k theme init
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';

      initExtra = ''
        # Extra shell opts for zsh
        ${setOptsStr}

        # Extra Shell Commands
        ${shell_extracommon}
        # Extra Shell Functions
        ${shell_function_str}

        # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '';
    };
  };
}
