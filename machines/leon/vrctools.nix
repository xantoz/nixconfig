{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    blender
    alcom vrc-get
    unityhub
    vrcx
  ];
}
