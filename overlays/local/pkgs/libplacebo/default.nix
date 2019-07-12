{ stdenv, fetchFromGitHub,
  meson, ninja, pkgconfig,
  vulkan-headers, vulkan-loader, shaderc, glslang, lcms2 }:

stdenv.mkDerivation rec {
  name = "libplacebo-${version}";
  version = "22a99191fec9ac14bcc26db72e24ccedad51c027";

  src = fetchFromGitHub {
    owner = "haasn";
    repo = "libplacebo";
    rev = version;
    sha256 = "18mplzzr5hz19lcjw2nrypq81ccargj7ydr18zir2afmff4r9s0w";
  };

  nativeBuildInputs = [ pkgconfig meson ninja ];

  buildInputs = [ shaderc glslang lcms2 ];

  propagatedBuildInputs = [
    vulkan-headers
    vulkan-loader
  ];

  mesonFlags = [
    "-Dvulkan=enabled" "-Dshaderc=enabled" "-Dlcms=enabled"
  ];

  meta = with stdenv.lib; {
    description = "Reusable library for GPU-accelerated image processing primitives";
    homepage =  https://github.com/haasn/libplacebo;
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
