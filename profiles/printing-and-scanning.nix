{ config, pkgs, ... }:

{
  # Printing settings
  services.avahi.enable = true;
  services.printing = {
    enable = true;
    browsed.enable = false;     # I don't trust this one
    drivers = with pkgs; [
      hplipWithPlugin
      postscript-lexmark
    ];
  };
  services.ipp-usb.enable = true;

  # scan
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      hplipWithPlugin
      epkowa
      # epsonscan2
      # pixma
    ];
  };
}
