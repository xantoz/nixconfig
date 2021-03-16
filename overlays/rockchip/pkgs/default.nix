self: super:

with super.lib; {

  ffmpeg-v4l2-request = super.ffmpeg.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "Kwiboo";
      repo = "FFmpeg";
      rev = "88ed0434a2030b9b3332c5134dc7e6d979054b45";
      sha256 = "1liyfmpyf02bdrpcz1511dliqwy9n7m2vd0d6h42lhmpz8kgcc88";
    };
    buildInputs = old.buildInputs ++ [ super.libudev super.libv4l ];
    configureFlags = old.configureFlags ++ [ "--enable-libudev" "--enable-libv4l2" "--enable-v4l2-request" ];
  });

  mpv-unwrapped = super.mpv-unwrapped.override {
    ffmpeg = self.ffmpeg-v4l2-request;
  };

}
