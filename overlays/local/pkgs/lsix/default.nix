{ stdenv, lib, fetchFromGitHub, imagemagick }:

stdenv.mkDerivation rec {
  name = "lsix-${version}";
  version = "f218619d247163f3891dca0ff3b81fa539f5d047";

  src = fetchFromGitHub {
    owner = "hackerb9";
    repo = "lsix";
    rev = version;
    sha256 = "0j617g93d5f2svpb2pzshwn54iw19wchypa67lcbjf5v1cdk8w5c";
  };

  buildInputs = [ imagemagick ];

  installPhase = ''
    mkdir -p $out/bin/
    cp lsix $out/bin/lsix
  '';
  fixupPhase = let
    runtimePath = lib.makeBinPath buildInputs;
  in
  ''
    patchShebangs $out/bin/lsix
    sed -i "2 i export PATH=${runtimePath}:\$PATH" $out/bin/lsix
  '';

  meta = with stdenv.lib; {
    description = "Shows thumbnails in terminal using sixel graphics";
    homepage =  https://github.com/hackerb9/lsix;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
