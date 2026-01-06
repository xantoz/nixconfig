{
  cargo-about,
  cargo-tauri,
  fetchFromGitHub,
  fetchNpmDeps,
  glib-networking,
  lib,
  libsoup_3,
  makeBinaryWrapper,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  wrapGAppsHook4,
  webkitgtk_4_1,
}:
let
  pname = "alcom";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "vrc-get";
    repo = "vrc-get";
    tag = "gui-v${version}";
    fetchSubmodules = true;
    hash = "sha256-I3eO6LxOhoxkoBbyJPedNssUPOS4XCY16LA3m6siiw8=";
  };

  subdir = "vrc-get-gui";
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  postPatch = ''
    sed -i -e 's/^createUpdaterArtifacts = "v1Compatible".*$//' vrc-get-gui/Tauri.toml
  '';

  nativeBuildInputs = [
    cargo-about
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook
    wrapGAppsHook4
    pkg-config
  ];

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      glib-networking
      libsoup_3
      makeBinaryWrapper
      webkitgtk_4_1
    ];

  useFetchCargoVendor = true;
  cargoHash = "sha256-ePStRmFjixkLssT7V6Spg9lRZEbojWWdkH39evWiiFg=";
  buildAndTestSubdir = subdir;

  npmDeps = fetchNpmDeps {
    inherit src;
    sourceRoot = "${src.name}/${subdir}";
    hash = "sha256-fVWtk89fhrbiiPVJEGgN6OAZ78otyyaxH2YYxU+tl+s=";
  };
  npmRoot = subdir;

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/ALCOM \
      --set APPIMAGE ALCOM
  '';

  meta = {
    description = "Experimental GUI application to manage VRChat Unity Projects";
    homepage = "https://github.com/vrc-get/vrc-get";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Scrumplex ];
    broken = stdenv.hostPlatform.isDarwin;
    mainProgram = "alcom";
  };
}
