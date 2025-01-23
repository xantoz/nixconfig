{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    waypipe
    bemenu

    # Usable minimal wayland-native terminals
    foot
    #stupidterm
  ];
}
