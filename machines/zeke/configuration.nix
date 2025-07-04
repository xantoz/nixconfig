# 15-inch Dell laptop I use at work (at least at the time of writing, maybe this config will apply to future work machines as well?)

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # NOTE: no profiles/wireless.nix because we use networkmanager on zeke
  imports = [
      ./hardware-configuration.nix
      ../../profiles/core.nix
      ../../profiles/graphical-kde.nix
      ../../profiles/input-methods-ibus.nix
      ../../profiles/bluetooth.nix
      ../../profiles/laptop.nix
      # ../../profiles/sway.nix
      ../../home/home-manager/nixos
    ];

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

  boot.kernelParams = [
    # Somewhat of a fix for modern insomniac laptops. At least the ones that actuall support S3 sleep
    "mem_sleep_default=deep"
  ];

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv7l-linux"
  ];
  # remote cross-compile for sumireko
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8SxDuqn+vUfXgxzKx91U0auCiWU3kT/wmqiK5uqUme akindestam@sumireko"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtYDCEy09OUvuD6gZLinAcPuUuGYPPi18a5QXAcMF1l sumireko-root"
  ];

  home-manager.users.akindestam = import ../../home/home.zeke.nix;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-ca2251ba-8e8e-43ff-b9a4-21b6a8dd5e7e".device = "/dev/disk/by-uuid/ca2251ba-8e8e-43ff-b9a4-21b6a8dd5e7e";
  boot.initrd.luks.devices."luks-ca2251ba-8e8e-43ff-b9a4-21b6a8dd5e7e".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "zeke"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable flatpak for installing flatpaks because sometimes maybe it might make sense?
  services.flatpak.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.akindestam = {
    isNormalUser = true;
    uid = 1000;
    description = "Anton Kindestam";
    extraGroups = [ "networkmanager" "wheel" "systemd-journal" "audio" "video" "render" "dialout" "lp" "cdrom" "floppy" "pipewire" ];
    packages = with pkgs; [
      # kalendar
      # kmail
      # kontact
      #blender
      # kate
      # thunderbird

      xsane
      #darktable
      #ansel
      #vkdt
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # CUDA support in Blender and more (See: https://discourse.nixos.org/t/how-to-get-cuda-working-in-blender/5918/12)
  nixpkgs.config.cudaSupport = true;

  # Add the nix-community cachix. This should hopefully give me binary cache for packages built with cuda enabled, so I don't have to rebuild blender all the time
  # TODO: Migrate zeke to use the xz.nvidia module to configure nvidia stuff, then this setting will come as part of that module
  nix.settings.substituters = [
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;   # Optionally, you may need to select the appropriate driver version for your specific GPU.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;
  hardware.nvidia.modesetting.enable = true;   # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
  hardware.nvidia.open = false; # zeke is RTX 1050 => not turing => can't use the open kernel module
  hardware.nvidia.prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true; # Gives us the nvidia-offload convenience script
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall =
    let ports = [ 22 5900 5906 8000 8080 8888 ];
    in {
      allowedTCPPorts = ports;
      allowedUDPPorts = ports;
    };
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
