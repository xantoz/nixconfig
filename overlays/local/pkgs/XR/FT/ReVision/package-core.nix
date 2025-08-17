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
  pname = "ReVision.Core";
  version = "0.0.1";

  src = src;

  # sourceRoot = "${src.name}/ReVision.App";

  projectFile = "ReVision.Core/ReVision.Core.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  nugetDeps = ./deps-core.json;

  # runtimeDeps = [ pkgs.zlib ];
}
