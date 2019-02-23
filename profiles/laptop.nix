{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    powertop
  ];

  # run powertop --auto-tune on startup
  powerManagement.powertop.enable = true;
}
