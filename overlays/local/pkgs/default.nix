self: super:

let
  pkgs_unstable = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/bf9fa86a9b1005d932f842edf2c38eeecc98eef3.tar.gz";
    sha256 = "1abs7hmg9c60h7chr8x9jkhh4cj32b13nr8n704myl4g8rm8sh91";
  }) {};
in
with super.lib; {
  # xterm = super.xterm.overrideAttrs(old: {
  #   configureFlags = old.configureFlags ++ [ "--enable-exec-xterm" ];
  # });

  m17n_db = super.m17n_db.overrideAttrs(old: {
    patches = [ ../../../patches/m17n_db/0001-add-sv-qwerty.mim.patch ];
  });

  ratpoison = super.ratpoison.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      repo = "ratpoison";
      owner = "xantoz";
      rev = "ce52592c128a7feec9949d458912087a0823f80e";
      sha256 = "0x7g5hz0mrjnj59w5frl71jmxf5cz71l801b1fahm3fr4qcidjck";
    };
    buildInputs = old.buildInputs ++ [ super.autoreconfHook super.texinfo ];
    version = "1.4.10";
    name = "ratpoison-1.4.10";
  });

  emacs28 = super.emacs28.override {
    withX = true;
    withGTK3 = false;
    withNativeCompilation = false;
    toolkit = "no";
  };

  emacs29 = super.emacs29.override {
    withX = true;
    withGTK3 = false;
    withNativeCompilation = false;
    toolkit = "no";
  };

  emacs30 = super.emacs30.override {
    withX = true;
    withGTK3 = false;
    withNativeCompilation = false;
    toolkit = "no";
  };

  emacs = super.emacs.override {
    withX = true;
    withGTK3 = false;
    withNativeCompilation = false;
    toolkit = "no";
  };

  # emacsNativeNoAOT = (super.emacs.override {
  #   withX = true;
  #   withGTK3 = false;
  #   toolkit = "no";
  # }).overrideAttrs(old: {
  #   env = super.lib.attrsets.overrideExisting old.env { NATIVE_FULL_AOT = "0"; };
  # });

  # emacsNoNativeComp = super.emacs.override {
  #   withX = true;
  #   withGTK3 = false;
  #   withNativeCompilation = false;
  #   toolkit = "no";
  # };

  # emacsPgtkNoNativeComp = super.emacs.override {
  #   withX = false;
  #   withGTK3 = true;
  #   withPgtk = true;
  #   withNativeCompilation = false;
  # };

  mpv-unwrapped = super.mpv-unwrapped.override {
    openalSupport = true;
    archiveSupport = true;
    jackaudioSupport = true;
    sixelSupport = true;
  };

  # mpv-unwrapped =
  #   let
  #     mpv_rev = "c1bef0f084b339b79f7b6551267bf59fe12f9389";
  #     mpv_sha256 = "sha256-xn8HHglm39FhCi3CNCrFsYTiT3ptZdDimBjQ18s0aaw=";
  #   in (super.mpv-unwrapped.override {
  #     openalSupport = true;
  #     archiveSupport = true;
  #     vdpauSupport = false;
  #     nv-codec-headers = null;
  #     jackaudioSupport = true;
  #     sixelSupport = true;
  #   }).overrideAttrs(old: {
  #     src = super.fetchFromGitHub {
  #       owner = "xantoz";
  #       repo = "mpv";
  #       rev = mpv_rev;
  #       sha256 = mpv_sha256;
  #     };
  #     version = "9999";
  #     patches = [ ];
  #     postPatch = old.postPatch + ''
  #       sed 's/UNKNOWN/g${mpv_rev}/' VERSION > snapshot_version
  #     '';
  #   });

  doas = super.doas.override { withPAM = false; };

  # vkdt = super.vkdt.overrideAttrs(old: {
  #   makeFlags = old.makeFlags ++ [ "CFLAGS=-Wnoerror" ];
  # });

  mpc-qt = super.mpc-qt.overrideAttrs(old: {
    src = super.fetchFromGitLab {
      owner = "mpc-qt";
      repo = "mpc-qt";
      rev = "2abe6e7fc643068d50522468fe75d614861555ad";
      sha256 = "1cis8dl9pm91mpnp696zvwsfp96gkwr8jgs45anbwd7ldw78w4x5";
    };
    version = "9999";
    name = "mpc-qt-9999";
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.qt5.wrapQtAppsHook ];
  });

  # libsigrokdecode = super.libsigrokdecode.overrideAttrs(old: {
  #   src = super.fetchFromGitHub {
  #     owner = "sigrokproject";
  #     repo = "libsigrokdecode";
  #     rev = "24ba9e1bdfe107e394176eda3116b714463a8437";
  #     sha256 = "KUl3zwzgl7FlKHZGjcXmCN9EyRa6R4IGJEBJxEDe9Fo=";
  #   };
  #   version = "9999";
  #   name = "libsigrokdecode-9999";
  #   nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook ];
  #   doCheck = false; # Tests seem to fail in some remote-building scenarios (at least when building aarch64 on x86_64 with the help of qemu)
  # });

  # libsigrok = super.libsigrok.overrideAttrs(old: {
  #   src = super.fetchFromGitHub {
  #     owner = "sigrokproject";
  #     repo = "libsigrok";
  #     rev = "c1f32601c47daec77012fd761611c503bf4cd104";
  #     sha256 = "LFLBvTrD12w+gtaE9v1zd2Z7vp18xeq5Vwk7LE4uDkg=";
  #   };
  #   version = "9999";
  #   name = "libsigrok-9999";
  #   nativeBuildInputs = old.nativeBuildInputs ++ [ super.autoreconfHook ];
  #   firmware = super.fetchurl {
  #     url = "https://sigrok.org/download/binary/sigrok-firmware-fx2lafw/sigrok-firmware-fx2lafw-bin-0.1.7.tar.gz";
  #     sha256 = "1br32wfkbyg3v0bh5smwvn1wbkwmlscqvz2vdlx7irs9al3zsxn8";
  #   };
  # });

  # pulseview = (super.libsForQt5.callPackage
  #   ../../../nixpkgs/pkgs/applications/science/electronics/pulseview { }
  # ).overrideAttrs(old: {
  #   src = super.fetchFromGitHub {
  #     owner = "sigrokproject";
  #     repo = "pulseview";
  #     rev = "7e5c8396624b94ad0c92382cfe3652c07800592d";
  #     sha256 = "W3Tvi+zN+6zp8FDSFTOPR7F8rtFynwiRFIzhSemqM04=";
  #   };
  #   patches = [];
  #   version = "9999";
  #   name = "pulseview-9999";
  #   nativeBuildInputs = old.nativeBuildInputs ++ [ super.qt5.qttools ];
  # });


  # wivrn = super.wivrn.overrideAttrs(old: {
  #   patches = [ ../../../patches/wivrn/0001-Attempt-to-make-vive-wands-take-precedence-over-ques.patch];
  # });

  redshift = (super.redshift.override { withGeolocation = false; });

  # # Die, networkmanager, die!
  # libproxy = super.libproxy.overrideAttrs(old: {
  #   buildInputs = foldr remove old.buildInputs [ super.networkmanager ];
  # });

  cellwriter = super.callPackage ./cellwriter { };

  easystroke = super.callPackage ./easystroke { };

  libdrc = super.callPackage ./libdrc { };

  simpleserver = super.callPackage ./simpleserver { };

  # mcomix-lite = super.callPackage ./mcomix-lite { };
  # mcomix-lite =
  #   let
  #     version = "c4906bda9ba54045a476a4d6fb88b5b236f913fe";
  #   in super.mcomix.overrideAttrs(old: {
  #     name = "mcomix-lite-${version}";
  #     version = version;
  #     src = super.fetchFromGitHub {
  #       owner = "thermitegod";
  #       repo = "mcomix-lite";
  #       rev = version;
  #     sha256 = "sha256-xbeSKIIfJxBAUZ67jh3FMkts272dt4tIWaAa2cHCMkA=";
  #     fetchSubmodules = true;
  #   };
  #   # meta = {
  #   #   description = "A fork of mcomix, a GTK3 image viewer for comic book archives";
  #   #   longDescription = ''
  #   #     MComix-Lite is a manga/comic reader written in Python3 / Gtk+3

  #   #     MComix-Lite is a fork of MComix3 which is a fork of MComix
  #   #     which is a fork of Comix.

  #   #     The main focus is ONLY on the reader and all other features,
  #   #     i.e. library, have been removed or could be subject to a
  #   #     future removal.
  #   #   '';
  #   #   homepage = https://github.com/thermitegod/mcomix-lite;
  #   # };
  #   });

  # Fix build-issue with CUDA
  basalt-monado = super.basalt-monado.overrideAttrs(old: {
    # TODO: Make this conditional on config.nixpkgs.config.cudaSupport
    buildInputs = old.buildInputs ++ [
        super.cudaPackages.cuda_cudart
        super.cudaPackages.cuda_cccl # <thrust/*>
        super.cudaPackages.libnpp # npp.h
        super.nvidia-optical-flow-sdk
        super.cudaPackages.libcublas # cublas_v2.h
        super.cudaPackages.libcufft # cufft.h
      ];
    nativeBuildInputs = old.nativeBuildInputs ++ [
      super.cudaPackages.cuda_nvcc
    ];
  });

  # # Quick hack/downgrade of darktable to 5.0.1 as 5.2.0 fails to build
  # # for me on leon (issues with libavif and some other issue with
  # # undeclared functions...)
  # darktable = super.darktable.overrideAttrs(old: rec {
  #   buildInputs = foldr remove old.buildInputs [ super.libavif ];
  #   version = "5.0.1";
  #   src = super.fetchurl {
  #     url = "https://github.com/darktable-org/darktable/releases/download/release-${version}/darktable-${version}.tar.xz";
  #     hash = "sha256-SpGNCU67qYPvZ6EMxxXD1+jKc4AJkgqf9l0zQXtt2YQ=";
  #   };
  # });

  monado = super.monado.overrideAttrs(old: {
    # Quick hack to fix build issues on leon with opencv (warning about
    # missing nvcc compiler -> This could probably be fixed like
    # basalt-monado above, but I don't really need opencv support in
    # monado anyway)
    buildInputs = foldr remove old.buildInputs [ super.opencv4 ];

    version = "9999";

    # Also use my own personal branch
    patches = [];
    src = super.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "xantoz";
      repo = "monado";
      rev = "db79552122c75ad0dbbc3762fbd3f6a2b2947b4e";
      hash = "sha256-Rv4H3nGE9WSCoYe7xOdviUDA/HJ5ilL2OEgAmi0x98s=";
    };
  });

  ProjectBabble = super.callPackage ./XR/FT/ProjectBabble { };
  EyeTrackVR = super.callPackage ./XR/FT/EyeTrackVR { };
  ReVision = super.callPackage ./XR/FT/ReVision/package.nix { };

  # Use experimental2 branch for xrizer
  xrizer = super.xrizer.overrideAttrs(old: {
    version = "9999";
    src = super.fetchFromGitHub {
        owner = "RinLovesYou";
        repo = "xrizer";
        rev = "f491eddd0d9839d85dbb773f61bd1096d5b004ef";
        sha256 = "sha256-12M7rkTMbIwNY56Jc36nC08owVSPOr1eBu0xpJxikdw=";
    };
    # useFetchCargoVendor = false;
    # cargoHash = "";
    cargoHash = super.lib.fakeHash;
    # Tests seem to break on this branch, so don't do them
    doCheck = false;
  });

  opencomposite = super.opencomposite.overrideAttrs(old: {
    patches = [ ../../../patches/opencomposite/0001-Always-use-estimated-thumb-curl-on-knuckles.patch ];
  });

  # Use version of lact backported from nixos-unstable
  #
  # TODO: Maybe we could use `lact = pkgs_unstable.lact`?
  # Although my current way of doing it has the benefit of not unneccessarily pulling in nixos-unstable dependencies,
  # since the version-bumped lact seems to build just fine on top of nixos-25.05 deps.
  lact = super.callPackage ./lact/package.nix { };

  # Need to use pkgs_unstable because the rust in nixos 25.05 is too old
  alcom = pkgs_unstable.callPackage ./alcom/package.nix { };
}
