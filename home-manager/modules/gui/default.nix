{ config, lib, pkgs, ... }@inputs:
let
  guilib = import ./lib.nix inputs;
  cfg = config.customHomeProfile.GUI;

  # NOTE: *that* an-anime-game-launcher specific, assume that installation is done in linux via the
  # appropriate channels (not going to link here, but lookup 'n-anime-game-launcher')
  # The defaults here are usually the same and its *USUALLY* safe to go ahead and delete to reinstall
  # These settings if we somehow bork the relevant configuration
  # We need to set the config here ourselves, mimicking the logic from here:
  # https://github.com/an-anime-team/an-anime-game-launcher/blob/1297490df7034af3b5385cc269659f23fb61abe2/src/ts/launcher/states/Launch.ts
  # Because we cannot run the game directly somehow (due to the telemetry code & how in our local system we cannot call it)
  agl_root = "${config.home.homeDirectory}/.local/share/anime-game-launcher";

  agl_env_vars = builtins.concatStringsSep " " [
    "WINEPREFIX='${agl_root}/game'"
    # hud
    "MANGOHUD=1"
    # dxvk async
    "DXVK_ASYNC=1"
    # Wine synchro, see here: https://github.com/AdelKS/LinuxGamingGuide#wine-tkg
    "WINEESYNC=1"
  ];
  agl_wine_executable = "${agl_root}/runners/${cfg.gaming.animeGameLauncherRunnerName}/bin/wine64";
  agl_gamedir = ''${agl_root}/game/drive_c/Program\ Files/Genshin\ Impact'';
  agl_game_exe = "${agl_gamedir}/GenshinImpact.exe";
  command = builtins.concatStringsSep " " [
    "gamemoderun" # If game mode is installed
    agl_wine_executable
    "${agl_gamedir}/unlockfps.bat" # ${agl_gamedir}/launcher.bat ==> original launcher.bat, replace when unlockfps gives error "Do not place unlocker as the same folder as the game"
  ];
  shell_extracommon_str = ''
    ########## Module Gaming Init Extra Start ##########
    genshin_start() {
      local restore=$PWD
      cd ${agl_gamedir}
      ${agl_env_vars} nohup ${command} &
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
        pkgs._1password-gui
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
