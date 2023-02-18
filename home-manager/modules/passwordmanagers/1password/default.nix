{ config, lib, pkgs, ... }@inputs:
let
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  isGUIEnabled = config.customHomeProfile.GUI.enable;
  cfg = config.customHomeProfile.passwordManagers._1password;
  extensions = [
    firefox-addons.onepassword-password-manager
  ];
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs._1password
      ];
    }
    (lib.mkIf isGUIEnabled {
      home.packages = [
        pkgs._1password-gui
      ];
      programs.firefox.profiles.default.extensions = extensions;
      programs.firefox.profiles.private.extensions = extensions;
    })
  ]);
}
