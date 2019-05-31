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

  libaom = super.libaom.overrideAttrs(old: {
    src = super.fetchgit {
      url = "https://aomedia.googlesource.com/aom";
      rev = "c35698139027872899b9d8cd4a871c1bc2c25a1a";
      sha256 = "1vszkihm7zm41iwcb3j435av5xnjgibgkrmj4lw27msf8mggbwjx";
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

  dav1d = super.dav1d.overrideAttrs(old: {
    src = super.fetchgit {
      url = "https://code.videolan.org/videolan/dav1d";
      rev = "785f00feccb5ed7c5739fc72bdcb9b422d8386ca";
      sha256 = "1kflqj2sw74x9jl97apmw3pp8sa455hhspqxnlwy7x7cmi7r5yql";
      fetchSubmodules = false;
    };
    version = "9999";
    name = "dav1d-9999";
  });

  libplacebo = super.callPackage ./libplacebo { };

  # to be able to build the wm4 removal branch first disable support for things
  # that have been removed, then also remove the --disable-xxx configure flags
  mpv =
    let
      custom_ffmpeg =
        (super.ffmpeg-full.override {
          nvenc = false;
        }).overrideAttrs(old: {
          src = super.fetchFromGitHub {
            owner = "FFmpeg";
            repo = "FFmpeg";
            rev = "9b069eb14e07d8faec32f2eef2d12e514290268f";
            sha256 = "0fjslhz876xj7pzzkr9877b38yfhqqiwq09q4rzh3k1m709w9i2b";
          };
          version = "9999";
          name = "ffmpeg-full-9999";
          buildInputs = old.buildInputs ++ [ self.dav1d ];
          configureFlags = old.configureFlags ++ [ "--enable-libdav1d" ];
        });
    in (super.mpv.override {
      cddaSupport = false;
      dvdnavSupport = false;
      dvdreadSupport = false;
      openalSupport = true;
      vulkanSupport = false; # we use libplacebo, so the upstream package is not quite right w.r.t vulkan
      archiveSupport = true;
    }).overrideAttrs(old: {
      src = super.fetchgit {
        url = "https://github.com/xantoz/mpv.git";
        rev = "27aded3f6a83b13d39fa8f1686d3a5d8cf711858";
        sha256 = "0qhchn75iybg1wqqqd7rz19z6fppvjwir1ynjvq7h8ifs02i0y79";
        fetchSubmodules = false;
        leaveDotGit = true;
        deepClone = true;
      };
      version = "9999";
      name = "mpv-9999";
      configureFlags =
        foldr remove old.configureFlags [ "--enable-dvbin" "--disable-dvdread" "--disable-dvdnav" "--disable-cdda" ];
      buildInputs =
        (remove super.ffmpeg_4 old.buildInputs) ++
        [ super.mesa_noglu self.libplacebo custom_ffmpeg ];
      nativeBuildInputs = old.nativeBuildInputs ++ [ super.git ]; # Needed by version.sh
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
