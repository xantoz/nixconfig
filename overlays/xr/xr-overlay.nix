{ config, lib, pkgs, ... }:

# This is a hacked-together way for me to have stuff selectively from the nixpkgs-xr overlay included as a submodule.
# This should also avoid having to go through flake-compat, which has troubles with submodules
#
# It also makes it be based on the same nixpkgs as everything else rather than what the flake says. For better and worse.
# If it ever becomes a problem I suppose I can figure out a way to hack it together differently.

# To use this put this file into imports.

let
  overlayFn = lib.composeManyExtensions [
    (self: super: {
      xrSources = self.callPackage ./pkgs/nixpkgs-xr/_sources/generated.nix { };
    })

    # Import all the new packages from the nixpkgs-xr overlay
    (import ../../nixpkgs/pkgs/top-level/by-name-overlay.nix ./pkgs/nixpkgs-xr/pkgs/by-name)

    # # Overridden packages
    # (import ./pkgs/nixpkgs-xr/pkgs/overrides/envision-unwrapped.nix)
    # (import ./pkgs/nixpkgs-xr/pkgs/overrides/monado.nix)
    # (import ./pkgs/nixpkgs-xr/pkgs/overrides/opencomposite.nix)
    # (import ./pkgs/nixpkgs-xr/pkgs/overrides/opencomposite-vendored.nix)
    # (import ./pkgs/nixpkgs-xr/pkgs/overrides/wlx-overlay-s.nix)
    (import ./pkgs/nixpkgs-xr/pkgs/overrides/wivrn.nix)
    # (import ./pkgs/nixpkgs-xr/pkgs/overrides/xrizer.nix)
  ];
in
{

  # TODO: We'd like to find a way to include this overlay in NIX_PATH as well (like we do for the local overlay)
  #       However, since we use lib.composeManyExtensions that becomes tricky.
  #
  #       Perhaps the "stupid" way of just making making a default.nix like the one I have in the local overlay calling
  #       into each of the additional packages by hand is the way to go?
  #
  #       Alternatively we could perhaps even just merge this overlay thingy with that one. Might particularly be useful since
  #       I have an xrizer override in there too.
  nixpkgs.overlays = [
    overlayFn
  ];
}
