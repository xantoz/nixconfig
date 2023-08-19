{ config, pkgs, ... }:

{
  # Printing settings
  services.avahi.enable = true;
  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplipWithPlugin ];
  };
  # services.ipp-usb.enable = true;

  # scan
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ hplipWithPlugin ];
  };
}
