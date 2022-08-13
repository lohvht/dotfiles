{ config, lib, pkgs, ... }:
let
  cfg = config.customHomeProfile.GUI;
  # https://nur.nix-community.org/repos/rycee/
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  ffcommon_settings = {
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.tabs.warnOnClose" = false;
    "extensions.pocket.enabled" = false;
    "privacy.donottrackheader.enabled" = true;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;
  };
  ffprivate_settings = {
    "browser.privatebrowsing.autostart" = true;
    "browser.startup.homepage" = "about:blank";
    # https://www.eff.org/https-everywhere/set-https-default-your-browser
    "dom.security.https_only_mode" = true;
    "privacy.clearOnShutdown.cache" = true;
    "privacy.clearOnShutdown.cookies" = true;
    "privacy.clearOnShutdown.downloads" = true;
    "privacy.clearOnShutdown.formdata" = true;
    "privacy.clearOnShutdown.history" = true;
    "privacy.clearOnShutdown.offlineApps" = true;
    "privacy.clearOnShutdown.openWindows" = true;
    "privacy.clearOnShutdown.sessions" = true;
    "privacy.clearOnShutdown.siteSettings" = true;
    "signon.rememberSignons" = false;
  };
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.bitwarden
      pkgs.teams
      pkgs.zoom-us
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
    };
    programs.firefox = {
      enable = true;
      # https://nixos.org/manual/nixpkgs/stable/#build-wrapped-firefox-with-extensions-and-policies
      package = pkgs.custom_firefox;
      extensions = [
        firefox-addons.ublock-origin
        firefox-addons.bitwarden
        firefox-addons.darkreader
        firefox-addons.decentraleyes
        firefox-addons.disable-javascript
        firefox-addons.https-everywhere
        firefox-addons.privacy-badger
        firefox-addons.privacy-redirect
        firefox-addons.unpaywall
      ];
      profiles.default = {
        name = "default";
        settings = ffcommon_settings;
      };
      profiles.private = {
        id = 1;
        name = "private";
        settings = ffcommon_settings // ffprivate_settings;
      };
    };
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      mutableExtensionsDir = true;
      keybindings = if pkgs.stdenv.isDarwin then [
        { key = "shift+cmd+/"; command = "editor.action.goToImplementation"; when = "";}
      ] else [
        { key = "shift+ctrl+/"; command = "editor.action.goToImplementation"; when = "";}
      ];
      userSettings = {
        "workbench.settings.editor" = "json";
        "update.mode" = "none";
        "editor.rulers" = [ 72 80 100 120 140 160];
        "editor.tabSize" = 2;
        "explorer.confirmDelete" = false;
        "terminal.integrated.fontFamily" = "MesloLGS NF";
        "terminal.integrated.fontSize" = 12;
        "workbench.iconTheme" = "Monokai Pro (Filter Spectrum) Icons";
        "workbench.colorTheme" = "Monokai Pro (Filter Spectrum)";
        "search.followSymlinks" = false;
        "todohighlight.keywords" = [
            {
                "text" = "TODO:";
                "backgroundColor" = "teal";
                "color" = "black";
                "overviewRulerColor" = "teal";
            }
            {
                "text" = "NOTE:";
                "backgroundColor" = "purple";
                "color" = "white";
                "overviewRulerColor" = "purple";
            }
        ];
        "workbench.colorCustomizations" = {};
        "editor.tokenColorCustomizations" = {
            "comments" = "#278a06";
        };
        "search.searchOnType" = false;
        "diffEditor.ignoreTrimWhitespace" = false;
        "cmake.configureOnOpen" = true;
      };
      extensions = [
        pkgs.vscode-extensions.eamodio.gitlens
        pkgs.vscode-extensions.ms-azuretools.vscode-docker
        pkgs.vscode-extensions.ms-vscode-remote.remote-containers
        pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
        pkgs.vscode-extensions.ms-vscode-remote.remote-ssh-edit
        pkgs.vscode-extensions.ms-vscode-remote.vscode-remote-extensionpack
        pkgs.vscode-extensions.ms-vscode.cpptools
        pkgs.vscode-extensions.ms-vscode.cmake-tools
        pkgs.vscode-extensions.Tyriar.sort-lines
        pkgs.vscode-extensions.zxh404.vscode-proto3
        pkgs.vscode-extensions.twxs.cmake
        pkgs.vscode-extensions.wayou.vscode-todo-highlight
        pkgs.vscode-extensions.wmaurer.change-case
        pkgs.vscode-extensions.tomoki1207.pdf
        pkgs.vscode-extensions.mtxr.sqltools
        pkgs.vscode-extensions.monokai.theme-monokai-pro-vscode
        pkgs.vscode-extensions.mikestead.dotenv
        pkgs.vscode-extensions.mechatroner.rainbow-csv
        pkgs.vscode-extensions.bcanzanella.openmatchingfiles
        pkgs.vscode-extensions.jnoortheen.nix-ide
      ];
    };
  };
}