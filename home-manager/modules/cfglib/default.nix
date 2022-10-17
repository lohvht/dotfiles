{ config, lib, pkgs, ... }:
let
  # Configuration library. You should import this to standardise config default values.

  isSystemCtlPathDefined = config.customHomeProfile.systemCtlPath != null;
  systemCtlPathInfo = {
    path = if !isSystemCtlPathDefined then "${pkgs.systemd}/bin/systemctl" else config.customHomeProfile.systemCtlPath;
    isDefined = isSystemCtlPathDefined;
  };

  mkSvcActiScHelper =
    { serviceFile
    , isUser ? false
    , systemFileInEtc ? true
    , preServiceInstall ? ""
    , postServiceInstall ? ""
    , preServiceUninstall ? ""
    , postServiceUninstall ? ""
    }: {
      inherit serviceFile isUser systemFileInEtc preServiceInstall postServiceInstall preServiceUninstall postServiceUninstall;
    };
  # serviceActivationScript is the generic script to run if we want to enable systemd services via home manager's activation script
  # Take note that for each service, if any script such as preServiceInstall,postServiceInstall etc etc are to be run that will
  # change the system, the onus is on the user of the code to handle the $DRY_RUN_CMD case
  serviceActivationScript = serviceFiles: builtins.concatStringsSep "\n"
    (builtins.map
      (
        s:
        let
          systemctlUserFlag = if s.isUser then " --user" else "";
          sudoPrefix = if s.isUser then "" else "sudo ";
          systemdRelativePath =
            if s.isUser then
              "home-files/.config/systemd/user"
            else if s.systemFileInEtc then
              "home-path/etc/systemd/system"
            else
              "home-path/lib/systemd/system";
          systemctlCMD = "XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/run/user/$(id -u)} $DRY_RUN_CMD ${sudoPrefix}${systemCtlPathInfo.path}${systemctlUserFlag}";
          installSection = ''
            echo "Installing ${s.serviceFile}"
            echo "1. Pre-install:"
            ${s.preServiceInstall}
            echo "2. Enable and start services:"
            ${systemctlCMD} enable $newServiceFile || true
            ${systemctlCMD} start ${s.serviceFile} || true
            echo "3. Post-install:"
            ${s.postServiceInstall}
            echo "Installation should be done now"
          '';
          uninstallSection = ''
            echo "Uninstalling ${s.serviceFile}"
            echo "1. Pre-uninstall:"
            ${s.preServiceUninstall}
            echo "2. stop and disable services:"
            ${systemctlCMD} stop ${s.serviceFile} || true
            ${systemctlCMD} disable ${s.serviceFile} || true
            echo "3. Post-uninstall:"
            ${s.postServiceUninstall}
            echo "Uninstallation should be done now"
          '';
        in
        ''
          # Services to start and extra post startup to run
          oldServicePath=""
          if [ -n "$oldGenPath" ] ; then
            oldServicePath="$oldGenPath/${systemdRelativePath}"
          fi
          oldServiceFile="$oldServicePath/${s.serviceFile}"
          newServiceFile="$newGenPath/${systemdRelativePath}/${s.serviceFile}"

          if ([ ! -n "$oldServicePath" ] || [ ! -f "$oldServiceFile" ]) && [ ! -f "$newServiceFile" ]; then
            echo "${s.serviceFile} isnt installed previously or currently, skipping"
          elif ([ ! -n "$oldServicePath" ] || [ ! -f "$oldServiceFile" ]) && [ -f "$newServiceFile" ]; then
            ${installSection}
          elif [ -f "$oldServiceFile" ] && [ ! -f "$newServiceFile" ]; then
            ${uninstallSection}
          else
            DIFF="$(diff "$oldServiceFile" "$newServiceFile")"
            if [ $? -ne 0 ]; then
              echo "The service paths are different"
              echo "printing out the diffs: >"
              echo $DIFF
              unset DIFF
              echo "Reinstalling the services"
              ${uninstallSection}
              ${installSection}
            else
              echo "no changes between the service paths, skipping"
            fi
          fi
          # unset to remove dangling variables
          unset oldServicePath oldServiceFile newServiceFile
        ''
      )
      serviceFiles);
in
{
  inherit systemCtlPathInfo;
  inherit mkSvcActiScHelper;
  inherit serviceActivationScript;
}
