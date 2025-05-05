{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.blurayCd.abcde;
  shell_extracommon_str = ''
    ########## Module blurayCd.abcde Init Extra Start ##########
    ########## Module blurayCd.abcde Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs.abcde
      ];
      home.shellAliases = {
        # Easy rip command to flac.
        rip_audio_cd = "abcde  -o 'flac:--best' -G";
      };
      home.file.".abcde.conf" = {
        text = builtins.readFile ./abcde.conf;
        executable = false;
      };
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initContent = shell_extracommon_str;
    }
  ]);
}
