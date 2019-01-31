{ stdenv, fetchFromGitHub, python36Packages }:

python36Packages.buildPythonApplication rec {
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

  propagatedBuildInputs = with python36Packages; [
    pyqt5
    dateparser
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
