{ config, ... }:
let
  NXPKGS_CFG_PATH = "${config.home.homeDirectory}/.config/nixpkgs";
in
''
  nxup() {
    local restore=$PWD
    cd ${NXPKGS_CFG_PATH}
    git pull
    nix-channel --update
    nix flake update $@
    cd $restore
  }

  hmapply() {
    local restore=$PWD
    cd ${NXPKGS_CFG_PATH}

    echo "Started applying of home manager profiles, showing possible profile values:"
    # This is functionally similar to hmls, because hmls isnt available due to the position of aliases definition under home-manager
    # We cannot use hmls directly.
    homeManagerProfiles="$(awk '/^        ###### HOMECONFIG PROFILES START/{p=1;next};/^        ###### HOMECONFIG PROFILES END/{p=0};p' ${NXPKGS_CFG_PATH}/flake.nix | awk -F'=' '{print $1}' | awk '{$1=$1;print}')"
    echo "$homeManagerProfiles"
    echo ""

    local homeProfileName=""
    if [ $# -gt 0 ]; then
      homeProfileName="$1"
      shift;
    else
      echo "please enter a home profile name to apply to via the list shown above, and then press [ENTER] "
      read homeProfileName
    fi
    local checkHomeProfile="$(echo "$homeManagerProfiles" | sed -n "/^$homeProfileName$/p")"
    if [ -z "$checkHomeProfile" ]; then
      echo "An invalid home profile name has been specified, the specified name was '$homeProfileName'"
      return 1
    fi

    echo "Running home manager profile switch on $homeProfileName now"
    home-manager switch --impure --flake .#$homeProfileName $@
    cd $restore
  }

  # Simple edit function
  e() {
    # use $EDITOR, otherwise if not found fallback to vim
    local editor="''${EDITOR:-vi}"
    eval $editor $@
  }

  gf() {
    branch=$1;
    shift;
    git fetch origin -f "$branch":"$branch"
  }

  gnb() {
    branch_to_checkout=$1;
    shift;
    git checkout "$branch_to_checkout" && git pull && git checkout -b $@
    echo "rest of args is: $@"
  }

  gpretty() {
    # Pretty prints between 2 revisions e.g. tag_name against master
    prev_rev=$1;
    current_rev=$2;
    git log --pretty=format:%s%n%b%n----------- --merges --first-parent $prev_rev..$current_rev
  }

  gprunelocal() {
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
  rsynccp() {
    # Uses rsync with the following options -chavzP --stats to copy from remote to local
    # For explanation of what the flags do, check man rsync OR http://explainshell.com/explain?cmd=rsync+-chavzP+--stats+user%40remote.host%3A%2Fpath%2Fto%2Fcopy+%2Fpath%2Fto%2Flocal%2Fstorage
    if [[ $# -ne 2 ]]; then
      echo "2 args required: ssh-host@ssh-ip:/path/to/file/or/dir /path/to/destination"
      echo "You passed in $#"
      return 2
    fi

    rsync -chavzP --stats $1 $2
  }

  ## Home manager functions
  hmclean() {
    echo "Started cleanup of home manager generations, showing generations"
    home-manager generations
    echo ""

    # TODO: Make it default to `now`, and specify an option instead, such as `--expire`
    local dateByDateCmd=""
    if [ $# -gt 0 ]; then
      dateByDateCmd="$1"
    else
      echo 'please enter a valid date string as passed in via `date -d`'
      echo 'such as "now"'
      echo 'and then press [ENTER] '
      read dateByDateCmd
    fi
    echo "Cleaning up home manager generations up to: $dateByDateCmd"
    home-manager expire-generations $dateByDateCmd
  }

  hmrollback() {
    echo "Started rollback of home manager generations, showing generations"
    home-manager generations
    echo ""

    local rollbackID=""
    if [ $# -gt 0 ]; then
      rollbackID="$1"
    else
      echo "please enter a valid ID to rollback to via the generations shown above, and then press [ENTER] "
      read rollbackID
    fi
    local generationPath="$(home-manager generations | awk -F 'id ' '{ print (NF>1) ? $NF : ""}' | sed -n "/^$rollbackID -/p" | awk -F "$rollbackID -> " '{ print (NF>1) ? $NF : ""}')"
    if [ -z "$generationPath" ]; then
      echo "An invalid generation ID has been specified, the specified generation was '$rollbackID'"
      return 1
    fi
    echo "Running rollback script now"
    echo "The path to the rollback script for generation '$rollbackID' is at $generationPath/activate"
    $generationPath/activate
  }

  ## Nix functions
  nxsh() {
    local restore=$PWD
    cd ${NXPKGS_CFG_PATH}
    # nix develop $@
    nix-shell $@
    cd $restore
  }

  # Taken from https://github.com/NixOS/nixpkgs/blob/8f868e1/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
  # first arg => publisher, second arg => extname
  function get_vsixpkg() {
      N="$1.$2"

      # Create a tempdir for the extension download.
      EXTTMP=$(mktemp -d -t vscode_exts_XXXXXXXX)

      URL="https://$1.gallery.vsassets.io/_apis/public/gallery/publisher/$1/extension/$2/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

      # Quietly but delicately curl down the file, blowing up at the first sign of trouble.
      curl --silent --show-error --retry 3 --fail -X GET -o "$EXTTMP/$N.zip" "$URL"
      # Unpack the file we need to stdout then pull out the version
      VER=$(jq -r '.version' <(unzip -qc "$EXTTMP/$N.zip" "extension/package.json"))
      # Calculate the SHA
      SHA=$(nix-hash --flat --base32 --type sha256 "$EXTTMP/$N.zip")

      # Clean up.
      rm -Rf "$EXTTMP"
      # I don't like 'rm -Rf' lurking in my scripts but this seems appropriate.

      cat <<-EOF
    {
      name = "$2";
      publisher = "$1";
      version = "$VER";
      sha256 = "$SHA";
    }
  EOF
  }
''
