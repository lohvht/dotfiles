{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.blurayCd.mkvtoolnix;
  shell_extracommon_str = ''
    ########## Module blurayCd.mkvtoolnix Init Extra Start ##########
    ########## Module blurayCd.mkvtoolnix Init Extra End ##########
  '';
  isGUIEnabled = config.customHomeProfile.GUI.enable;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initContent = shell_extracommon_str;
    }
    (lib.mkIf isGUIEnabled {
      home.packages = [
        pkgs.mkvtoolnix
      ];
    })
  ]);
}
