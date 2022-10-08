{ config, lib, pkgs, ... }:
let
  shell_extracommon_str = ''
    ########## Module SSHAgent Init Extra Start ##########
    if [ -n "$ZSH_VERSION" ]; then
      emulate ksh -c ". ssh-find-agent.sh" # for zsh
    elif [ -n "$BASH_VERSION" ]; then
      . ssh-find-agent.sh # for bash
    else
      . ssh-find-agent.sh # for bash
    fi
    # Try to find an agent, if cannot find, then we run the eval command
    ssh_find_agent -a
    if [ -z "$SSH_AUTH_SOCK" ]
    then
      eval $(ssh-agent) > /dev/null
      ssh-add -l >/dev/null || alias ssh='ssh-add -l >/dev/null || ssh-add && unalias ssh; ssh'
    fi
    ########## Module SSHAgent Init Extra End ##########
  '';
in
{
  config = lib.mkMerge [
    {
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
      home.file.".local/bin/ssh-find-agent.sh" = {
        text = builtins.readFile ./ssh-find-agent.sh;
        executable = true;
      };
    }
  ];
}
