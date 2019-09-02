{
  stdenv, fetchFromGitHub, writeShellScriptBin, pkgconfig,
  xorg,
  gtkmm3,
  glib,
  dbus-glib,
  boost,
  intltool,
  gettext,
  bash
}:

stdenv.mkDerivation rec {
  name = "easystroke-${version}";
  version = "0.6.0_p20160705";

  src = fetchFromGitHub {
    owner = "thjaeger";
    repo = "easystroke";
    rev = "f7c1614004e9c518bd4f6f4b3a2ddaf23911a5ef";
    sha256 = "0map8zbnq993gchgw97blf085cbslry2sa3z4ambdcwbl0r9rd6x";
  };

  nativeBuildInputs =
    let
      fakegit = writeShellScriptBin "git" ''
        echo "${version}"
      '';
    in [
      fakegit
      pkgconfig
      intltool
      gettext
    ];

  buildInputs = [
    boost
    glib
    dbus-glib
    gtkmm3
    xorg.xorgserver
    xorg.libX11
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXtst
  ];

  patches = [
    ./easystroke-0.6.0-abs.patch
    ./easystroke-0.6.0-cellrendertextish.patch
    ./easystroke-0.6.0-cxx11.patch
    ./easystroke-0.6.0-desktop.patch
    # ./easystroke-0.6.0-gentoo.patch
  ];

  makeFlags = [ "DESTDIR=$(out) PREFIX=" ];

  meta = with stdenv.lib; {
    description = "A gesture-recognition application for X11";
    homepage =  https://github.com/thjaeger/easystroke;
    license = licenses.isc;
    platforms = platforms.linux;
  };
}
