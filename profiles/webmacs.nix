{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    webmacs
  ];

  # This is old, outdated and insecure... unfortunately...
  # But webmacs depends on it.
  # I really liked webmacs back in the day...
  # I wonder if it'd port to qt6...
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];
}
