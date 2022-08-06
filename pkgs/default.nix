# When you add custom packages, list them here
# TODO: This is not the packages we're installing. this is to add additional
#       custom packages for nixpkgs so that we can install them
{ pkgs }: {
  pyenv = pkgs.callPackage ./pyenv { };
  nvm = pkgs.callPackage ./nvm { };
}
