{ config, lib, pkgs, ... }:
let
  desktopWrap = { name, ... }@makeDesktopItemInput:
    let
      desktop_item = pkgs.makeDesktopItem makeDesktopItemInput;
    in
    {
      ".local/share/applications/${name}.desktop" = {
        source = "${desktop_item}/share/applications/${name}.desktop";
        executable = true;
      };
    };
in
{
  inherit desktopWrap;
}
