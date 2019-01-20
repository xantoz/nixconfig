{ stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  name = "webmacs-${version}";
  version = "96fe2e475c8cc32e2a1dda391d964e966c20144f";

  src = fetchFromGitHub {
    owner = "xantoz";
    repo = "webmacs";
    rev = version;
    sha256 = "1ip4z7iq2kmfi8jl1j0kxvq8gbgq00x26r71n3bgkyxvazlvp7vp";
    fetchSubmodules = true;
  };

  preBuild = ''
    export CC=g++
  '';

  propagatedBuildInputs = with python3Packages; [
    pyqt5
    (dateparser.overridePythonAttrs(old: {
      preCheck =''
        # skip because of missing convertdate module, which is an extra requirement
        rm tests/test_jalali.py

        # skip because of failures with Python 3.7: https://github.com/NixOS/nixpkgs/issues/52766
        rm tests/test_search.py
      '';
    }))
    jinja2
    pygments
    tzlocal
    pytz
    regex
    markupsafe
    six
  ];

  meta = with stdenv.lib; {
    description = "webmacs - keyboard driven (emacs key bindings) browser";
    homepage =  https://webmacs.readthedocs.io/en/latest/;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
