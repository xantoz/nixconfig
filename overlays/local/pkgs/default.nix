self: super:

with super.lib; {
  xterm = super.xterm.overrideAttrs(old: {
    configureFlags = old.configureFlags ++ [ "--enable-exec-xterm" ];
  });

  m17n_db = super.m17n_db.overrideAttrs(old: {
    patches = [ ../../../patches/m17n_db/0001-add-sv-qwerty.mim.patch ];
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
      rev = "bcc6468b39916de6a3756c98e744ed5d0534eb40";
      # date = "2019-04-06T11:36:34+02:00";
      sha256 = "0cpyw5y5i0b4j6cdvifqq3b5342xl14wi4sv1p9rn9my7qf72lq7";
      fetchSubmodules = false;
    };
    version="27.0.9999";
    name="emacs-vcs-27.0.9999";
    patches = [];
    configureFlags = old.configureFlags ++ [ "--with-x=yes" "--with-x-toolkit=no" ];
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook super.texinfo ];
  });

  # to be able to build the wm4 removal branch first disable support for things
  # that have been removed, then also remove the --disable-xxx configure flags
  mpv = (super.mpv.override {
    cddaSupport = false;
    dvdnavSupport = false;
    dvdreadSupport = false;
    openalSupport = true;
  }).overrideAttrs(old: {
    src = super.fetchFromGitHub {
      repo = "mpv";
      owner = "xantoz";
      rev = "7b29a2ad82b1d29da14bd57c6b90a8a142d7e389";
      sha256 = "1hy2ffcsgj70j83syrg5vlc9amsg25mxn0r4s09v4qfryqicjqq3";
    };
    version = "0.29.1-git";
    name = "mpv-0.29.1-git";
    configureFlags =
      foldr remove old.configureFlags [ "--enable-dvbin" "--disable-dvdread" "--disable-dvdnav" "--disable-cdda" ];
    buildInputs = old.buildInputs ++ [ super.pkgs.mesa_noglu ];
  });

  libsigrokdecode = super.libsigrokdecode.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      repo = "libsigrokdecode";
      owner = "sigrokproject";
      rev = "12a045188f21f42300b4cf25302478e25d15acb6";
      sha256 = "0sm9f975plz0gkglgzhjzgxs29kxfrj6r80cm5p0p2w6w94n5059";
    };
    version = "git";
    name = "libsigrokdecode-git";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook ];
  });

  libsigrok = super.libsigrok.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      repo = "libsigrok";
      owner = "sigrokproject";
      rev = "7ed4ae63075531b6f7e9052b79f9883504d13271";
      sha256 = "0pccj8x3j1gkiqmfmik6pq8ykf831xhj6zyzpg57j57n93jdc8dd";
    };
    version = "git";
    name = "libsigrok-git";
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
      rev = "af33d4cbacc745f4473f5c0f4fa1f9ebb8d84d0a";
      sha256 = "0vwhi023hj9ajnxswpkf6mldc1vf9fq4jnsdziz4ymvxp94ibsgp";
    };
    version = "git";
    name = "pulseview-git";
  });

  webmacs = super.callPackage ./webmacs { };
}
