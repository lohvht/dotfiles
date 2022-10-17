{ config, lib, pkgs, ... }@moduleargs:
let
  shell_function_str = import ./shell_functions.sh.nix moduleargs;
  shell_extracommoninit_str = import ./shell_extracommoninit.sh.nix moduleargs;
  shell_extracommon_str = import ./shell_extracommon.sh.nix moduleargs;
in
{
  config = (lib.mkMerge [
    {
      programs.bash = {
        enable = true;
        # don't put duplicate lines or lines starting with space in the history.
        # See bash(1) for more options
        historyControl = [ "ignorespace" "ignoredups" ];
        historyFileSize = 1000000;
        shellOptions = [
          "checkjobs" # Warn if closing shell with running jobs.
          "extglob" # If set, the extended pattern matching features are enabled.
          "nocaseglob" # Case insensitive globbing
          "autocd" # if only directory path is entered, cd there.
          "globstar" # Recursive globbing
          "histappend" # Immediately append history instead of overwriting
          "checkwinsize" # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
        ];

        sessionVariables = {
          PS1 = ''\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$'';
        } // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
          # Apparently this is how MacOS sees colour
          CLICOLOR = 1;
          LSCOLORS = "ExFxBxDxCxegedabagacad";
          # on mac, give support to wombat256 colors
          TERM = "xterm-256color";
        };

        profileExtra = ''
          if [ -e ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh ]; then . ${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
        '';

        bashrcExtra = ''
          ########## Module Common Init ExtraTop Start ##########
          ${shell_extracommoninit_str}
          ########## Module Common Init ExtraTop End ##########
        '';

        initExtra = ''
          ########## Module Common Init Extra Start ##########
          ${shell_extracommon_str}

          # Extra Shell Functions
          ${shell_function_str}
          ########## Module Common Init Extra End ##########
        '';
      };
    }
  ]);
}
