{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.musicCd;
  shell_extracommon_str = ''
    ########## Module musicCd Init Extra Start ##########
    ########## Module musicCd Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs.abcde
        pkgs.picard
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
