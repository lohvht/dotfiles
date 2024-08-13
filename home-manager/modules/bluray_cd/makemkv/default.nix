{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.blurayCd.makemkv;
  shell_extracommon_str = ''
    ########## Module blurayCd.makemkv Init Extra Start ##########
    ########## Module blurayCd.makemkv Init Extra End ##########
  '';
  isGUIEnabled = config.customHomeProfile.GUI.enable;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
    }
    (lib.mkIf isGUIEnabled {
      home.packages = [
        pkgs.makemkv
        pkgs.mkvtoolnix
      ];
    })
  ]);
}
