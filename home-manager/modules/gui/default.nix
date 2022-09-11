{ config, lib, pkgs, ... }@inputs:
let
  guilib = import ./lib.nix inputs;
  cfg = config.customHomeProfile.GUI;

  # NOTE: *that* an-anime-game-launcher specific, assume that installation is done in linux via the
  # appropriate channels (not going to link here, but lookup 'n-anime-game-launcher')
  # The defaults here are usually the same and its *USUALLY* safe to go ahead and delete to reinstall
  # These settings if we somehow bork the relevant configuration
  agl_root = "${config.home.homeDirectory}/.local/share/anime-game-launcher";
  shell_extracommon_str = ''
    ########## Module Gaming Init Extra Start ##########
    genshin_start() {
      local restore=$PWD
      cd /tmp
      WINEPREFIX='${agl_root}/game' nohup ${agl_root}/runners/${cfg.gaming.animeGameLauncherRunnerName}/bin/wine64 ${agl_root}/game/drive_c/Program\ Files/Genshin\ Impact/GenshinImpact.exe &
      cd $restore
    }
    ########## Module Gaming Init Extra End ##########
  '';
  nextcloud_client_pkg = guilib.nixGLWrap pkgs.nextcloud-client;
in
{
  imports = [
    ./browser.nix
    ./vscode.nix
    ./conky.nix
  ];
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (pkgs.stdenv.isLinux && cfg.nextcloudClient.enable) {
      home.packages = [
        nextcloud_client_pkg
      ];
      services.nextcloud-client = {
        enable = true;
        package = nextcloud_client_pkg;
        startInBackground = true;
      };
      # TODO: Find a way to nixify this without exposing too much
      # # See https://github.com/nextcloud/desktop/blob/71dbd1103f96ea909e79e8c2d4f87331b248d73a/doc/conffile.rst
      # # for configuration option
      # xdg.configFile."Nextcloud/nextcloud.cfg".text = ''
      #   [General]
      #   showExperimentalOptions=true
      # '';
    })
    (lib.mkIf (pkgs.stdenv.isLinux && cfg.gaming.enable && cfg.gaming.animeGameLauncherRunnerName != null) {
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
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
        pkgs.obsidian
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
        package = guilib.nixGLWrap pkgs.alacritty;
      };
    }
  ]);
}
