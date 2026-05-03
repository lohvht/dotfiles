{ config, lib, pkgs, ... }@inputs:
let
  cfg = config.customHomeProfile.blurayCd.handbrake;
  shell_extracommon_str = ''
    ########## Module blurayCd.handbrake Init Extra Start ##########
    ########## Module blurayCd.handbrake Init Extra End ##########
  '';
  custom_handbrake_pkg = pkgs.handbrake.overrideAttrs(old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
      pkgs.autoAddDriverRunpath
    ];
  });
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
