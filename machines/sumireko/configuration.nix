{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../profiles/core.nix
    ../../profiles/graphical.nix
    ../../profiles/input-methods.nix
    ../../profiles/wireless.nix
    ../../profiles/bluetooth.nix
    ../../profiles/laptop.nix
    ../../profiles/sway.nix
    ../../home/home-manager/nixos
  ];

  home-manager.users.tewi_inaba = import ../../home/home.sumireko.nix;

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "sumireko";

  services.xserver.videoDrivers = [ "modesetting" ];

  environment.systemPackages = with pkgs; [
    ardour

    # try getting the icons of the home manager services to work this way??
    pasystray
    blueman

    # stupidterm for use in sway as a wayland-native terminal
    stupidterm
  ];
}
