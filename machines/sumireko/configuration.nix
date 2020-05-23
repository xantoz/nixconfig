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

  home-manager.users.tewi_inaba = import ../../home/home.nazrin.nix;
  
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "sumireko";
}
