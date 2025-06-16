{
  lib,
  python3Packages,
  fetchFromGitHub,
  fetchPypi,

  onnxruntime,
}:

let
  FreeSimpleGUI = python3Packages.buildPythonPackage rec {
    pname = "freesimplegui";
    # version = "5.1.1";
    version = "5.2.0";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-UMhpuNXYT0gXUmCiFp5Cc5T/GyKxCbUUGFjV9Q5jvvo=";
    };

    dependencies = with python3Packages; [
      tkinter
    ];
  };

  python_osc = python3Packages.buildPythonPackage rec {
    pname = "python_osc";
    version = "1.9.0";

    format = "pyproject";
    nativeBuildInputs = with python3Packages; [ setuptools wheel ];

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-q1D2axoZ79W/9yLyarZFDfGc3YS6ho8IyaM+fHhRRFY=";
    };
  };

  v4l2py = python3Packages.buildPythonPackage rec {
    pname = "v4l2py";
    version = "3.0.0";

    format = "pyproject";
    nativeBuildInputs = with python3Packages; [ setuptools wheel ];

    dependencies = with python3Packages; [ linuxpy ];

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-foPAL3OT2og8eRube6PdERY7QtFeaNwJs+PZmm11t6Q=";
    };
  };
in
python3Packages.buildPythonApplication rec {
# python3Packages.buildPythonPackage rec {
  format = "pyproject";
  nativeBuildInputs = with python3Packages; [ setuptools wheel ];

  pname = "ProjectBabble";
  version = "v2.0.7-149-gdfeeb87";
  # pyproject = true;

  src = fetchFromGitHub {
    owner = "Project-Babble";
    repo = "ProjectBabble";
    rev = "dfeeb87e868c8c70da59206077cd6fd6ada8fbe2";
    hash = "sha256-vi9KCHzKwxkiksOmRBA9rMb2oFjZhgLd46IkI2KjhZk=";
  };

  # sourceRoot = "${src.name}/BabbleApp";

  pythonDeps = [
    python3Packages.onnxruntime
    python3Packages.torch
    python3Packages.torchvision
    python3Packages.opencv-python
    python3Packages.pillow
    python3Packages.pydantic
    FreeSimpleGUI
    python_osc
    python3Packages.pyserial
    python3Packages.colorama
    # comtypes
    # pygrabber
    python3Packages.psutil
    python3Packages.requests
    v4l2py
    python3Packages.sounddevice
    python3Packages.soundfile
  ];

  dependencies = [ onnxruntime ] ++ pythonDeps;

  postPatch = ''
    sed -i '1 i\#!/usr/bin/env python3' BabbleApp/babbleapp.py

    # Do an ugly sys.path hack, because BabbleApp imports are all wrong
    # Also contains an ugly chdir hack, because of all the relative paths in babble
    echo -e 'import sys\nimport os\nfrom pathlib import Path\nmypath = str(Path(__file__).resolve().parent)\nsys.path.append(mypath)\nprint(sys.path)\nos.chdir(mypath)\n' > BabbleApp/__init__.py

    # Make sure sub-libs utils and vivefacialtracker are included
    touch BabbleApp/utils/__init__.py BabbleApp/vivefacialtracker/__init__.py

    # Patch to fix location of config files
    sed -i -e '1 i\from pathlib import Path' \
           -e 's|^CONFIG_FILE_NAME.*$|CONFIG_FILE_NAME = Path.home() / ".config" / "ProjectBabble" / "babble_settings.json"|' \
           -e '/^CONFIG_FILE_NAME.*$/a CONFIG_FILE_NAME.parent.mkdir(parents=True, exist_ok=True)' \
           -e 's|^BACKUP_CONFIG_FILE_NAME.*$|BACKUP_CONFIG_FILE_NAME = Path.home() \/ ".config" \/ "ProjectBabble" \/ "babble_settings.backup"|' \
           -e '/^BACKUP_CONFIG_FILE_NAME.*$/a BACKUP_CONFIG_FILE_NAME.parent.mkdir(parents=True, exist_ok=True)' \
           BabbleApp/config.py

    # Patch the logger module to not try to store logs in a relative directory. For now we just patch it to write them in a folder under /tmp
    sed -i -e 's|log_dir\s*=\s*\".*\"|log_dir = "/tmp/Babble/Logs"|' BabbleApp/logger.py

    cat > setup.py <<__EOF__
    #!/usr/bin/env python
    from setuptools import setup, find_packages
    from pathlib import Path

    # Resolve paths relative to the BabbleApp/ directory
    this_dir = Path(__file__).resolve().parent
    reqs = [l.rstrip("; ") for l in (this_dir / "BabbleApp" / "requirements.txt").read_text().splitlines()]

    setup(
        name="project-babble",
        version="2.0.7",
        packages=find_packages(),
        entry_points={
            "console_scripts": [
                "babble-app = BabbleApp.babbleapp:main",
            ],
        },
        package_data = { "BabbleApp": [ "**/*" ] },
        include_package_data=True,
    )
    __EOF__
  '';

  meta = {
    description = "A DIY mouth tracking method for VR";
    homepage = "https://github.com/Project-Babble/ProjectBabble";
    license = lib.licenses.unfree;
  };
}
