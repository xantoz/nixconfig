# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../profiles/core.nix
      ../../profiles/graphical.nix
      ../../profiles/input-methods.nix
      ../../profiles/wireless.nix
      ../../profiles/bluetooth.nix
      ../../profiles/laptop.nix
      ../../home/home-manager/nixos
    ];

  home-manager.users.tewi_inaba = import ../../home/home.nazrin.nix;

  environment.systemPackages = with pkgs; let
    my_xbattbar = haskellPackages.xbattbar.overrideAttrs(old: { patches = [ ../../patches/haskellPackages.xbattbar/xbattbar-0.2.patch ]; } );
  in [
    my_xbattbar
    btrfsProgs
    libva-utils
    libva1
    dmidecode
    units

    # test
    sway
    swaybg
    swaylock
    swayidle
    xwayland
    mako

    dolphinEmuMaster
  ];

  ## Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    version = 2;
    efiSupport = true;
    enableCryptodisk = true;
    extraInitrd = /boot/initrd.keys.gz;
  };

  boot.initrd.luks.devices = [{
      name = "root-decrypt";
      device = "/dev/disk/by-uuid/4ff87337-7366-4329-bed1-e30291b4878c";
      preLVM = true;
      keyFile = "/keyfile0.bin";
      allowDiscards = true;
    }
  ];

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

  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''
    Option "TearFree" "on"
  '';

  # TODO: set default scheduler for SSD:s to deadline

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Order the sound cards using ancient magic
  boot.extraModprobeConfig = ''
    # PCH
    options snd-hda-intel index=0 model=auto vid=8086 pid=9c20
    # HDMI
    options snd-hda-intel index=1 model=auto vid=8086 pid=0a0c
  '';

  # TODO: modularize
  services.triggerhappy =
    let
      backlightPath = "/sys/class/backlight/intel_backlight";
      backlightStep = "28";         # TODO: really want to be able to specify this in percent
      brightnessUpCmd = pkgs.writeShellScript "brightness_up" ''
        max_brightness="$(cat ${backlightPath}/max_brightness)"
        x=$(( $(cat "${backlightPath}/brightness") + ${backlightStep} ))
        x=$(( (x > $max_brightness) ? $max_brightness : x ))
        echo "$x" > "${backlightPath}/brightness"
      '';
      brightnessDownCmd = pkgs.writeShellScript "brightness_down" ''
        x=$(( $(cat "${backlightPath}/brightness") - ${backlightStep} ));
        x=$(( (x < 0) ? 0 : x ));
        echo "$x" > "${backlightPath}/brightness"
      '';
      mute       = "${pkgs.pamixer}/bin/pamixer --mute";
      volumeDown = "${pkgs.pamixer}/bin/pamixer --unmute --decrease 2";
      volumeUp   = "${pkgs.pamixer}/bin/pamixer --unmute --increase 2";
      micMute    = "${pkgs.pamixer}/bin/pamixer --default-source --toggle-mute";
    in {
      enable = true;
      user = "tewi_inaba";
      bindings = [
        # "Mute" media key
        {
          keys = [ "MUTE" ];
          event = "press";
          cmd = mute;
        }

        # "Lower Volume" media key
        {
          keys = [ "VOLUMEDOWN" ];
          event = "press";
          cmd = volumeDown;
        }
        {
          keys = [ "VOLUMEDOWN" ];
          event = "hold";
          cmd = volumeDown;
        }

        # "Raise Volume" media key
        {
          keys = [ "VOLUMEUP" ];
          event = "press";
          cmd = volumeUp;
        }
        {
          keys = [ "VOLUMEUP" ];
          event = "hold";
          cmd = volumeUp;
        }

        # "Mic Mute" media key
        {
          keys = [ "MICMUTE" ];
          event = "press";
          cmd = micMute;
        }

        {
          keys = [ "BRIGHTNESSUP" ];
          event = "press";
          cmd = "${brightnessUpCmd}";
        }
        {
          keys = [ "BRIGHTNESSUP" ];
          event = "hold";
          cmd = "${brightnessUpCmd}";
        }

        {
          keys = [ "BRIGHTNESSDOWN" ];
          event = "press";
          cmd = "${brightnessDownCmd}";
        }
        {
          keys = [ "BRIGHTNESSDOWN" ];
          event = "hold";
          cmd = "${brightnessDownCmd}";
        }
      ];
    };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
