{ stdenv,
  fetchgit,
  python3Packages,
  mkDerivationWith,
  wrapQtAppsHook,
  qtbase
}:

mkDerivationWith python3Packages.buildPythonApplication rec {
  name = "webmacs-${version}";
  version = "90f66817671df3590da5b657a4a0af9f70d6412f";

  src = fetchgit {
    url = "https://github.com/xantoz/webmacs";
    rev = version;
    sha256 = "11b81qdwq1ygwqfbsm2zgbacdlymnv2v3icfy5xd6iwjnlxlsak2";
    fetchSubmodules = true;
  };

  preBuild = ''
    export CC=g++
  '';

  buildInputs = [
    qtbase
  ];

  nativeBuildINputs = [
    wrapQtAppsHook
  ];

  propagatedBuildInputs = with python3Packages; [
    pyqt5
    pyqtwebengine
    dateparser
    jinja2
    pygments
    tzlocal
    pytz
    regex
    markupsafe
    six
  ];

  dontWrapGApps = true;
  dontWrapQtApps = true;

  postFixup = ''
    wrapProgram $out/bin/webmacs \
      "''${qtWrapperArgs[@]}"
  '';

  doCheck = false;

  meta = with stdenv.lib; {
    description = "webmacs - keyboard driven (emacs key bindings) browser";
    homepage =  https://webmacs.readthedocs.io/en/latest/;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
