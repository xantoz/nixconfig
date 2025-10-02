{ lib
, fetchFromGitHub
, stdenv
, dotnetCorePackages
, pkgs
, makeWrapper
}:

let
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  runtimeLibs = [ pkgs.libusb1 pkgs.hidapi pkgs.zlib ];
in
stdenv.mkDerivation {
  pname = "revision";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "Blue-Doggo";
    repo = "ReVision";
    rev = "master";
    hash = "sha256-+SYHhVRdzB645G0NWtsqZ34DViK5AhY9pJiZmV7BZ1s=";
  };

  nativeBuildInputs = [ dotnet-sdk makeWrapper ];
  buildInputs = runtimeLibs;

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
    runHook preInstall

    outDir=$out/output
    mkdir -p $outDir/Plugins

    # Copy main binary + assets
    cp -r ReVision.App/bin/Debug/net*/linux-x64/* $outDir/

    # Copy plugins into subfolder
    cp ReVision.EyeDevice/bin/Debug/net*/linux-x64/ReVision.EyeDevice.dll $outDir/Plugins/
    cp ReVision.MJPEG/bin/Debug/net*/linux-x64/ReVision.MJPEG.dll $outDir/Plugins/
    cp ReVision.Vive/bin/Debug/net*/linux-x64/ReVision.Vive.dll $outDir/Plugins/

    # Create wrapper that enters the correct directory and sets up library path
    mkdir -p $out/bin
    makeWrapper $outDir/ReVision.App $out/bin/ReVision \
      --set LD_LIBRARY_PATH "${lib.makeLibraryPath runtimeLibs}" \
      --chdir $outDir

    runHook postInstall
  '';

  meta = {
    description = "ReVision application with plugins and wrapper";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
