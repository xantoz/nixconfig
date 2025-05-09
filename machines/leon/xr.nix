# TODO: Now we should try and split the xr profile out eventually I think.
#       Make it a module, since we need to at least choose between wivrn and monado
#
#       Bonus points if I make a module that gives me some scripts to choose between wivrn and monado using a CLI script, and same for opencomposite and xrizer.
#       In fact having it be a CLI tool for the choosing makes it easier, since we won't need home-manager to write in ~/.config/openvr and ~/.config/openxr I think?
#       One problem though: services.{wivrn,monado}.defaultRuntime does something in /etc/xdg/openxr/1/active_runtime.json. But I think ~/.config/openxr/1/active_runtime.json takes precedence?


{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays =
    let
      nixpkgs-xr = import (builtins.fetchGit {
        url = "https://github.com/nix-community/nixpkgs-xr.git";
        rev = "bf697f884e4eb02f1f190d4a5dd7b012ee35d855";
      });
    in [
      nixpkgs-xr.overlays.default
    ];

  environment.systemPackages = with pkgs; [
    # VR related
    opencomposite
    xrgears
    wlx-overlay-s
    motoc
    (writeShellScriptBin "wivrn-dashboard-trackers" ''
       env ADB_LIBUSB=0 WIVRN_USE_STEAMVR_LH=1 LH_DISCOVER_WAIT_MS=6000 steam-run wivrn-dashboard
    '')
    wayvr-dashboard
  ];

  services.monado = {
    enable = true;
    # defaultRuntime = true; # Register as default OpenXR runtime
  };
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    XRT_COMPOSITOR_DEFAULT_FRAMERATE="90";
    U_PACING_APP_US_MIN_FRAME_PERIOD = "5";
    U_PACING_COMP_PRESENT_TO_DISPLAY_OFFSET="10";
    XRT_COMPOSITOR_SCALE_PERCENTAGE = "100";
    # XRT_COMPOSITOR_FORCE_NVIDIA = "1";
    # XRT_COMPOSITOR_FORCE_NVIDIA_DISPLAY = "1";
    WMR_HANDTRACKING = "0";
    LH_HANDTRACKING = "0";
  };
  # programs.envision = {
  #   enable = true;
  #   openFirewall = true;
  # };
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };
  programs.adb.enable = true;   # Add ADB for WiVRn etc. to quest 2
  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
  };

  # More generic game related things that ended up here anyway

  programs.gamemode.enable = true;

  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    # But this proton-ge-rtsp-bin (from nixpkgs-xr overlay) is kinda of tangetially XR related (better video playback in VRC)
    extraCompatPackages = [
      pkgs.proton-ge-rtsp-bin
      pkgs.steam-play-none
    ];
    package = pkgs.steam.override {
      extraEnv = {
        MANGOHUD = true;
        # OBS_VKCAPTURE = true;
      };
    };
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
}
