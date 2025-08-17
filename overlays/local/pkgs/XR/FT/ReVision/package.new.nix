{ lib
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, stdenv
, pkgs
}:

let
  src = fetchFromGitHub {
    owner = "Blue-Doggo";
    repo = "ReVision";
    rev = "master";
    hash = "sha256-+SYHhVRdzB645G0NWtsqZ34DViK5AhY9pJiZmV7BZ1s=";
  };

  slnfile = buildDotnetModule {
    pname = "revision";
    version = "0.0.1";

    src = src;

    projectFile = "ReVision.sln";
    dotnet-sdk = dotnetCorePackages.sdk_9_0;
    dotnet-runtime = dotnetCorePackages.runtime_9_0;

    # nugetConfig = ./nuget.config;

    # Needed DLLs used by the app
    postInstall = ''
      cp $src/ReVision.App/hidapi.dll $out/
      cp $src/ReVision.App/libusb-1.0.dll $out/
    '';

    runtimeDeps = [ pkgs.zlib ];

    installPhase = ''
      mkdir -p $out/bin
      cp -r $buildOutput/* $out/
      find $buildOutput -type f -executable -exec cp {} $out/bin \;
    '';
  };

  ReVision_App = buildDotnetModule {
    pname = "ReVision_App";
    version = "0.0.1";

    src = src;

    sourceRoot = "${src.name}/ReVision.App";

    # nugetConfig = ./nuget.config;


    projectFile = "ReVision.App.csproj";
    dotnet-sdk = dotnetCorePackages.sdk_9_0;
    dotnet-runtime = dotnetCorePackages.runtime_9_0;
  };
in
s
