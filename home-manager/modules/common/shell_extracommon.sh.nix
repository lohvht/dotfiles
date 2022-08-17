{ pkgs, ... }:
''
  if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  fi
  # make less more friendly for non-text input files, see lesspipe(1)
  [ -x ${pkgs.lesspipe}/bin/lesspipe.sh ] && eval "$(SHELL=${pkgs.bash} ${pkgs.lesspipe}/bin/lesspipe.sh)"
''
