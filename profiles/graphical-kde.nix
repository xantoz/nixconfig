{ lib, config, pkgs, ... }:

{
  # base it on our graphical.nix, but we then do some tweaks
  imports = [
    ./graphical.nix
  ];

  # Override settings from profiles/graphical.nix, since we are going full ham KDE
  services.xserver.autorun = lib.mkForce true;
  services.xserver.displayManager.startx.enable = lib.mkForce false;
  services.physlock.enable = lib.mkForce false;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
}
