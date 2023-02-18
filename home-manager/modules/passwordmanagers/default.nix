{ config, lib, pkgs, ... }:
{
  imports = [
    ./1password
    ./bitwarden
  ];
}
