# currently hard-coded for graphical

{ config, pkgs, ... }:

{
  services.dbus.packages = [ pkgs.blueman ];

  # environment.systemPackages = with pkgs; [
  #   blueman
  # ];
}
