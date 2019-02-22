{ stdenv, fetchFromGitHub, python37Packages }:

python37Packages.buildPythonApplication rec {
  name = "webmacs-${version}";
  version = "d03057cf14491bcbd9f3a64fc126ec3e6f9a590e";

  src = fetchFromGitHub {
    owner = "xantoz";
    repo = "webmacs";
    rev = version;
    sha256 = "099ml91jp3q4slhyzdrhf0fkwzgj18r6f6zjwzd99lc72vcihb4g";
    fetchSubmodules = true;
  };

  preBuild = ''
    export CC=g++
  '';

  propagatedBuildInputs = with python37Packages; [
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
