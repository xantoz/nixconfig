{ pkgs, ... }:

let
  xsaneGimp = pkgs.xsane.override { gimpSupport = true; };
in
{
    home.file = {
      ".config/GIMP/2.10/plug-ins/xsane".source = "${xsaneGimp}/bin/xsane";
    };
}
