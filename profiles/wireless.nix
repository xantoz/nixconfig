{ config, pkgs, ... }:

{
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.userControlled.enable = true;

  environment.systemPackages = with pkgs; [
    wpa_supplicant_gui
  ];

  security.sudo.extraRules = [
    { commands = [ { command = "${pkgs.rfkill}/bin/rfkill"; options = [ "SETENV" "NOPASSWD" ]; } ]; groups = [ "wheel" ]; }
  ];
}