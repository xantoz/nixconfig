{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  name = "greaseweazle-${version}";
  version = "v1.22";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "keirf";
    repo = "greaseweazle";
    rev = "${version}";
    sha256 = "sha256-Ki4OvtcFn5DH87OCWY7xN9fRhGxlzS9QIuQCJxPWJco=";
  };

  build-system = with python3Packages; [ setuptools_scm wheel ];

  dependencies = with python3Packages; [
    crcmod
    bitarray
    pyserial
    requests
  ];

  meta = {
    description = "Tools for accessing a floppy drive at the raw flux level";
    homepage = https://github.com/keirf/greaseweazle;
    license = lib.licenses.unlicense;
  };
}
