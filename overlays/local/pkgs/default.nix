self: super:

with super.lib; {
  xterm = super.xterm.overrideAttrs(old: {
    configureFlags = old.configureFlags ++ [ "--enable-exec-xterm" ];
  });

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

  emacs26 = super.emacs26.override {
    withX = true;
    withGTK3 = false;
    withGTK2 = false;
    toolkit = "no";
  };

  emacs27 = super.emacs27.override {
    withX = true;
    withGTK3 = false;
    withGTK2 = false;
    toolkit = "no";
  };

  mpv-unwrapped =
    let
      mpv_rev = "cb5a836046d40d0a58f7d33c077f0b0f581adc9a";
      mpv_sha256 = "0lyqnw75fajzd8pxrfa2l3fw6bky3ri6kc4rmfp7hj7cd029qkfm";
      fakegit = super.writeShellScriptBin "git" ''
        echo "${mpv_rev}"
      '';
    in (super.mpv-unwrapped.override {
      openalSupport = true;
      archiveSupport = true;
      vdpauSupport = false;
      nv-codec-headers = null;
      sambaSupport = false;     # libsmbclient support was removed in git master
      sndioSupport = false;     # sndio support was removed in git master
    }).overrideAttrs(old: {
      src = super.fetchFromGitHub {
        owner = "xantoz";
        repo = "mpv";
        rev = mpv_rev;
        sha256 = mpv_sha256;
      };
      version = "9999";
      name = "mpv-9999";
      wafConfigureFlags = foldr remove old.wafConfigureFlags [
        "--disable-libsmbclient" # libsmbclient support was removed in git maste
        "--disable-sndio"        # sndio support was removed in git master
      ];
      nativeBuildInputs = old.nativeBuildInputs ++ [ fakegit ];
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
      rev = "296c29a33b9894b27686e56cb4368d61c7c815aa";
      sha256 = "0f6jvg4x169q6878mgk9g129k6nwzc60hmac69fhcjsn4fj2ldwx";
    };
    version = "9999";
    name = "libsigrokdecode-9999";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook ];
  });

  libsigrok = super.libsigrok.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "sigrokproject";
      repo = "libsigrok";
      rev = "25879a34e925ce58e62a59382b9a287a75350564";
      sha256 = "020hxhvfsx5wnj1pa5cns3dr3g4vdhan1bc0xp21n9f8rl78pc41";
    };
    version = "9999";
    name = "libsigrok-9999";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook ];
    firmware = super.fetchurl {
      url = "https://sigrok.org/download/binary/sigrok-firmware-fx2lafw/sigrok-firmware-fx2lafw-bin-0.1.6.tar.gz";
      sha256 = "14sd8xqph4kb109g073daiavpadb20fcz7ch1ipn0waz7nlly4sw";
    };
  });

  pulseview = super.pulseview.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "sigrokproject";
      repo = "pulseview";
      rev = "9d307c60d7fc2dee27bca6eaadd1e68bf7ab0cbf";
      sha256 = "0y2syvzwln82g2wk4xawyyfrkx9pq13faj159694v8f9da96yw6s";
    };
    version = "9999";
    name = "pulseview-9999";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.qt5.qttools ];

  });

  redshift = (super.redshift.override { withGeolocation = false; });

  # # Die, networkmanager, die!
  # libproxy = super.libproxy.overrideAttrs(old: {
  #   buildInputs = foldr remove old.buildInputs [ super.networkmanager ];
  # });

  dolphinEmu = super.dolphinEmu.overrideAttrs(old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.qt5.wrapQtAppsHook ];
  });

  cellwriter = super.callPackage ./cellwriter { };

  easystroke = super.callPackage ./easystroke { };

  libdrc = super.callPackage ./libdrc { };

  simpleserver = super.callPackage ./simpleserver { };

  mcomix = super.callPackage ./mcomix { };
}
