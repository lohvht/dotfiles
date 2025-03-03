{ config, lib, pkgs, ... }:
let
  # https://nur.nix-community.org/repos/rycee/
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  isGUIEnabled = config.customHomeProfile.GUI.enable;
  cfg = config.customHomeProfile.passwordManagers.bitwarden;
  extensions = [
    firefox-addons.bitwarden
  ];
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [
        pkgs.bitwarden-cli
      ];
    }
    (lib.mkIf isGUIEnabled {
      home.packages = [
        pkgs.bitwarden
      ];
      programs.firefox.profiles.default.extensions.packages = extensions;
      programs.firefox.profiles.private.extensions.packages = extensions;
    })
  ]);
}
