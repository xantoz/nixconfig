{ stdenv, fetchFromGitHub,
  meson, ninja, pkgconfig,
  vulkan-headers, vulkan-loader, shaderc, lcms2 }:

stdenv.mkDerivation rec {
  name = "libplacebo-${version}";
  version = "02c0219529c28a04996b264c04e481f01cc274e5";

  src = fetchFromGitHub {
    owner = "haasn";
    repo = "libplacebo";
    rev = version;
    sha256 = "13wa2z06zhqngpmgray92vxxqgs4w3ibl3z7y468l90s5fp8s8yn";
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
    license = licenses.lgpl21plus;
    platforms = platforms.linux;
  };
}
