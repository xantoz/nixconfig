{ lib,
  stdenv,
  rustPlatform,
  fetchNpmDeps,
  cargo-tauri,
  glib-networking,
  nodejs_latest,
  #pnpm_9,
  npmHooks,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook3,
  pulseaudio,
  xdg-utils,
  fetchFromGitHub,
  libayatana-appindicator,
  librsvg,
  alsa-lib,
  gtk3,
  glib,
  libsoup_2_4,
  autoPatchelfHook,
  ...
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

  # Fetch npm dependencies
  npmDeps = fetchNpmDeps {
    name = "${pname}-npm-deps-${version}";
    inherit src;
    hash = "sha256-W2X9g0LFIgkLbZBdr4OqodeN7U/h3nVfl3mKV9dsZTg=";
  };

  useFetchCargoVendor = true;
  # Cargo.lock file (required for reproducible builds)
  cargoHash = "sha256-Hfl5zIQ4IgDp4SQnwIfekDkiZ8vs2N8CzjlVDc7W4VM=";

  # Use the cargo-tauri hook
  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs_latest
    #pnpm_9.configHook
    npmHooks.npmConfigHook
    pkg-config
    wrapGAppsHook3
    autoPatchelfHook
  ];


  dontAutoPatchelf = true;
  preBuild = ''
    autoPatchelf node_modules/sass-embedded-linux-x64/dart-sass/src/dart
  '';

  # Runtime dependencies
  buildInputs = [
    openssl
    librsvg
    libsoup_2_4
    gtk3
    glib
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    webkitgtk_4_1
    libayatana-appindicator
    alsa-lib
  ];

  # SET the Tauri source directory
  cargoRoot = "src-tauri";

  # Build and test in the Tauri directory
  buildAndTestSubdir = cargoRoot;

  # Optional: Tauri-specific build flags
  #tauriBuildFlags = [ "--release" ]; # Build in release mode
  #tauriBundleType = "appimage"; # Bundle type (e.g., "app", "updater")

  # # Environment variables
  # OPENSSL_DIR = "${openssl.dev}";

  # installPhase = ''
  #   mkdir -p $out/bin
  #   cp -r src-tauri/target/release/wayvr_dashboard $out/bin/

  #   # Wrap the binary for pactl and xdg-open
  #   wrapProgram $out/bin/wayvr_dashboard --prefix PATH : ${lib.makeBinPath [ pulseaudio xdg-utils ]}
  # '';

  postInstall = ''
    wrapProgram $out/bin/wayvr_dashboard --prefix PATH : ${lib.makeBinPath [ pulseaudio xdg-utils ]}
  '';


  # Optional: Disable Tauri build or install hooks if needed
  # dontTauriBuild = true;
  # dontTauriInstall = true;
}
