{
  src
, name

, lib
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, stdenv
, pkgs
}:

buildDotnetModule {
  pname = "ReVision.${name}";
  version = "0.0.1";

  src = src;

  # sourceRoot = "${src.name}/ReVision.App";

  projectFile = "ReVision.${name}/ReVision.${name}.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  nugetDeps = ./. + "/deps-${name}.json";

  # runtimeDeps = [ pkgs.zlib ];
}
