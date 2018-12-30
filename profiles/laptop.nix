{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
  let
    my_xbattbar = haskellPackages.xbattbar.overrideAttrs(old: { patches = [ ../patches/xbattbar-0.2.patch ]; } );
  in [
    powertop
    my_xbattbar
  ];
}
