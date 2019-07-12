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
      rev = "46980237595c3065f15106b0c3483cdd57fd3153";
      sha256 ="0ibra0gm2x8igjlr4xi4c8r3ahmlljkw8a90kc4z1gy8g30yzj3m";
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
            rev = "b19550367fff8d8d77e94c4c5eaac42e70c61fc5";
            sha256 = "1yzha5rp2dfxyiffl7avzshidyqaxlnfvp1952sjprh5bk4kw2ir";
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
      repo = "libsigrokdecode";
      owner = "sigrokproject";
      rev = "7592278ad81ee057718b01b4e9e18a99e833b51d";
      sha256 = "0hif9rk10vp0d1wcd3cgaaxnjh136ik5d4q0rvi59g06hxwqylcq";
    };
    version = "9999";
    name = "libsigrokdecode-9999";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook ];
  });

  libsigrok = super.libsigrok.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      repo = "libsigrok";
      owner = "sigrokproject";
      rev = "7d0f52f7e5cb16d204490ca4006983237bf3df7d";
      sha256 = "0ykxzxsp9zi37i6q33w30n9md94p3lpwbxz36k5z0lfmjyybpy7k";
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
      repo = "pulseview";
      owner = "sigrokproject";
      rev = "96dbf014dad1309d4ade9c14a8b46733e2f531c8";
      sha256 = "1qp1ny31pk9b9lwvsm3363nj5cxmn0453arflrbhpq5ckbd9161y";
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
