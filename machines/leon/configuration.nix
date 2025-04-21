# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./xr.nix
      ./gpu.nix
      ../../profiles/core.nix
      ../../profiles/graphical-kde.nix
      ../../profiles/input-methods.nix
      ../../profiles/bluetooth.nix
      ../../profiles/laptop.nix
      ../../profiles/sway.nix
      ../../profiles/printing-and-scanning.nix
      ../../home/home-manager/nixos
    ];

  home-manager = {
    users.tewi_inaba = import ../../home/home.leon.nix;
    backupFileExtension = "back";
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-7c41bfcf-840d-454f-81e4-79a9bc562401".device = "/dev/disk/by-uuid/7c41bfcf-840d-454f-81e4-79a9bc562401";

  boot.kernelParams = [
    # Somewhat of a fix for modern insomniac laptops. At least the ones that actuall support S3 sleep
    "mem_sleep_default=deep"
    "preempt=full"
  ];

  networking = {
    hostName = "leon";          # Define your hostname.
    networkmanager = {
      enable = true; # Easiest to use and most distros use this by default.
      wifi.backend = "iwd";
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Limit the amount of resources available to the nix daemon
  #
  # In theory this might make `nixos-rebuild switch` be more nice to
  # other programs. OTOH I might simply have better results using
  # something like: systemd-run --scope -p 'CPUAccounting=yes' -p 'AllowedCPUs=0-4' -p 'CPUWeight=50' -p 'MemoryHigh=14G' sh -c 'nixos-rebuild boot 2>&1 | nom'
  systemd.services.nix-daemon.serviceConfig = {
    AllowedCPUs = "0-6";
    MemoryAccounting = "yes";
    MemoryHigh = "8G";
    MemoryMax = "9G";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv7l-linux"
  ];
  # remote cross-compile for sumireko
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8SxDuqn+vUfXgxzKx91U0auCiWU3kT/wmqiK5uqUme akindestam@sumireko"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtYDCEy09OUvuD6gZLinAcPuUuGYPPi18a5QXAcMF1l sumireko-root"
  ];


  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tewi_inaba = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "adbusers" "audio" "video" "kvm" "render" "input" "gamemode" "dialout" "pipewire" ];
    packages = with pkgs; [
      # kalendar
      # kmail
      # kontact
      blender
      # kate
      # thunderbird

      alcom
      unityhub

      xsane
      darktable
      #ansel
      #vkdt

      mcomix

      dolphin-emu
    ];
  };

  # Enable waydroid
  virtualisation.waydroid.enable = true;

  xz.obs = {
    enable = true;
    loopBackSupport = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-3d-effect
      obs-pipewire-audio-capture
      obs-vkcapture
      # obs-nvfbc
      droidcam-obs              # Use a phone as a camera
      # obs-gstreamer
      # obs-vaapi

      # (
      # # Fugly-hack-fix so it builds properly under CUDA
      # obs-backgroundremoval.overrideAttrs(old: {
      #   # TODO: Make this conditional on config.nixpkgs.config.cudaSupport
      #   buildInputs = old.buildInputs ++ [
      #     pkgs.cudaPackages.cuda_cudart
      #     pkgs.cudaPackages.cuda_cccl # <thrust/*>
      #     pkgs.cudaPackages.libnpp # npp.h
      #     pkgs.nvidia-optical-flow-sdk
      #     pkgs.cudaPackages.libcublas # cublas_v2.h
      #     pkgs.cudaPackages.libcufft # cufft.h
      #   ];
      #   nativeBuildInputs = old.nativeBuildInputs ++ [
      #     pkgs.cudaPackages.cuda_nvcc
      #   ];
      # })
      # )
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # emacs
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    zile
    wget
    drm_info
    git
    tig
    tree
    pv
    htop
    mangohud
    nvtopPackages.full                       # GPU stats like htop
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  networking.firewall =
    let ports = [ 22 53 67 68 5900 5906 8000 8080 8888 ];
    in {
      allowedTCPPorts = ports;
      allowedUDPPorts = ports;
    };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
