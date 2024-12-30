{ config, lib, pkgs, ... }@inputs:
let
  guilib = import ./lib.nix inputs;

  cfg = config.customHomeProfile.GUI;
  # https://nur.nix-community.org/repos/rycee/
  inherit (pkgs.nur.repos.rycee) firefox-addons;

  ffcommon_settings = {
    # Attempt to fix sporadic inability to load youtube videos
    # due to codec
    "media.mediasource.vp9.enabled" = false;
    "browser.tabs.inTitlebar" = 0;
    "gfx.webrender.all" = true;
    "media.ffmpeg.vaapi.enabled" = true;
    "media.hardware-video-decoding.force-enabled" = true;
    "media.rdd-ffmpeg.enabled" = true;
    "gfx.x11-egl.force-enabled" = true;
    "widget.dmabuf.force-enabled" = true;
    "app.normandy.api_url" = "";
    "app.normandy.enabled" = false;
    "app.shield.optoutstudies.enabled" = false;
    "apz.overscroll.enabled" = true; # DEFAULT NON-LINUX
    "beacon.enabled" = false;
    "breakpad.reportURL" = "";
    "browser.cache.disk.enable" = false;
    "browser.cache.jsbc_compression_level" = 5;
    "browser.cache.memory.capacity" = 256000; # default= -1 (32768)
    "browser.cache.memory.max_entry_size" = 10240; # default=5120 (5 MB)
    "browser.contentblocking.category" = "strict";
    "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
    "browser.download.open_pdf_attachments_inline" = true;
    "browser.download.start_downloads_in_tmp_dir" = true;
    "browser.helperApps.deleteTempFileOnExit" = true;
    "browser.newtab.preload" = false;
    "browser.newtabpage.activity-stream.default.sites" = "";
    "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.feeds.snippets" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.newtabpage.enabled" = false;
    "browser.ping-centre.telemetry" = false;
    "browser.privatebrowsing.forceMediaMemoryCache" = true;
    "browser.sessionstore.interval" = 120000;
    "browser.tabs.crashReporting.sendReport" = false;
    "browser.tabs.warnOnClose" = false;
    "browser.xul.error_pages.expert_bad_cert" = true;
    "content.notify.interval" = 100000;
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "dom.disable_open_during_load" = true;
    "dom.enable_web_task_scheduling" = true;
    "dom.event.clipboardevents.enabled" = false;
    "dom.event.contextmenu.enabled" = false;
    "dom.popup_allowed_events" = "click dblclick mousedown pointerdown";
    "dom.security.https_first" = true;
    "dom.security.https_only_mode_error_page_user_suggestions" = true;
    "dom.security.https_only_mode_send_http_background_request" = false;
    "dom.security.https_only_mode" = true; # https://www.eff.org/https-everywhere/set-https-default-your-browser
    "dom.security.sanitizer.enabled" = true;
    "extensions.pocket.enabled" = false;
    "extensions.postDownloadThirdPartyPrompt" = false;
    "general.autoScroll" = true;
    "general.smoothScroll.currentVelocityWeighting" = 1.0;
    "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
    "general.smoothScroll.msdPhysics.enabled" = true;
    "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 600;
    "general.smoothScroll.msdPhysics.regularSpringConstant" = 650;
    "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
    "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = 2.0;
    "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
    "general.smoothScroll.stopDecelerationWeighting" = 1.0;
    "general.smoothScroll" = true; # DEFAULT
    "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
    "gfx.canvas.accelerated.cache-items" = 32768;
    "gfx.canvas.accelerated.cache-size" = 4096;
    "gfx.content.skia-font-cache-size" = 80;
    "image.mem.decode_bytes_at_a_time" = 65536;
    "layout.css.grid-template-masonry-value.enabled" = true;
    "layout.css.has-selector.enabled" = true;
    "media.autoplay.default" = 5;
    "media.cache_readahead_limit" = 7200;
    "media.cache_resume_threshold" = 3600;
    "media.memory_cache_max_size" = 131072; # default=8192; AF=65536
    "media.memory_caches_combined_limit_kb" = 1048576; # default=524288
    "media.memory_caches_combined_limit_pc_sysmem" = 10; # default=5
    "media.peerconnection.ice.default_address_only" = true;
    "media.peerconnection.ice.no_host" = true;
    "media.peerconnection.ice.proxy_only_if_behind_proxy" = true;
    "mousewheel.default.delta_multiplier_y" = 300; # 250-400; adjust this number to your liking
    "network.buffer.cache.count" = 128;
    "network.buffer.cache.size" = 262144;
    "network.captive-portal-service.enabled" = false;
    "network.connectivity-service.enabled" = false;
    "network.dns.disablePrefetch" = true;
    "network.dns.max_high_priority_threads" = 8;
    "network.dnsCacheExpiration" = 3600;
    "network.http.max-connections" = 1800;
    "network.http.max-persistent-connections-per-server" = 10;
    "network.http.max-urgent-start-excessive-connections-per-host" = 5;
    "network.http.pacing.requests.enabled" = false;
    "network.http.referer.XOriginPolicy" = 2;
    "network.http.referer.XOriginTrimmingPolicy" = 2;
    # NOTE: network.http.sendRefererHeader
    #   controls whether or not to send a referrer regardless of origin
    #     0 = never send the header
    #     1 = send the header only when clicking on links and similar elements
    #     2 = (default) send on all requests (e.g. images, links, etc.)
    # Setting this to 1 / 0 can break some websites, stay at 2 for now
    "network.http.sendRefererHeader" = 2;
    "network.predictor.enabled" = false;
    "network.prefetch-next" = false;
    "network.ssl_tokens_cache_capacity" = 10240;
    "pdfjs.enableScripting" = false;
    "permissions.default.desktop-notification" = 2;
    "permissions.default.geo" = 2;
    "permissions.manager.defaultsUrl" = "";
    "privacy.donottrackheader.enabled" = true;
    "privacy.firstparty.isolate" = true; # First party isolation (also called "double keying") can prevent third parties from tracking users across multiple sites.
    "privacy.globalprivacycontrol.enabled" = true;
    "privacy.globalprivacycontrol.functionality.enabled" = true;
    "privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage" = true;
    "privacy.partition.always_partition_third_party_non_cookie_storage" = true;
    "privacy.partition.network_state.ocsp_cache" = true;
    "privacy.partition.serviceWorkers" = true;
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;
    "privacy.userContext.enabled" = true;
    "security.cert_pinning.enforcement_level" = 2;
    "security.enterprise_roots.enabled" = true;
    "security.mixed_content.block_display_content" = true;
    "security.mixed_content.upgrade_display_content.image" = true;
    "security.mixed_content.upgrade_display_content" = true;
    "security.OCSP.enabled" = 0;
    "security.pki.crlite_mode" = 2;
    "security.pki.sha1_enforcement_level" = 1;
    "security.remote_settings.crlite_filters.enabled" = true;
    "security.ssl.treat_unsafe_negotiation_as_broken" = true;
    # NOTE: lohvht@30dec2024: attempted bunch of fixes to try to fix google services
    # slowness in FF > 128, including youtube.
    # Taken from: https://old.reddit.com/r/firefox/comments/1em9uuh/firefox_128_issues_with_google_services/
    # "network.http.http3.enable" = false;
    "network.http.http3.enable_0rtt" = false;
    "security.tls.enable_0rtt_data" = false;
    "signon.rememberSignons" = false;
    "toolkit.coverage.endpoint.base" = "";
    "toolkit.coverage.opt-out" = true;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.coverage.opt-out" = true;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.server" = "data:,";
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "webchannel.allowObject.urlWhitelist" = "";
    "webgl.force-enabled" = true;
    "widget.use-xdg-desktop-portal.file-picker" = true;
    # "webgl.force-enable" = true; # This could be wrong, doublecheck
  };
  ffprivate_settings = {
    "browser.download.manager.addToRecentDocs" = false;
    "browser.download.useDownloadDir" = false;
    "browser.privatebrowsing.autostart" = true;
    "browser.startup.homepage" = "about:blank";
    "media.peerconnection.enabled" = false;
    "privacy.clearOnShutdown.cache" = true;
    "privacy.clearOnShutdown.cookies" = true;
    "privacy.clearOnShutdown.downloads" = true;
    "privacy.clearOnShutdown.formdata" = true;
    "privacy.clearOnShutdown.history" = true;
    "privacy.clearOnShutdown.offlineApps" = true;
    "privacy.clearOnShutdown.openWindows" = true;
    "privacy.clearOnShutdown.sessions" = true;
    "privacy.clearOnShutdown.siteSettings" = true;
  };
  # For the default profile, we will do dynamic native tabs for sidebery, as highlighted here
  # https://github.com/mbnuqw/sidebery/wiki/Firefox-Styles-Snippets-(via-userChrome.css)#completely-hide-native-tabs-strip
  # Extra sidebery styles we apply here too, usually taken here:
  # https://github.com/mbnuqw/sidebery/wiki/Sidebery-Styles-Snippets
  firefox_userchrome = builtins.readFile ./firefox-userchrome.css;

  wrapped_firefox_pkg = (pkgs.wrapFirefox pkgs.firefox-unwrapped {
    extraPolicies = {
      # Policies here: https://github.com/mozilla/policy-templates
      Certificates = {
        ImportEnterpriseRoots = true;
      };
      ImportEnterpriseRoots = true;
      AppAutoUpdate = false;
      HardwareAcceleration = true;
      DisableAppUpdate = true;
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
  }).override {
    nativeMessagingHosts = [
      pkgs.fx-cast-bridge # Enable chromecast for firefox
      pkgs.plasma5Packages.plasma-browser-integration # enable KDE plasma integration
    ];
  };
  # NOTE: We have to do this and use a separate bin firefox-nixGL instead of just using firefox via `guilib.nixGLWrap`
  #       The home-manager program.firefox.package doesnt accept anything else as it needs the `override` attribute key
  #       which the wrapper doesnt have.
  custom_firefox_pkg = guilib.nixGLWrapOpts wrapped_firefox_pkg { binSuffix = "-nixGL"; };

  extensions = [
    firefox-addons.ublock-origin # adblocker
    firefox-addons.decentraleyes # Protects you against tracking through "free", centralised, content delivery
    firefox-addons.unpaywall # attempt to unpaywall research articles
    firefox-addons.sponsorblock # block sponsor sections of YT videos
    firefox-addons.skip-redirect # attempt to skip multiple redirects by redirecting to final destination directly
    firefox-addons.sidebery # tab mgmt
    firefox-addons.plasma-integration # KDE plasma integration
    # firefox-addons.bypass-paywalls-clean
    firefox-addons.old-reddit-redirect
    firefox-addons.canvasblocker
    firefox-addons.user-agent-string-switcher
  ];
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      home.file = {
        # NOTE: Do remember to do the sidebery import
        ".local/firefox-custom/sidebery-export.json".text = builtins.readFile ./firefox-sidebery-export.json;
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
      home.sessionVariables = {
        MOZ_USE_XINPUT2 = "1"; # Make Firefox use xinput2, improving touchscreen support, enable touchpad gestures and enables smoothscrolling
        MOZ_ENABLE_WAYLAND = "1";
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
        profiles.default = {
          name = "Default";
          settings = ffcommon_settings;
          isDefault = true;
          extensions = extensions;
          userChrome = firefox_userchrome;
        };
        profiles.private = {
          id = 1;
          name = "Private";
          settings = ffcommon_settings // ffprivate_settings;
          extensions = extensions;
          userChrome = firefox_userchrome;
        };
      };
    }
  ]);
}
