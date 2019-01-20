self: super:

{
  # back-port of https://github.com/ivan/nixpkgs/commit/b8f9ca39444398e1078bf25859c62f46af18925e
  python37Packages.dateparser = super.python37Packages.dateparser.overrideAttrs(old: {
      preCheck =''
        # skip because of missing convertdate module, which is an extra requirement
        rm tests/test_jalali.py
g
        # skip because of failures with Python 3.7: https://github.com/NixOS/nixpkgs/issues/52766
        rm tests/test_search.py
      '';
  });
  xterm = super.xterm.overrideAttrs(old: {
    configureFlags = old.configureFlags ++ [ "--enable-exec-xterm" ];
  });
}
