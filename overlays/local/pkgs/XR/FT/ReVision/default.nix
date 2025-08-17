{ pkgs ? import <nixpkgs> {} }:

let
  src = pkgs.fetchFromGitHub {
    owner = "Blue-Doggo";
    repo = "ReVision";
    rev = "master";
    hash = "sha256-+SYHhVRdzB645G0NWtsqZ34DViK5AhY9pJiZmV7BZ1s=";
  };
in
{
  ReVision = pkgs.callPackage ./package.nix { src = src; };

  # ReVision_App = pkgs.callPackage ./package-app.nix { src = src; };
  # ReVision_Core = pkgs.callPackage ./package-core.nix { src = src; };
  # ReVision_EyeDevice = pkgs.callPackage ./package-eyedevice.nix { src = src; };
  # ReVision_MJPEG = pkgs.callPackage ./package-MJPEG.nix { src = src; };
  # ReVision_Vive = pkgs.callPackage ./package-vive.nix { src = src; };

  ReVision_App       = pkgs.callPackage ./package-generic.nix { src = src; name = "App"; };
  ReVision_Core      = pkgs.callPackage ./package-generic.nix { src = src; name = "Core"; };
  # ReVision_EyeDevice = pkgs.callPackage ./package-generic.nix { src = src; name = "EyeDevice"; };
  ReVision_EyeDevice = pkgs.callPackage ./package-eyedevice.nix { src = src; };
  ReVision_MJPEG     = pkgs.callPackage ./package-generic.nix { src = src; name = "MJPEG"; };
  ReVision_Vive      = pkgs.callPackage ./package-generic.nix { src = src; name = "Vive"; };
}
