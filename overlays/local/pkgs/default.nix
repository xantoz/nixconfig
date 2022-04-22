self: super:

with super.lib; {
  # xterm = super.xterm.overrideAttrs(old: {
  #   configureFlags = old.configureFlags ++ [ "--enable-exec-xterm" ];
  # });

  m17n_db = super.m17n_db.overrideAttrs(old: {
    patches = [ ../../../patches/m17n_db/0001-add-sv-qwerty.mim.patch ];
  });

  ratpoison = super.ratpoison.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      repo = "ratpoison";
      owner = "xantoz";
      rev = "ce52592c128a7feec9949d458912087a0823f80e";
      sha256 = "0x7g5hz0mrjnj59w5frl71jmxf5cz71l801b1fahm3fr4qcidjck";
    };
    buildInputs = old.buildInputs ++ [ super.autoreconfHook super.texinfo ];
    version = "1.4.10";
    name = "ratpoison-1.4.10";
  });

  emacs28 = super.emacs28.override {
    withX = true;
    withGTK3 = false;
    withGTK2 = false;
    toolkit = "no";
  };

  libplacebo = super.libplacebo.overrideAttrs(old: {
    src = super.fetchFromGitLab {
      domain = "code.videolan.org";
      owner = "videolan";
      repo = "libplacebo";
      rev = "22d06a7a25fb4b96a66543b6c4af78d1d4b2fff4";
      sha256 = "Orf8K5IYI2wqpyIFdeuzVLHqM+N2OAkkgXMp7+a/Rgk=";
    };
    buildInputs = old.buildInputs ++ [ super.libunwind ];
    version = "9999";
  });

  mpv-unwrapped =
    let
      mpv_rev = "0a63f3c41ef7e21342555fd05b2028618b1bd941"; # personal-build--v83
      mpv_sha256 = "GwPiorYlBJw2V+dhE6fwt7QzDoNvhir6aO3Ij7/lNuc=";
    in (super.mpv-unwrapped.override {
      openalSupport = true;
      archiveSupport = true;
      vdpauSupport = false;
      nv-codec-headers = null;
      jackaudioSupport = true;
      sixelSupport = true;
    }).overrideAttrs(old: {
      src = super.fetchFromGitHub {
        owner = "xantoz";
        repo = "mpv";
        rev = mpv_rev;
        sha256 = mpv_sha256;
      };
      version = "9999";
      patches = [ ];
      postPatch = old.postPatch + ''
        sed 's/UNKNOWN/g${mpv_rev}/' VERSION > snapshot_version
      '';
    });

  mpc-qt = super.mpc-qt.overrideAttrs(old: {
    src = super.fetchFromGitLab {
      owner = "mpc-qt";
      repo = "mpc-qt";
      rev = "2abe6e7fc643068d50522468fe75d614861555ad";
      sha256 = "1cis8dl9pm91mpnp696zvwsfp96gkwr8jgs45anbwd7ldw78w4x5";
    };
    version = "9999";
    name = "mpc-qt-9999";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.qt5.wrapQtAppsHook ];
  });

  libsigrokdecode = super.libsigrokdecode.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "sigrokproject";
      repo = "libsigrokdecode";
      rev = "02aa01ad5f05f2730309200abda0ac75d3721e1d";
      sha256 = "054p2sja32d5shlbsvrpaw3pq7gg4n03327ml1dn53pjnsl0wbjz";
    };
    version = "9999";
    name = "libsigrokdecode-9999";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook ];
  });

  libsigrok = super.libsigrok.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "sigrokproject";
      repo = "libsigrok";
      rev = "e972674d0b30b98dcc354b707a80b6bfc1aeb532";
      sha256 = "0sp9y0wb6caw6d69h0z10hd6vgjgmi8z1a93i3yjbzxx8a48iyzg";
    };
    version = "9999";
    name = "libsigrok-9999";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook ];
    firmware = super.fetchurl {
      url = "https://sigrok.org/download/binary/sigrok-firmware-fx2lafw/sigrok-firmware-fx2lafw-bin-0.1.7.tar.gz";
      sha256 = "1br32wfkbyg3v0bh5smwvn1wbkwmlscqvz2vdlx7irs9al3zsxn8";
    };
  });

  pulseview = super.pulseview.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "sigrokproject";
      repo = "pulseview";
      rev = "a6fa4d477d783478935a78c1b70596e38ae8ca64";
      sha256 = "1j5g8w74zmskq1r0rj68yz4xqv4z9j91v2hwr3i2jyk4g3yfxvd3";
    };
    patches = [];
    version = "9999";
    name = "pulseview-9999";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.qt514.qttools ];
  });

  redshift = (super.redshift.override { withGeolocation = false; });

  # # Die, networkmanager, die!
  # libproxy = super.libproxy.overrideAttrs(old: {
  #   buildInputs = foldr remove old.buildInputs [ super.networkmanager ];
  # });

  cellwriter = super.callPackage ./cellwriter { };

  easystroke = super.callPackage ./easystroke { };

  libdrc = super.callPackage ./libdrc { };

  simpleserver = super.callPackage ./simpleserver { };

  mcomix-lite = super.callPackage ./mcomix-lite { };

  lsix = super.callPackage ./lsix { };
}
