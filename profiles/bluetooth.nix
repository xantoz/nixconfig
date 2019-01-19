# currently hard-coded for graphical

{ config, pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  services.dbus.packages = [ pkgs.bluez pkgs.blueman ];

  # environment.systemPackages = with pkgs; [
  #   blueman
  # ];
}
