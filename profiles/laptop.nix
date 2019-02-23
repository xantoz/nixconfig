{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    powertop
  ];

  # run powertop --auto-tune on startup
  powerManagement.powertop.enable = true;

  # enable upower (mainly to get autohibernate on low battery)
  services.upower.enable = true;
}
