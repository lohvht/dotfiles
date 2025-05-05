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
    (lib.mkIf (pkgs.stdenv.isLinux && cfg.libreoffice.enable) {
      home.packages = [
        pkgs.libreoffice-qt
        pkgs.hunspell
        pkgs.hunspellDicts.en_GB-ise
      ];
    })
    (lib.mkIf (pkgs.stdenv.isLinux && cfg.nextcloudClient.enable) {
      home.packages = [
        nextcloud_client_pkg
      ];
      services.nextcloud-client = {
        enable = true;
        package = nextcloud_client_pkg;
        startInBackground = true;
      };
      systemd.user.services.nextcloud-client = {
        Unit = {
          After = pkgs.lib.mkForce "graphical-session.target";
        };
        Service = {
          Environment = pkgs.lib.mkForce "PATH=${config.home.profileDirectory}/bin:/usr/bin";
        };
      };
      # TODO: Find a way to nixify this without exposing too much
      # # See https://github.com/nextcloud/desktop/blob/71dbd1103f96ea909e79e8c2d4f87331b248d73a/doc/conffile.rst
      # # for configuration option
      # xdg.configFile."Nextcloud/nextcloud.cfg".text = ''
      #   [General]
      #   showExperimentalOptions=true
      # '';
    })
    # (lib.mkIf (pkgs.stdenv.isLinux && cfg.gaming.enable) {
    #   home.packages = [
    #     (guilib.nixGLWrap (pkgs.lutris.override {
    #       extraLibraries = pkgs: [
    #         # List library dependencies here
    #         pkgs.dxvk
    #       ];
    #       extraPkgs = pkgs: [
    #         # List package dependencies here
    #       ];
    #     }))
    #   ];
    # })
    (lib.mkIf (pkgs.stdenv.isLinux && cfg.gaming.enable) {
      programs.mangohud = {
        enable = true;
        enableSessionWide = false;
      };
    })
    (lib.mkIf (pkgs.stdenv.isLinux && cfg.gaming.enable && cfg.gaming.animeGameLauncherRunnerName != null) {
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initContent = shell_extracommon_str;
    })
    (lib.mkIf cfg.communications.ms_teams.enable {
      home.packages = [
        pkgs.teams
      ];
    })
    (lib.mkIf cfg.communications.zoom.enable {
      home.packages = [
        pkgs.zoom-us
      ];
    })
    (lib.mkIf cfg.communications.discord.enable {
      home.packages = [
        pkgs.discord
      ];
    })
    (lib.mkIf cfg.communications.thunderbird.enable {
      home.packages = [
        pkgs.thunderbird
      ];
    })
    (lib.mkIf cfg.communications.slack.enable {
      home.packages = [
        pkgs.slack
      ];
    })
    (lib.mkIf cfg.development.apiClient.enable {
      home.packages = [
        pkgs.bruno
      ];
    })
    # TODO: lohvht@22dec2024: See if possible to setup different language input keyboard (IME/IMF)
    # support via nix exclusively.
    # ATM I followed this guide for fcitx5 + KDE Plasma on Wayland integration:
    # https://wiki.archlinux.org/title/Input_method
    # https://wiki.archlinux.org/title/Fcitx5#Integration
    #
    # Install these packages
    # ```
    # sudo pacman -S fcitx5 fcitx5-configtool
    # sudo pacman -S fcitx5-chinese-addons fcitx5-pinyin-zhwiki  # Chinese / Pinyin
    # yay -S fcitx5-mozc-ut # Japanese, select mozc-ut for wider JP dictionary
    # ```
    # Export this env var as stated here: https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland#KDE_Plasma
    #
    # ```
    # export XMODIFIERS=@im=fcitx
    # ```
    #
    # Then go ahead to KDE, Settings > Keyboard > Virtual Keyboard and select either one of the fcitx5 options
    # After restarting, you should be able to select input method from the KDE settings
    #
    {
      home.packages = [
        pkgs.nixgl.auto.nixGLDefault
        pkgs.obsidian
        pkgs.wxhexeditor
      ];
      xdg.systemDirs.data = [
        "/home/vloh/.local/share/flatpak/exports/share"
        "/var/lib/flatpak/exports/share"
      ];
    }
  ]);
}
