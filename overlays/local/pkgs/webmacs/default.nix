{ stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  name = "webmacs-${version}";
  # version = "af40a04d3b713a26d0b00e74eb185f6bfd4978c2";
  version = "702e600e9e141d2f94616676a75ed8cae97fcae4";

  src = fetchFromGitHub {
    owner = "parkouss";
    repo = "webmacs";
    rev = version;
    sha256 = "19k9z9i4pr23yx5dw7wgsmly3g3yyc2hr66jk456fc388qk3z7yr";
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
