{ lib
, fetchFromGitHub
, dotnetCorePackages
, stdenv
, pkgs
}:

let
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
in
stdenv.mkDerivation {
  pname = "revision";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "Blue-Doggo";
    repo = "ReVision";
    rev = "d7413956d23613db7106620ef3ab5b22173affdd";
    sha256 = "0000000000000000000000000000000000000000000000000000"; # Replace
  };

  nativeBuildInputs = [ dotnet-sdk ];

  buildPhase = ''
    runHook preBuild

    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

    dotnet build --runtime linux-x64 ReVision.App/
    dotnet build --runtime linux-x64 ReVision.Vive/
    dotnet build --runtime linux-x64 ReVision.Core/
    dotnet build --runtime linux-x64 ReVision.EyeDevice/
    dotnet build --runtime linux-x64 ReVision.MJPEG/

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/output
    cp -r ReVision.App/bin/Debug/net*/linux-x64/* $out/output/

    mkdir -p $out/output/Plugins
    cp ReVision.EyeDevice/bin/Debug/net*/linux-x64/ReVision.EyeDevice.dll $out/output/Plugins
    cp ReVision.MJPEG/bin/Debug/net*/linux-x64/ReVision.MJPEG.dll $out/output/Plugins
    cp ReVision.Vive/bin/Debug/net*/linux-x64/ReVision.Vive.dll $out/output/Plugins
  '';

  # Optional: include runtime dependencies
  runtimeDeps = [ pkgs.zlib ];

  meta = {
    description = "ReVision application with plugins";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
