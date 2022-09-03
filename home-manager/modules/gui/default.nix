{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.GUI;
  # NOTE: *that* an-anime-game-launcher specific, assume that installation is done in linux via the
  # appropriate channels (not going to link here, but lookup 'n-anime-game-launcher')
  # The defaults here are usually the same and its *USUALLY* safe to go ahead and delete to reinstall
  # These settings if we somehow bork the relevant configuration
  agl_root = "${config.home.homeDirectory}/.local/share/anime-game-launcher";
in
{
  imports = [
    ./browser.nix
    ./vscode.nix
    ./conky.nix
  ];
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (pkgs.stdenv.isLinux && cfg.gaming.enable && cfg.gaming.animeGameLauncherRunnerName != null) {
      home.shellAliases = {
        genshin_start = ''WINEPREFIX='${agl_root}/game' ${agl_root}/runners/${cfg.gaming.animeGameLauncherRunnerName}/bin/wine64 ${agl_root}/game/drive_c/Program\ Files/Genshin\ Impact/GenshinImpact.exe'';
      };
    })
    (lib.mkIf pkgs.stdenv.isLinux {
      home.file = {
        ".local/share/applications/Alacritty.desktop" = {
          text = ''
            [Desktop Entry]
            Categories=System;TerminalEmulator;
            Exec=nixGL alacritty
            GenericName=Terminal
            Icon=${pkgs.alacritty}/share/icons/hicolor/scalable/apps/Alacritty.svg
            Name=Alacritty
            Type=Application
            Terminal=false
            Comment=A fast, cross-platform, OpenGL terminal emulator
            StartupWMClass=Alacritty
            Actions=New;

            [Desktop Action New]
            Name=Open a New Terminal
            Icon=${pkgs.alacritty}/share/icons/hicolor/scalable/apps/Alacritty.svg
            Exec=nixGL alacritty
          '';
          executable = true;
        };
      };
    })
    {
      home.packages = [
        pkgs.nixgl.auto.nixGLDefault
        pkgs.bitwarden
        pkgs.teams
        pkgs.zoom-us
        pkgs.discord
        pkgs.thunderbird
        pkgs.slack
      ];
      programs.alacritty = {
        # Alacritty is a terminal emulator
        # TODO: add in alacritty settings a la
        # https://github.com/alacritty/alacritty
        # Below are some examples on how
        # https://github.com/davidtwco/veritas/blob/6f2c676a76ef2885c9102aeaea874c361dbcaf61/home/configs/alacritty.nix
        # https://arslan.io/2018/02/05/gpu-accelerated-terminal-alacritty/
        # https://pezcoder.medium.com/how-i-migrated-from-iterm-to-alacritty-c50a04705f95
        enable = true;
        package = pkgs.alacritty;
      };
    }
  ]);
}
