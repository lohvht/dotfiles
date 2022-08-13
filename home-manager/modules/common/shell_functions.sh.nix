{ config, ... }:
let
  NXPKGS_CFG_PATH = "${config.home.homeDirectory}/.config/nixpkgs";
in
''
function nxup() {
  local restore=$PWD
  cd ${NXPKGS_CFG_PATH}
  nix-channel --update
  nix flake update $@
  cd $restore
}

function hmapply() {
  local restore=$PWD
  cd ${NXPKGS_CFG_PATH}
  home-manager switch --impure --flake .#$@
  cd $restore
}

# Simple edit function
function e() {
  # use $EDITOR, otherwise if not found fallback to vim
  local editor="''${EDITOR:-vi}"
  $editor $@
}

function gf() {
  branch=$1;
  shift;
  git fetch origin -f "$branch":"$branch"
}

function gnb() {
  branch_to_checkout=$1;
  shift;
  git checkout "$branch_to_checkout" && git pull && git checkout -b $@
  echo "rest of args is: $@"
}

function gpretty() {
  # Pretty prints between 2 revisions e.g. tag_name against master
  prev_rev=$1;
  current_rev=$2;
  git log --pretty=format:%s%n%b%n----------- --merges --first-parent $prev_rev..$current_rev
}

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

## Nix functions
function nxsh() {
  local restore=$PWD
  cd ${NXPKGS_CFG_PATH}
  # nix develop $@
  nix-shell $@
  cd $restore
}
''