# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../profiles/core.nix
      ../../profiles/graphical.nix
      ../../profiles/input-methods.nix
      ../../profiles/wireless.nix
      ../../profiles/bluetooth.nix
      ../../profiles/laptop.nix
      ../../home/home-manager/nixos
    ];

  home-manager.users.tewi_inaba = import ../../home/home.momiji.nix;

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
      enable = true;
      efiSupport = false;
      device = "/dev/disk/by-id/ata-ST9500423AS_S2V0JH08";
      enableCryptodisk = true;
      extraInitrd = /boot/initrd.keys.gz;
  };

  boot.initrd.luks.devices = [{
    name = "root-decrypt";
    device = "/dev/disk/by-uuid/746ee3c5-25b7-42e8-8ae4-11a90123257f";
    preLVM = true;
    keyFile = "/keyfile0.bin";
    allowDiscards = true;
  }];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "momiji"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  #time.timeZone = "Europe/Stockholm";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  services.xserver = {
      videoDrivers = [ "intel" ];
      deviceSection = ''
        Option "TearFree" "on"
      '';
      wacom.enable = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  boot.tmpOnTmpfs = true;

  programs.cellwriter = {
    enable = true;
    profile = ../../config/cellwriter/profile;
  };

  environment.systemPackages = with pkgs; [
    easystroke                  # TODO: module for this when you are somewhat more ready to freeze the config
    xournal
    # xournalpp
    #wineUnstable
    wineFull
  ];

  users.users.tewi_inaba = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "systemd-journal" "audio" "video" "render" "dialout" "lp" "cdrom" "floppy" "pipewire" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
