{ config, lib, pkgs, ... }@inputs:
let
  cfg = config.customHomeProfile.blurayCd.handbrake;
  gpus = config.systemHardwareInfo.gpus;

  shell_extracommon_str = ''
    ########## Module blurayCd.handbrake Init Extra Start ##########
    ########## Module blurayCd.handbrake Init Extra End ##########
  '';
  guilib = import ../../gui/lib.nix inputs;
  hasNvidia = lib.any (g: g.driver == "nvidia") gpus;
  hasAMD = lib.any (g: g.driver == "amdgpu") gpus;
  nixGLToUse = if hasNvidia then "nvidia" else if hasAMD then "auto" else "mesa";
  custom_handbrake_pkg = guilib.nixGLWrapOpts pkgs.handbrake { nixGLPackage = nixGLToUse; };
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        custom_handbrake_pkg
      ];
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initContent = shell_extracommon_str;
    }
  ]);
}
