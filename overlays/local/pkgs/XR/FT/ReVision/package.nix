{
  src
, lib
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, stdenv
, pkgs
}:

buildDotnetModule {
  pname = "ReVision";
  version = "0.0.1";

  src = src;

  projectFile = "ReVision.sln";
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  nugetDeps = ./deps.json;

  nugetConfig = ./nuget.config;

  # # Needed DLLs used by the app
  # postInstall = ''
  #   cp $src/ReVision.App/hidapi.dll $out/
  #   cp $src/ReVision.App/libusb-1.0.dll $out/
  # '';

  runtimeDeps = [ pkgs.zlib ];

  # installPhase = ''
  #   mkdir -p $out/bin
  #   cp -r $buildOutput/* $out/
  #   find $buildOutput -type f -executable -exec cp {} $out/bin \;
  # '';
}
