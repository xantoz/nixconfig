self: super:

with super.lib; {

  ffmpeg-v4l2-request = super.ffmpeg.overrideAttrs(old: {
    src = super.fetchFromGitHub {
      owner = "Kwiboo";
      repo = "FFmpeg";
      rev = "9236ad7c3e4048f18c4cb79eafbe2a89085de381";
      sha256 = "0lv1cvh6fnwqbxnxpkpsmny4q24hhbqykj22q0npxnzxh165882m";
    };
    buildInputs = old.buildInputs ++ [ super.libudev super.libv4l ];
    configureFlags = old.configureFlags ++ [ "--enable-libudev" "--enable-libv4l2" "--enable-v4l2-request" ];
  });

  mpv-unwrapped = super.mpv-unwrapped.override {
    ffmpeg = self.ffmpeg-v4l2-request;
  };

}
