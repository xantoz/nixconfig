{ stdenv, fetchgit, python37Packages }:

python37Packages.buildPythonApplication rec {
  name = "webmacs-${version}";
  version = "67f10f0238833111676ec7742f46653ab284629f";

  src = fetchgit {
    url = "https://github.com/xantoz/webmacs";
    rev = version;
    sha256 = "0lb8panig1k5zpc0wfv1ip1q07g3gjmn0swxsdzi3s66lj8crirx";
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
