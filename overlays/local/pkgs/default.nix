self: super:

with super.lib; rec {
  # back-port of https://github.com/ivan/nixpkgs/commit/b8f9ca39444398e1078bf25859c62f46af18925e
  python37Packages.dateparser = super.python37Packages.dateparser.overridePythonAttrs(old: {
      preCheck =''
        # skip because of missing convertdate module, which is an extra requirement
        rm tests/test_jalali.py

        # skip because of failures with Python 3.7: https://github.com/NixOS/nixpkgs/issues/52766
        rm tests/test_search.py
      '';
  });
  xterm = super.xterm.overrideAttrs(old: {
    configureFlags = old.configureFlags ++ [ "--enable-exec-xterm" ];
  });
  m17n_db = super.m17n_db.overrideAttrs(old: {
    patches = [ ../../../patches/m17n_db/0001-add-sv-qwerty.mim.patch ];
  });
  webmacs = super.callPackage ./webmacs { };
}
