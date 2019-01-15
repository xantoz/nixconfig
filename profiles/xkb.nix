# Use when not using input-methods.nix

{ config, pkgs, ... }:

{
  services.xserver.layout = "us,se";
  services.xserver.xkbOptions = "ctrl:nocaps,grp:shifts_toggle";
}
