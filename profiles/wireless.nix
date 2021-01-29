{ config, pkgs, ... }:

{
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.userControlled.enable = false;

  environment.systemPackages = with pkgs; [
    wpa_supplicant_gui
  ];

  security.doas.extraRules = [
    { groups = [ "wheel" ]; noPass = true; cmd = "${pkgs.utillinux}/bin/rfkill"; }
  ];
}
