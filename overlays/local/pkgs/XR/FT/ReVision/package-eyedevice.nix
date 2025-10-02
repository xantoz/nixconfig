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
  pname = "ReVision.EyeDevice";
  version = "0.0.1";

  src = src;

  # sourceRoot = "${src.name}/ReVision.App";

  projectFile = "ReVision.EyeDevice/ReVision.EyeDevice.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  nugetDeps = ./. + "/deps-EyeDevice.json";

  buildInput  =  [ pkgs.libusb1 pkgs.hidapi ];

  runtimeDeps = [ pkgs.zlib ];
}
