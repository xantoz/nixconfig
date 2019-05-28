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
      rev = "41bf865329bbc2411203e9a90bc8dfd93ed5ef31";
      sha256 = "01s5blb3xz2ykpdxf2c19z5m8v9ch0klaczphb37ql0n7q6d1w5c";
      fetchSubmodules = false;
    };
    version="27.0.9999";
    name="emacs-vcs-27.0.9999";
    patches = [];
    configureFlags = old.configureFlags ++ [ "--with-x=yes" "--with-x-toolkit=no" ];
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook super.texinfo ];
  });

  libaom = super.libaom.overrideAttrs(old: let rev = "d00a576dc3196a164ff70666a5e046f5d9b33e95"; in {
    src = super.fetchgit {
      url = "https://aomedia.googlesource.com/aom";
      rev = rev;
      sha256 = "1jynqqml18182h3nz2yxsdc4wvs3j7nzj17pvy6ic2s4nrk6d1rz";
      fetchSubmodules = false;
    };
    version = rev;
    name = "libaom-${rev}";
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

  libplacebo = super.callPackage ./libplacebo { };

  # to be able to build the wm4 removal branch first disable support for things
  # that have been removed, then also remove the --disable-xxx configure flags
  mpv =
    let
      # TODO: git version of libdav1d
      custom_ffmpeg =
        super.ffmpeg-full.overrideAttrs(old: {
          src = super.fetchFromGitHub {
            owner = "FFmpeg";
            repo = "FFmpeg";
            rev = "9b069eb14e07d8faec32f2eef2d12e514290268f";
            sha256 = "0fjslhz876xj7pzzkr9877b38yfhqqiwq09q4rzh3k1m709w9i2b";
          };
          version = "9999";
          name = "ffmpeg-full-9999";
          buildInputs = old.buildInputs ++ [ super.dav1d ];
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
        rev = "2efaaba1956b681f039927ee57f24a893ee1fab4";
        sha256 = "19qmrl32f5qgildm69dlkakjv2wamw8nrabyiyihzppnm9qsx1z5";
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
