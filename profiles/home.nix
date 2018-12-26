{ config, pkgs, ... }:

{
  imports = [
    ../home-xantoz-nixpkgs/home-manager/nixos
  ];

  home-manager.users.tewi_inaba = import ../home-xantoz-nixpkgs/home.nix;
}
