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
  version = "0.2.8";

  src = fetchFromGitHub {
    owner = "olekolek1000";
    repo = "wayvr-dashboard";
    hash = "sha256-VqHVTPOCQWzNM7X++FXOkdc0uNqtXGsZ3yYgf3Hg1k0=";
    rev = "cdd5982da9497509cb5fbb5c499289e506cf2499"; # 0.2.8
  };


  sourceRoot = "${src.name}/src-tauri";

  useFetchCargoVendor = true;
  cargoHash = "sha256-Hfl5zIQ4IgDp4SQnwIfekDkiZ8vs2N8CzjlVDc7W4VM=";

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
