{ stdenv, lib, fetchFromGitHub, python39Packages,
  gobject-introspection, gtk3, gdk-pixbuf,
  wrapGAppsHook
}:

python39Packages.buildPythonApplication rec {
    name = "mcomix-lite-${version}";
    version = "v3.3.0";

    src = fetchFromGitHub {
      owner = "thermitegod";
      repo = "mcomix-ilte";
      rev = "${version}";
      sha256 = "9oydg0Vei8O6eogwn/+qezsXMLqvNhGu8ARpJPoCB2w=";
      fetchSubmodules = true;
    };

    buildInputs = [ gobject-introspection gtk3 gdk-pixbuf ];

    nativeBuildInputs = [ wrapGAppsHook ];

    propagatedBuildInputs = with python39Packages; [
      libarchive-c
      urllib3
      pillow
      xxhash
      loguru
      pyyaml
      pygobject3
      pycairo
      send2trash
    ];

    # Correct wrapper behavior, see https://github.com/NixOS/nixpkgs/issues/56943
    # until https://github.com/NixOS/nixpkgs/pull/102613
    strictDeps = false;


    # TODO: error in check phase
    doCheck = false;

    meta = {
      description = "A fork of mcomix, a GTK3 image viewer for comic book archives";

      longDescription = ''
        MComix-Lite is a manga/comic reader written in Python3 / Gtk+3

        MComix-Lite is a fork of MComix3 which is a fork of MComix
        which is a fork of Comix.

        The main focus is ONLY on the reader and all other features,
        i.e. library, have been removed or could be subject to a
        future removal.
      '';
      homepage = https://github.com/thermitegod/mcomix-lite;
      license = lib.licenses.gpl2;
    };
}
