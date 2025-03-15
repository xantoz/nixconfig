{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays =
    let
      nixpkgs-xr = import (builtins.fetchGit {
        url = "https://github.com/nix-community/nixpkgs-xr.git";
        rev = "99383a8dda24c47f13418c505937338cbb05194e";
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
