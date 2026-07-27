{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.blurayCd.mkvtoolnix;
  pkg = pkgs.mkvtoolnix;
  shell_extracommon_str = ''
    ########## Module blurayCd.mkvtoolnix Init Extra Start ##########
    mkv_extractedit_chapters() {
      if [ "$#" -ne 1 ]; then
        printf "Pass a single MKV file to edit its chapters\n" >&2;
        return 1
      fi
      file=$1;

      new_tmp="$(${pkgs.coreutils}/bin/mktemp -t chapters.XXXXXXXXXX.xml)"
      if [ -z "$new_tmp" ] || [ ! -f "$new_tmp" ]; then
        print "Unable to create the tempfile for chapters\n" >&2;
        return 1
      fi
      printf "Extracting chapters for file '%s' to '%s'\n" "$file" "$new_tmp"
      ${pkg}/bin/mkvextract chapters "$file" > "$new_tmp"

      tmp_xml_sha="$(${pkgs.coreutils}/bin/sha256sum "$new_tmp")"
      printf "Editing chapter files at '%s'\n" "$new_tmp"
      e -w "$new_tmp"
      _=$(print "$tmp_xml_sha" | sha256sum --check 2>/dev/null)
      if [ "$?" -eq 0 ]; then
        printf "Chapters not edited, exiting without edits\n"
        return 0
      fi
      ${pkg}/bin/mkvpropedit "$file" --chapters "$new_tmp"
      print "DONE!"
    }
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
        pkg
      ];
    })
  ]);
}
