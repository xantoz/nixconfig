{ stdenv, fetchFromGitHub,
  meson, ninja, pkgconfig,
  vulkan-headers, vulkan-loader, shaderc, lcms2 }:

stdenv.mkDerivation rec {
  name = "libplacebo-${version}";
  version = "d1b796875e61af1c54b83180a1d31dd41c52b09d";

  src = fetchFromGitHub {
    owner = "haasn";
    repo = "libplacebo";
    rev = version;
    sha256 = "0m2r35smzcxbil82sr68y6fl8w06p7idgd594w0w1i585q28bcjl";
  };

  nativeBuildInputs = [ pkgconfig meson ninja ];

  propagatedBuildInputs = [
    vulkan-headers
    vulkan-loader
    shaderc
    lcms2
  ];

  mesonFlags = [
    "-Dvulkan=enabled" "-Dshaderc=enabled" "-Dlcms=enabled"
  ];

  meta = with stdenv.lib; {
    description = "libplacebo";
    homepage =  https://github.com/haasn/libplacebo;
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
