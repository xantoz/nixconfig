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
      mpv_rev = "1f66709af4e6de071fa8552bbd4cea00af99b9c3";
      mpv_sha256 = "19n5xvycpnbbwwxdry818kk8c29za8mcbb8gg6rsya3lnnllbc6i";
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

  # # Die, networkmanager, die!
  # libproxy = super.libproxy.overrideAttrs(old: {
  #   buildInputs = foldr remove old.buildInputs [ super.networkmanager ];
  # });

  dolphinEmu = super.dolphinEmu.overrideAttrs(old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.qt5.wrapQtAppsHook ];
  });

  sway = super.sway.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = "a576bc27bf29e91ccf6659cafffeb6cd38a8d9f1";
      sha256 = "03si2ayspqzqk6y1ia0y3i0xcf6x3jdx3l75i879lrjkg06r5wgx";
    };
    patches = [];
    version = "9999";
    name = "sway-9999";
  });

  wlroots = super.wlroots.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "wlroots";
      rev = "b1a63bcd84adad5bffa8ba73dbf64e05c8ce9bc9";
      sha256 = "178hqmr2pcc4jpbghv812j5n3bm829jp0czphkdsxdniwlyrmi73";
    };
    patches = [];
    version = "9999";
    name = "wlroots-9999";
  });

  cellwriter = super.callPackage ./cellwriter { };

  easystroke = super.callPackage ./easystroke { };

  libdrc = super.callPackage ./libdrc { };

  simpleserver = super.callPackage ./simpleserver { };

  mcomix = super.callPackage ./mcomix { };
}
