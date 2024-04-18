{ config, lib, pkgs, ... }:
{
  imports = [
    ./mariadb
    ./postgres
  ];
}
