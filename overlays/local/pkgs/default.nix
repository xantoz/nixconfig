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
      rev = "5f4e8e2e088de9fb76cb631077c6eddd3219f594";
      # date = "2019-04-06T11:36:34+02:00";
      sha256 = "1dbpdj0mbywjlv0ahr4yyjxsqibjd26qbiz66c1qwadd5kyka32f";
      fetchSubmodules = false;
    };
    version="27.0.9999";
    name="emacs-vcs-27.0.9999";
    patches = [];
    configureFlags = old.configureFlags ++ [ "--with-x=yes" "--with-x-toolkit=no" ];
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook super.texinfo ];
  });

  libplacebo = super.callPackage ./libplacebo { };

  # to be able to build the wm4 removal branch first disable support for things
  # that have been removed, then also remove the --disable-xxx configure flags
  mpv = (super.mpv.override {
    cddaSupport = false;
    dvdnavSupport = false;
    dvdreadSupport = false;
    openalSupport = true;
    vulkanSupport = false; # we use libplacebo, so the upstream package is not quite right w.r.t vulkan
  }).overrideAttrs(old: {
    src = super.fetchgit {
      url = "https://github.com/xantoz/mpv.git";
      rev = "89b23a9c1037a701a61745dcfcd266242d4b7656";
      sha256 = "094cp4bn727g11a98z7nzj2j7rijbi0dvczqcrq47a8bzw31lq6p";
      fetchSubmodules = false;
      leaveDotGit = true;
    };
    version = "9999";
    name = "mpv-9999";
    configureFlags =
      foldr remove old.configureFlags [ "--enable-dvbin" "--disable-dvdread" "--disable-dvdnav" "--disable-cdda" ];
    buildInputs = old.buildInputs ++ [ super.pkgs.mesa_noglu self.pkgs.libplacebo ];
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

  webmacs = super.callPackage ./webmacs { };
}
