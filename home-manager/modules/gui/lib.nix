{ config, lib, pkgs, ... }:
let
  # Solution taken from hab25 from this link: https://github.com/guibou/nixGL/issues/44#issuecomment-1182548777
  # to use, for example in home.packages, simply just use it as `nixGLWrap pkgs.alacritty`
  nixGLWrap = pkg: nixGLWrapOpts pkg { };

  nixGLWrapOpts = pkg: { binSuffix ? ""
                       , wrapperSuffix ? ""
                       ,
                       }@options: pkgs.runCommand "${pkg.name}-nixgl-wrapper${wrapperSuffix}" { } ''
    mkdir $out
    ln -s ${pkg}/* $out
    rm $out/bin
    mkdir $out/bin
    for bin in ${pkg}/bin/*; do
      wrapped_bin=$out/bin/$(basename $bin)${binSuffix}
      cat <<EOF >$wrapped_bin
    #!${pkgs.bash}/bin/bash
    exec ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL $bin \$@
    EOF
      chmod +x $wrapped_bin
    done
  '';
in
{
  inherit nixGLWrap;
  inherit nixGLWrapOpts;
}
