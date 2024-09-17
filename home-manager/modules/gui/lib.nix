{ config, lib, pkgs, ... }:
let
  # Solution taken from hab25 from this link: https://github.com/guibou/nixGL/issues/44#issuecomment-1182548777
  # to use, for example in home.packages, simply just use it as `nixGLWrap pkgs.alacritty`
  nixGLWrap = pkg: nixGLWrapOpts pkg { };

  nixGLWrapOpts = pkg: { binSuffix ? ""
                       , wrapperSuffix ? ""
                       , nixGLPackage ? "mesa"
                       ,
                       }@options:
    let
      # NOTE: For nvidia - will need to install `prime-run` on system - this is usually located in the nvidia-prime package
      #
      # for arch based, do the following:
      #   pacman -S nvidia-prime
      nixGLRunCommand =
        if nixGLPackage == "nvidia" then "/usr/bin/prime-run ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL"
        else if nixGLPackage == "auto" then "${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL"
        else "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel";
    in
    pkgs.runCommand "${pkg.name}-nixgl-wrapper${wrapperSuffix}" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
        wrapped_bin=$out/bin/$(basename $bin)${binSuffix}
        cat <<EOF >$wrapped_bin
      #!${pkgs.bash}/bin/bash
      exec ${nixGLRunCommand} $bin \$@
      EOF
          chmod +x $wrapped_bin
        done
    '';
in
{
  inherit nixGLWrap;
  inherit nixGLWrapOpts;
}
