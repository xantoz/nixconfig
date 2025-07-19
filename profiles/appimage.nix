{ config, pkgs, ... }:

{
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [
        pkgs.dotnet-runtime     # Needed for VRCX for one
        pkgs.icu                # Needed by VRCFaceTracking.Avalonia appimage
      ];
    };
  };
}
