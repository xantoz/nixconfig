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

  libplacebo = super.callPackage ./libplacebo { };

  mpv =
    let
      custom_libaom = super.libaom.overrideAttrs(old: {
        src = super.fetchgit {
          url = "https://aomedia.googlesource.com/aom";
          rev = "32185d165e0a238a32b20c5bbd59e360bd46d067";
          sha256 = "1h3w56masgpwrvcf6r033rhzsxhrl16z5pbr8m59i0rd46pzbhlz";
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
      mpv_rev = "5626642b39b00ade9d44821981ef7b1e97f546c9";
      mpv_sha256 = "11xddnzvg5jz4rfrp4h6avg7qb51190fi7i0l5b4jhza06rn2i4s";
      fakegit = super.writeShellScriptBin "git" ''
        echo "${mpv_rev}"
      '';
    in (super.mpv.override {
      # to be able to build the wm4 removal branch first disable support for things
      # that have been removed, then also remove the --disable-xxx configure flags
      cddaSupport = false;
      dvdnavSupport = false;
      dvdreadSupport = false;
      openalSupport = true;
      vulkanSupport = false; # we use libplacebo, so the upstream package is not quite right w.r.t vulkan
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
      configureFlags =
        (foldr remove old.configureFlags [
          "--enable-dvbin"
          "--disable-dvdread"
          "--disable-dvdnav"
          "--disable-cdda"
        ]) ++ [
          "--enable-vulkan" "--enable-libplacebo"
        ];
      buildInputs =
        (remove super.ffmpeg_4 old.buildInputs) ++
        [ super.mesa_noglu self.libplacebo custom_ffmpeg ];
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
      rev = "e64a9722829b78cc9e0c1089307ed76cdadad1fe";
      sha256 = "1ac2cx2idqp9q8jlmbqr75jpx0mgdg0c3hpjrxzwc79ngxlc3r4m";
    };
    version = "9999";
    name = "libsigrokdecode-9999";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook ];
  });

  libsigrok = super.libsigrok.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "sigrokproject";
      repo = "libsigrok";
      rev = "80d349756971fe8c4e3326e0d0e38a45a82a6554";
      sha256 = "10r128xs5kxxnvcclg7f7r60dnisb8lcgsyhf2rw0x7rynkxwxjp";
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
      rev = "8b4ce4aedc46a464d4ab126ba461e9d39324062d";
      sha256 = "1x5d648vaqmhv3qpgybnnawp0n8w5g6q0havn64ak90nrg9p69fm";
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

  webmacs = super.libsForQt5.callPackage ./webmacs { };

  cellwriter = super.callPackage ./cellwriter { };

  easystroke = super.callPackage ./easystroke { };

  libdrc = super.callPackage ./libdrc { };

  simpleserver = super.callPackage ./simpleserver { };
}
