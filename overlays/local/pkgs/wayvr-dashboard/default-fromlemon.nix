{
, lib
, rustPlatform
, buildNpmPackage
, alsa-lib
, autoPatchelfHook
, curl
, dbus
, glib
, gtk3
, librsvg
, libsoup_2_4
, openssl
, pkg-config
, webkitgtk_4_1
, wget
, wrapGAppsHook3
}:
rustPlatform.buildRustPackage rec {
  pname = "wayvr-dashboard";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "olekolek1000";
    repo = "wayvr-dashboard";
    hash = "sha256-lcL+igZdZB5GM2bZTZaR0sRy78Jx4kv58P+dBhrN7Ac=";
    rev = "a927e7a20268c521e508c4a9521b12530f6e8422";
  };


  sourceRoot = "${src.name}/src-tauri";

  useFetchCargoVendor = true;
  cargoHash = "sha256-2Rz51zr6O8eCez1UnjkD4FYjdkhmjS/0SvfHV90og1k=";

  frontend = buildNpmPackage {
    inherit version src;
    pname = "wayvr-dashboard-ui";

    npmDepsHash = "sha256-W2X9g0LFIgkLbZBdr4OqodeN7U/h3nVfl3mKV9dsZTg=";

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    dontAutoPatchelf = true;

    preBuild = ''
      autoPatchelf node_modules/sass-embedded-linux-x64/dart-sass/src/dart
    '';

    postBuild = ''
      cp -r dist/ $out
    '';
  };

  postPatch = ''xo
    substituteInPlace tauri.conf.json \
      --replace-warn '"frontendDist": "../dist"' '"frontendDist": "${frontend}"'
    substituteInPlace tauri.conf.json \
      --replace-warn '"npm run build"' '""'
  '';

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    curl
    dbus
    glib
    gtk3
    librsvg
    libsoup_2_4
    openssl
    webkitgtk_4_1
    wget
  ];

  doCheck = false;

  meta = with lib; {
    description = "A desktop environment and launcher for VR (wlx-overlay-s addon)";
    homepage = "https://github.com/olekolek1000/wayvr-dashboard";
    changelog = "https://github.com/olekolek1000/wayvr-dashboard/releases/";
    license = licenses.mit;
    maintainers = with maintainers; [ passivelemon ];
    platforms = platforms.linux;
    mainProgram = "wayvr_dashboard";
  };
}
