self: super:

with super.lib; {
  xterm = super.xterm.overrideAttrs(old: {
    configureFlags = old.configureFlags ++ [ "--enable-exec-xterm" ];
  });
  emacs26 = super.emacs26.overrideAttrs(old: {
    configureFlags = old.configureFlags ++ [ "--with-x=yes" "--with-x-toolkit=no" ];
  });
  m17n_db = super.m17n_db.overrideAttrs(old: {
    patches = [ ../../../patches/m17n_db/0001-add-sv-qwerty.mim.patch ];
  });
  mpv = super.mpv.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      repo = "mpv";
      owner = "xantoz";
      rev = "drm-presentation-feedback";
      sha256 = "1fdzqxzyzwnxav8sw4649z881frdnn5jj94ngk42bm46l88ry0r1";
    };
    version = "0.29.1-git";
    name = "mpv-0.29.1-git";
    buildInputs = old.buildInputs ++ [
      super.pkgs.mesa_noglu
    ];
  });

  libsigrokdecode = super.libsigrokdecode.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      repo = "libsigrokdecode";
      owner = "sigrokproject";
      rev = "49d3e6f83c68e62138621f94bf5e22c9d7717fca";
      sha256 = "07gjg881gj9718hmc0815jvspzs2dx7d05jksk2ixlslqyjdphc2";
    };
    version = "git";
    name = "libsigrokdecode-git";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook ];
  });

  libsigrok = super.libsigrok.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      repo = "libsigrok";
      owner = "sigrokproject";
      rev = "1b6b9c01dfd33a75b22d7b5e0d6a284ae37b39e1";
      sha256 = "08i6bkvjm7c7176idzdl83ckxmpzdfiz3issji01y3myscyfpwjr";
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
      rev = "baef263a884ee4ff4d3dd15cd4d334fa9178b090";
      sha256 = "0fxpisrjk00ird0qypb36cid198mc6y8k9grwcilgrpy4m8isn0z";
    };
    version = "git";
    name = "pulseview-git";
  });

  webmacs = super.callPackage ./webmacs { };
}
