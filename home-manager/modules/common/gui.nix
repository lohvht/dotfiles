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
    "general.autoScroll" = true;
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

  custom_firefox_pkg = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    extraPolicies = {
      # Policies here: https://github.com/mozilla/policy-templates
      AppAutoUpdate = false;
      DisableAppUpdate = true;
      DisableBuiltinPDFViewer = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableDeveloperTools = false;
      DisableFeedbackCommands = true;
      DisableSystemAddonUpdate = true;
      DisableFormHistory = true;
      NewTabPage = false;
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = true;
      NetworkPrediction = false; # disable dns prefetch
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      SearchSuggestEnabled = false;
      FirefoxHome = {
        Search = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
        TopSites = false;
        SponsoredTopSites = false;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        SkipOnboarding = true;
      };
      Homepage = {
        StartPage = "previous-session";
      };
    };
    extraPrefs = ''
      // Show more ssl cert infos
      lockPref("security.identityblock.show_extended_validation", true);
    '';
  };

  # NOTE: *that* an-anime-game-launcher specific, assume that installation is done in linux via the
  # appropriate channels (not going to link here, but lookup 'n-anime-game-launcher')
  # The defaults here are usually the same and its *USUALLY* safe to go ahead and delete to reinstall
  # These settings if we somehow bork the relevant configuration
  agl_root = "${config.home.homeDirectory}/.local/share/anime-game-launcher";
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (pkgs.stdenv.isLinux && cfg.gaming.enable) {
      home.shellAliases = {
        genshin_start = ''WINEPREFIX='${agl_root}/game' ${agl_root}/runners/lutris-GE-Proton7-22-x86_64/bin/wine64 ${agl_root}/game/drive_c/Program\ Files/Genshin\ Impact/GenshinImpact.exe'';
      };
    })
    (lib.mkIf pkgs.stdenv.isLinux {
      home.file = {
        ".local/share/applications/firefox.desktop" = {
          text = ''
            [Desktop Entry]
            Categories=Network;WebBrowser
            Exec=nixGL firefox -P Default %U
            GenericName=Web Browser
            Icon=${custom_firefox_pkg}/share/icons/hicolor/128x128/apps/firefox.png
            MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp
            Name=Firefox
            Type=Application
            Version=1.4
            Terminal=False
            Actions=private_window;

            [Desktop Action private_window]
            Name=Open a Private Window
            Icon=${custom_firefox_pkg}/share/icons/hicolor/128x128/apps/firefox.png
            Exec=nixGL firefox -P Private %U
          '';
          executable = true;
        };
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
        ".local/share/applications/Codium.desktop" = {
          text = ''
            [Desktop Entry]
            Actions=new-empty-window
            Categories=Utility;TextEditor;Development;IDE
            Comment=Code Editing. Redefined.
            Exec=codium %F
            GenericName=Text Editor
            Icon=${pkgs.vscodium}/share/pixmaps/code.png
            Keywords=vscode
            MimeType=text/plain;inode/directory
            Name=VSCodium
            StartupNotify=true
            StartupWMClass=vscodium
            Type=Application
            Version=1.4

            [Desktop Action new-empty-window]
            Exec=codium --new-window %F
            Icon=${pkgs.vscodium}/share/pixmaps/code.png
            Name=New Empty Window
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
      ];
      home.file = {
        ".local/bin/update_installed_exts.sh".source = pkgs.fetchFromGitHub
          {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "8f868e154ca265e38481ab15d28429f7ff72e0e4";
            sha256 = "0qma806bpd99glhjl3zwdkaydi44nrhjg51n6n4siqkfq0kk96v7";
          } + "/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh";
      };
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
      programs.firefox = {
        enable = true;
        # https://nixos.org/manual/nixpkgs/stable/#build-wrapped-firefox-with-extensions-and-policies
        package = custom_firefox_pkg;
        extensions = [
          firefox-addons.ublock-origin
          firefox-addons.bitwarden
          firefox-addons.darkreader
          firefox-addons.decentraleyes
          firefox-addons.disable-javascript
          firefox-addons.https-everywhere
          firefox-addons.privacy-badger
          firefox-addons.unpaywall
        ];
        profiles.default = {
          name = "Default";
          settings = ffcommon_settings;
          isDefault = true;
        };
        profiles.private = {
          id = 1;
          name = "Private";
          settings = ffcommon_settings // ffprivate_settings;
        };
      };
      home.shellAliases = {
        code = "codium";
      };
      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;
        mutableExtensionsDir = true;
        keybindings = [
          { key = "ctrl+alt+up"; command = "editor.action.insertCursorAbove"; when = "editorTextFocus"; }
          { key = "ctrl+alt+down"; command = "editor.action.insertCursorBelow"; when = "editorTextFocus"; }
        ] ++ (if pkgs.stdenv.isDarwin then [
          { key = "shift+cmd+/"; command = "editor.action.goToImplementation"; when = ""; }
        ] else [
          { key = "shift+ctrl+/"; command = "editor.action.goToImplementation"; when = ""; }
        ]);
        userSettings = {
          "workbench.settings.editor" = "json";
          "update.mode" = "none";
          "editor.rulers" = [ 72 80 100 120 140 160 ];
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
          "workbench.colorCustomizations" = { };
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
          pkgs.vscode-extensions.ms-vscode.cpptools
          pkgs.vscode-extensions.tyriar.sort-lines
          pkgs.vscode-extensions.zxh404.vscode-proto3
          pkgs.vscode-extensions.tomoki1207.pdf
          pkgs.vscode-extensions.mikestead.dotenv
          pkgs.vscode-extensions.mechatroner.rainbow-csv
          pkgs.vscode-extensions.jnoortheen.nix-ide
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            publisher = "jgclark";
            name = "vscode-todo-highlight";
            version = "2.0.4";
            sha256 = "18zm1w4ziq3i7fn2rcd095va7nqnbdmsvr82lj27s33zrd2wwzzr";
          }
          {
            name = "change-case";
            publisher = "wmaurer";
            version = "1.0.0";
            sha256 = "0dxsdahyivx1ghxs6l9b93filfm8vl5q2sa4g21fiklgdnaf7pxl";
          }
          {
            name = "cmake-tools";
            publisher = "ms-vscode";
            version = "1.12.22";
            sha256 = "1jampq21wly9hrawzfmmn1829jk31h6kl37svv2xc3cz34jk914y";
          }
          {
            name = "cmake";
            publisher = "twxs";
            version = "0.0.17";
            sha256 = "11hzjd0gxkq37689rrr2aszxng5l9fwpgs9nnglq3zhfa1msyn08";
          }
          {
            publisher = "monokai";
            name = "theme-monokai-pro-vscode";
            version = "1.1.20";
            sha256 = "0ddwqsvsqdjblmb0xlad17czy2837g27ymwvzissz4b9r111xyhx";
          }
          {
            publisher = "bcanzanella";
            name = "openmatchingfiles";
            version = "0.5.2";
            sha256 = "0wpv77jir5k77ml0x1y21gk4kxk53vnkxrqg4v35clhdhszzh6fq";
          }
        ];
      };
    }
  ]);
}
