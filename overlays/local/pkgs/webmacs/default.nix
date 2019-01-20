{ stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  name = "webmacs-${version}";
  version = "6a0ff0747f04837301b0a1944ec9f27d1ae510f5";

  src = fetchFromGitHub {
    owner = "parkouss";
    repo = "webmacs";
    rev = version;
    sha256 = "03fi22l6imm7bv7c897lq1xl3v640gqb7haxmnsnh7jdn13fr1xv";
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

  doCheck = false;

  meta = with stdenv.lib; {
    description = "webmacs - keyboard driven (emacs key bindings) browser";
    homepage =  https://webmacs.readthedocs.io/en/latest/;
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
