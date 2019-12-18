self: super:

with super.lib; {
  xterm = super.xterm.overrideAttrs(old: {
    configureFlags = old.configureFlags ++ [ "--enable-exec-xterm" ];
  });

  m17n_db = super.m17n_db.overrideAttrs(old: {
    patches = [ ../../../patches/m17n_db/0001-add-sv-qwerty.mim.patch ];
  });

  mcomix = super.mcomix.overrideAttrs(old: {
    patches = [ ../../../patches/mcomix/fix-PIL-image-version.patch ];
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

  emacs26 = (super.emacs26.override {
    withX = true;
    withGTK3 = false;
    withGTK2 = false;
  }).overrideAttrs(old: {
    configureFlags = old.configureFlags ++ [ "--with-x=yes" "--with-x-toolkit=no" ];
  });

  emacsVcs27 = (super.emacs26.override {
    withX = true;
    withGTK3 = false;
    withGTK2 = false;
  }).overrideAttrs(old: {
    src = super.fetchgit {
      url = "https://git.savannah.gnu.org/git/emacs.git";
      rev = "4051fa3ba9b4527b57b4cd114ddaaf72a3b23528";
      sha256 = "0c1cld0g2dbxawj5pygygxxp2p56fbiw9zv01vzv99xc4p9sglr0";
      fetchSubmodules = false;
    };
    version="27.0.9999";
    name="emacs-vcs-27.0.9999";
    patches = [];
    configureFlags = old.configureFlags ++ [ "--with-x=yes" "--with-x-toolkit=no" ];
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook super.texinfo ];
  });

  mpv =
    let
      custom_libaom = super.libaom.overrideAttrs(old: {
        src = super.fetchgit {
          url = "https://aomedia.googlesource.com/aom";
          rev = "d53f175e3a90e20e850d32d8bbffbd29b0a35282"; # v1.0.0-errata1-avif-27-gd53f175e3
          sha256 = "15fnanpgnicjh7ndh6c68g8ciwpwkzyh209d99ffk6453s59qw54";
          fetchSubmodules = false;
        };
        version = "9999";
        name = "libaom-9999";
        # As is way too common, the prefix handling in the libaom build is borked,
        # and all paths, even ones beginning with /, are treated as relative to the
        # prefix. So here we change some variables (from the absolute paths that nix
        # would usually put) to make it work.
        cmakeFlags = [
          "-DCMAKE_INSTALL_INCLUDEDIR=include"
          "-DCMAKE_INSTALL_LIBDIR=lib"
          "-DCMAKE_INSTALL_NAME_DIR=lib"
        ];
      });
      custom_ffmpeg =
        (super.ffmpeg-full.override {
          libaom = custom_libaom;
          nvenc = false;
        });
      mpv_rev = "127b6e9823cfad806fb04e3e9893289ae47b3c60";
      mpv_sha256 = "0k6ldn4p9yxamp42b7sv4aqdkmhih7hgzhrsqvrk4p1h1cr1zq7z";
      fakegit = super.writeShellScriptBin "git" ''
        echo "${mpv_rev}"
      '';
    in (super.mpv.override {
      openalSupport = true;
      archiveSupport = true;
      vdpauSupport = false;
      nv-codec-headers = null;
    }).overrideAttrs(old: {
      src = super.fetchFromGitHub {
        owner = "xantoz";
        repo = "mpv";
        rev = mpv_rev;
        sha256 = mpv_sha256;
      };
      version = "9999";
      name = "mpv-9999";
      buildInputs =
        (remove super.ffmpeg_4 old.buildInputs) ++ [ custom_ffmpeg ];
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
      rev = "9e953ff151c5d714dd57ec81eb402ec1d77ab8e7";
      sha256 = "08albnn8zr0wdr734jqgfcjij300979gi26k0yi4yijmf711dqsa";
    };
    version = "9999";
    name = "libsigrokdecode-9999";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook ];
  });

  libsigrok = super.libsigrok.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "sigrokproject";
      repo = "libsigrok";
      rev = "cfdc80151b106ae83f3380cb308d53314974257a";
      sha256 = "12rywq85gj5ccjbifs3m1jwy69b2pkckm0lifwbjp42wn1r8ixni";
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
      rev = "ac91f7ad5b49267a072f83fcacfe3a695d37cd7c";
      sha256 = "0qfjgv94rg14pyazylnnqwxqma66ri9vd3c5y30zjk3qgsydbjys";
    };
    version = "9999";
    name = "pulseview-9999";
  });

  redshift = (super.redshift.override { withGeolocation = false; });

  # Die, networkmanager, die!
  libproxy = super.libproxy.overrideAttrs(old: {
    buildInputs = foldr remove old.buildInputs [ super.networkmanager ];
  });

  dolphinEmu = super.dolphinEmu.overrideAttrs(old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.qt5.wrapQtAppsHook ];
  });

  sway = super.sway.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = "aa8fe584215d29e31ae5af43afa81db03b997f85";
      sha256 = "0zpq14h3jxb2igmf3jil475ifqd45506h0vvf3s6hg2qmhmrrwvm";
    };
    patches = [];
    version = "9999";
    name = "sway-9999";
  });

  wlroots = super.wlroots.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = "774548696c0a5f3164a3ce5a85d893da6c3b18be";
      sha256 = "0ij8fdi83kxzf4mi1mpn2zyy8zb5nk5nxhnqgzksb3zsiylwkpd6";
    };
    patches = [];
    version = "9999";
    name = "wlroots-9999";
  });

  cellwriter = super.callPackage ./cellwriter { };

  easystroke = super.callPackage ./easystroke { };

  libdrc = super.callPackage ./libdrc { };

  simpleserver = super.callPackage ./simpleserver { };
}
