{ config, lib, pkgs, ... }@inputs:
let
  guilib = import ./lib.nix inputs;

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
    "webgl.force-enable" = true;
    "security.enterprise_roots.enabled" = true;
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

  wrapped_firefox_pkg = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    extraPolicies = {
      # Policies here: https://github.com/mozilla/policy-templates
      Certificates = {
        ImportEnterpriseRoots = true;
      };
      ImportEnterpriseRoots = true;
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
  # NOTE: We have to do this and use a separate bin firefox-nixGL instead of just using firefox via `guilib.nixGLWrap`
  #       The home-manager program.firefox.package doesnt accept anything else as it needs the `override` attribute key
  #       which the wrapper doesnt have.
  custom_firefox_pkg = guilib.nixGLWrapOpts wrapped_firefox_pkg { binSuffix = "-nixGL"; };
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      home.file = {
        ".local/share/applications/firefox.desktop" = {
          text = ''
            [Desktop Entry]
            Categories=Network;WebBrowser
            Exec=firefox-nixGL -P Default %U
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
            Exec=firefox-nixGL -P Private %U
          '';
          executable = true;
        };
      };
    })
    {
      home.packages = [
        custom_firefox_pkg
      ];
      programs.firefox = {
        enable = true;
        # https://nixos.org/manual/nixpkgs/stable/#build-wrapped-firefox-with-extensions-and-policies
        package = wrapped_firefox_pkg;
        extensions = [
          firefox-addons.ublock-origin # adblocker
          firefox-addons.bitwarden # bitwarden password manager
          firefox-addons.darkreader
          firefox-addons.decentraleyes # Protects you against tracking through "free", centralised, content delivery
          firefox-addons.disable-javascript
          firefox-addons.privacy-badger # stops advertisers/3rd party trackers from tracking
          firefox-addons.unpaywall # attempt to unpaywall research articles
          firefox-addons.sponsorblock # block sponsor sections of YT videos
          firefox-addons.sourcegraph # View gitlab/other code repo source code for 20+ languages
          firefox-addons.skip-redirect # attempt to skip multiple redirects by redirecting to final destination directly
          firefox-addons.sidebery # tab mgmt
          firefox-addons.plasma-integration # KDE plasma integration
          firefox-addons.don-t-fuck-with-paste # Restore Copy/Paste for websites that mess around with those
          firefox-addons.display-_anchors # Display invisible anchor link
          firefox-addons.clearurls # attempt to remove tracking elements when clicking URLs
          firefox-addons.bypass-paywalls-clean # attempts to unpaywall paywalled articles
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
    }
  ]);
}
