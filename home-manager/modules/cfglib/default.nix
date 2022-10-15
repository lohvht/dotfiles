{ config, lib, pkgs, ... }:
let
  # Configuration library. You should import this to standardise config default values.

  isSystemCtlPathDefined = config.customHomeProfile.systemCtlPath != null;
  systemCtlPathInfo = {
    path = if !isSystemCtlPathDefined then "${pkgs.systemd}/bin/systemctl" else config.customHomeProfile.systemCtlPath;
    isDefined = isSystemCtlPathDefined;
  };
in
{
  inherit systemCtlPathInfo;
}
