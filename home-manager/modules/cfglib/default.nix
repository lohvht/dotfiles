{ config, lib, pkgs, ... }:
let
  # Configuration library. You should import this to standardise config default values.

  isSystemCtlPathDefined = config.customHomeProfile.systemCtlPath != null;
  systemCtlPathInfo = {
    path = if !isSystemCtlPathDefined then "${pkgs.systemd}/bin/systemctl" else config.customHomeProfile.systemCtlPath;
    isDefined = isSystemCtlPathDefined;
  };

  mkSvcActiScHelper = { serviceFile, isUser ? false, preServiceInstall ? "", postServiceInstall ? "", preServiceUninstall ? "", postServiceUninstall ? "" }: {
    inherit serviceFile isUser preServiceInstall postServiceInstall preServiceUninstall postServiceUninstall;
  };
  serviceActivationScript = serviceFiles: builtins.concatStringsSep "\n"
    (builtins.map (
      s:
      let
        systemctlUserFlag = if s.isUser then " --user" else "";
        sudoPrefix = if s.isUser then "sudo " else "";
        systemdRelativePath = if s.isUser then "home-files/.config/systemd/user" else "home-path/lib/systemd/system";
        systemctlCMD = "XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/run/user/$(id -u)} ${sudoPrefix}${systemCtlPathInfo.path}${systemctlUserFlag}";
        installSection = ''
          echo "Run the following to install ${s.serviceFile}"
          echo "1. Pre-install:"
          cat << EOF
          ${s.preServiceInstall}
          EOF
          echo "2. Enable and start services:"
          echo "${systemctlCMD} enable $newServicePath/${s.serviceFile}"
          echo "${systemctlCMD} start ${s.serviceFile}"
          echo "3. Post-install:"
          cat << EOF
          ${s.postServiceInstall}
          EOF
          echo "Installation should be done afterwards"
        '';
        uninstallSection = ''
          echo "Run the following to uninstall ${s.serviceFile}"
          echo "1. Pre-uninstall:"
          cat << EOF
          ${s.preServiceUninstall}
          EOF
          echo "2. stop and disable services:"
          echo "${systemctlCMD} stop ${s.serviceFile}"
          echo "${systemctlCMD} disable ${s.serviceFile}"
          echo "3. Post-uninstall:"
          cat << EOF
          ${s.postServiceUninstall}
          EOF
          echo "Uninstallation should be done afterwards"
        '';

      in
      ''
        # Services to start and extra post startup to run
        oldServicePath=""
        newServicePath=""
        if [ -n "$oldGenPath" ] ; then
          oldServicePath="$oldGenPath/${systemdRelativePath}"
        fi
        newServicePath="$newGenPath/${systemdRelativePath}"

        echo "##### Printing out install/removal/update steps for ${s.serviceFile} #####"
        echo "##### Check if the ${s.serviceFile} is running #####"
        echo "${systemctlCMD} status ${s.serviceFile}"

        if ([ ! -n "$oldServicePath" ] || [ ! -f "$oldServicePath/${s.serviceFile}" ]) && [ ! -d "$newServicePath/${s.serviceFile}" ]; then
          echo "DEBUG: ${s.serviceFile} isnt installed previously or currently, skipping"
        elif ([ ! -n "$oldServicePath" ] || [ ! -f "$oldServicePath/${s.serviceFile}" ]) && [ -f "$newServicePath/${s.serviceFile}" ]; then
          ${installSection}
        elif [ ! -f "$oldServicePath/${s.serviceFile}" ] && [ -f "$newServicePath/${s.serviceFile}" ]; then
          ${uninstallSection}
        else
          DIFF="$(diff "$oldServicePath/${s.serviceFile}" "$newServicePath/${s.serviceFile}")"
          if [ $? -ne 0 ]; then
            echo "The service paths are different"
            echo "printing out the diffs: >"
            echo $DIFF
            unset DIFF

            echo "OLD path is '$oldServicePath/${s.serviceFile}', NEW path '$newServicePath/${s.serviceFile}'"
            echo "inspect the changes above, if changes are needed, run the following steps:"
            ${uninstallSection}
            ${installSection}
          else
            echo "no changes between the service paths, skipping"
          fi
        fi
        # unset to remove dangling variables
        unset systemdStatus oldServicePath newServicePath
      '';
    )
    serviceFiles);
in
{
  inherit systemCtlPathInfo;
  inherit mkSvcActiScHelper;
  inherit serviceActivationScript;
}
