{ config, lib, pkgs, ... }:
{
  imports = [
    ./handbrake
    ./makemkv
    ./mkvtoolnix
  ];
}
