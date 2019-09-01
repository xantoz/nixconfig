{ stdenv, x264,
  fetchgit,
  fetchFromGitHub,
  # ffmpeg_2,
  ffmpeg_4,
  yasm, perl, pkg-config,
  mesa_noglu, libGLU_combined, glew, SDL }:

let
  custom_x264 = x264.overrideAttrs(old: {
    src = fetchgit {
      url = "https://bitbucket.org/memahaxx/drc-x264/";
      rev = "998dacc19ff5b56d86f4b185011b89d2e80ab5e7";
      sha256 = "1gdz5bfzk657ls8n5w588yshz7vv5pxv1spiq8lqax3sby7jmq83";
      fetchSubmodules = false;
    };

    nativeBuildInputs = old.nativeBuildInputs ++ [ yasm perl ];

    name = "drc-x264";
    version = "drc-x264-9999";
  });
in stdenv.mkDerivation {
  name = "libdrc";
  version = "libdrc-9999";

  # TODO: try? https://github.com/rolandoislas/libdrc/commits/master

  src = fetchFromGitHub  {
    owner = "rolandoislas";
    repo = "libdrc";
    rev = "eb53344e4cd68500ca050c14c182ee3173c08848";
    sha256 = "103kamqnilqa0k9pif45pq38v6lq2mq06n5x4kzyccksm1hk1w42";
  };

  # src = fetchgit {
  #   url = "https://bitbucket.org/memahaxx/libdrc";
  #   rev = "5c26ba6d45920c8609466d00994e2bb313325ba9";
  #   sha256 = "06rpikh8c125zcdq9b3xfdqh8f4vcqll4i6shhhgnkvn5w2hv6qf";
  #   fetchSubmodules = false;
  # };

  preConfigure = ''
    sed -i -e 's|^#!.*|#!${stdenv.shell}|' ./configure
    sed -i -e '/#include <vector>/a #include <functional>' include/drc/streamer.h
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ffmpeg_4 custom_x264 mesa_noglu libGLU_combined glew SDL ];
}
