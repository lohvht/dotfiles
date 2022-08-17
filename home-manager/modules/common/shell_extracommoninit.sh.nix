{ config, ... }:
''
  mkdir -p ${config.home.homeDirectory}/.vim/backups
  mkdir -p ${config.home.homeDirectory}/.vim/swaps
  mkdir -p ${config.home.homeDirectory}/.vim/undo

  # Load initial extra shell dotfiles
  for file in ~/.{aliasextra,rcextra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
  done;
''
