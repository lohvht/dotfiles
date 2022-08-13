{ config, lib, pkgs, ... }:
let
  # TODO: Rust installation not ready yet
  cfg = config.customHomeProfile.rust;

  shell_extracommon_str = ''
    ########## Module Rust Init Extra Start ##########
    if [[ -r ${config.home.homeDirectory}/.cargo/env ]]; then
        source "${config.home.homeDirectory}/.cargo/env"
    else
        echo "WARNING: Can't find cargo env for rustup"
    fi
    ########## Module Rust Init Extra End ##########
  '';
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.bash.initExtra = shell_extracommon_str;
      programs.zsh.initExtra = shell_extracommon_str;
    }
  ]);
}
