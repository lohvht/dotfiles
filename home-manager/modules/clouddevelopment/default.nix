{ config, lib, pkgs, ... }:
{
  imports = [
    ./docker
    ./k8s
    ./terraform
  ];
}
