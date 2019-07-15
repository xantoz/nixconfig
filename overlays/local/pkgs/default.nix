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
      rev = "dd7789d99663c410472acb95b2a81269ae765b07";
      sha256 = "125528rnv7m6qfg0kvq8i6q0sp1br9ck6i8kc2ns4chk8yk4adch";
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
      rev = "c3748b13765a193fcff7f75b9d1ba99b24fa3509";
      sha256 = "0r29alib7baibdmhv0c44r86dhw9hxk8srfsh8ishl14js12yx0a";
      fetchSubmodules = false;
    };
    version="27.0.9999";
    name="emacs-vcs-27.0.9999";
    patches = [];
    configureFlags = old.configureFlags ++ [ "--with-x=yes" "--with-x-toolkit=no" ];
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook super.texinfo ];
  });

  dav1d = super.dav1d.overrideAttrs(old: {
    src = super.fetchgit {
      url = "https://code.videolan.org/videolan/dav1d";
      rev = "6ef9a030145eef79fdeab6d4d38e00423ae7a83d";
      sha256 = "0sg8px7q3q7vpv05g0mp63vm9xvg17ja6ffcw5gn8qbf6d9svhvq";
      fetchSubmodules = false;
    };
    version = "9999";
    name = "dav1d-9999";
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
        }).overrideAttrs(old: {
          src = super.fetchFromGitHub {
            owner = "FFmpeg";
            repo = "FFmpeg";
            rev = "7cb4f8c962bdd0e08881f8ce15f7bdd2d546ba44";
            sha256 = "1bkzjj692q38w1pk4yj33fl3h28ggwjv2sj3y5gr9z2n84gakcvf";
          };
          version = "9999";
          name = "ffmpeg-full-9999";
          buildInputs = old.buildInputs ++ [ self.dav1d ];
          configureFlags = old.configureFlags ++ [ "--enable-libdav1d" ];
        });
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
      src = super.fetchgit {
        url = "https://github.com/xantoz/mpv.git";
        rev = "c503899d41b602eff5c550719ad3a9b3140fb8e3";
        sha256 = "1yzha5rp2dfxyiffl7avzshidyqaxlnfvp1952sjprh5bk4kw2ir";
        fetchSubmodules = false;
        leaveDotGit = true;
        deepClone = true;
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
      nativeBuildInputs = old.nativeBuildInputs ++ [ super.git ]; # Needed by version.sh
    });

  mpc-qt = super.mpc-qt.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "wm4";
      repo = "mpc-qt";
      rev = "2abe6e7fc643068d50522468fe75d614861555ad";
      sha256 = "1cis8dl9pm91mpnp696zvwsfp96gkwr8jgs45anbwd7ldw78w4x5";
    };
    version = "9999";
    name = "mpc-qt-9999";
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

  webmacs = super.callPackage ./webmacs { };
}
