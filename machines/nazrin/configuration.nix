# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  # NOTE: no profiles/wireless.nix because we use networkmanager
  imports =
    [
      ./hardware-configuration.nix
      ../../profiles/core.nix
      ../../profiles/graphical.nix
      ../../profiles/input-methods.nix
      ../../profiles/bluetooth.nix
      ../../profiles/laptop.nix
      ../../profiles/sway.nix
      ../../profiles/printing-and-scanning.nix
      ../../home/home-manager/nixos
    ];
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };
  services.resolved.enable = true; # Use resolved together with networkmanager (Enabling this should set networking.networkmanager.dns to "systemd-resolved")

  home-manager.users.tewi_inaba = import ../../home/home.nazrin.nix;

  environment.systemPackages = with pkgs; let
    my_xbattbar = haskellPackages.xbattbar.overrideAttrs(old: { patches = [ ../../patches/haskellPackages.xbattbar/xbattbar-0.2.patch ]; } );
  in [
    wirelesstools
    iw
    iwgtk

    my_xbattbar
    btrfs-progs
    libva-utils
    libva1
    dmidecode
    units
  ];

  # programs.steam.enable = true;

  # boot.kernelPatches = [{
  #   name = "atari-partitioning";
  #   patch = null;
  #   extraConfig = ''
  #   ATARI_PARTITION y
  #   '';
  # }];

  ## Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };

  boot.initrd.secrets = {
    "keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
  };

  boot.initrd.luks.devices = {
    root-decrypt = {
      device = "/dev/disk/by-uuid/4ff87337-7366-4329-bed1-e30291b4878c";
      preLVM = true;
      keyFile = "/keyfile0.bin";
      allowDiscards = true;
    };
  };

  boot.initrd.systemd.enable = true;

  # boot.tmpOnTmpfs = true;

  networking.hostName = "nazrin"; # Define your hostname.

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8000 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  networking.enableB43Firmware = true;

#  services.xserver.videoDrivers = [ "intel" ];
#  services.xserver.deviceSection = ''
#    Option "TearFree" "on"
#  '';

  # TODO: set default scheduler for SSD:s to deadline

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Order the sound cards using ancient magic
  boot.extraModprobeConfig = ''
    # PCH
    options snd-hda-intel index=0 model=auto vid=8086 pid=9c20
    # HDMI
    options snd-hda-intel index=1 model=auto vid=8086 pid=0a0c
  '';

  # Set up ZRAM swap devices
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.mediakeys = {
    enable = true;
  };

  users.users.tewi_inaba = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "systemd-journal" "audio" "video" "render" "dialout" "lp" "scanner" "cdrom" "floppy" "networkmanager" ];
    packages = with pkgs; [
      wineWowPackages.full
      dolphin-emu-beta
      # discord

      cargo
      rustc

      # # Temporary addition for rust_image_fiddler (TODO: start using direnv?)
      # rustfmt
      # rust-analyzer
      # clippy
      # cmake
      # pkg-config
      # fltk
      # pango
      # xorg.libXft
    ];
  };

  # Enable portals and stuff?
  xdg.portal = {
    enable = true;
    config = {
      sway = {
        default = lib.mkForce "lxqt"; # Use lxqt over GTK on sway as the fallback
        # TODO: Use xdg-desktop-portal-luminous over xdg-desktop-wlr for nicer screenshotting? (xdg-desktop-portal-luminous currently not available in nixpkgs)
        # "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce "luminous";
        # "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce "luminous";
      };
      ratpoison = {
        default = "lxqt";
      };
    };
    extraPortals = with pkgs; [
      lxqt.xdg-desktop-portal-lxqt
      # xdg-desktop-portal-hyprland
      # pantheon.xdg-desktop-portal-pantheon
      # xdg-desktop-portal-kde
      # xdg-desktop-portal-cosmic
      # xdg-desktop-portal-xapp
      # xdg-desktop-portal-lxqt
      # xdg-desktop-portal-shana
    ];

    # Some NixOS-specific fix for xdg-open or so?
    xdgOpenUsePortal = true;
  };

  # have udisks2 because hyper-modern stuff might want to d-bus against it or something
  services.udisks2 = {
    enable = true;
    mountOnMedia = false;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.05"; # Did you read the comment?
}
