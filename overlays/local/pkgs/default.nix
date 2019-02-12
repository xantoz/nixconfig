self: super:

with super.lib; {
  xterm = super.xterm.overrideAttrs(old: {
    configureFlags = old.configureFlags ++ [ "--enable-exec-xterm" ];
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
  webmacs = super.callPackage ./webmacs { };
}
