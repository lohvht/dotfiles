{ pkgs, ... }:
pkgs.wrapFirefox pkgs.firefox-devedition-bin-unwrapped {
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
  };
  extraPrefs = ''
    // Show more ssl cert infos
    lockPref("security.identityblock.show_extended_validation", true);
  '';
}
