# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../profiles/core.nix
      ../../profiles/graphical-kde.nix
      ../../profiles/input-methods.nix
      ../../profiles/bluetooth.nix
      ../../profiles/laptop.nix
      # ../../profiles/sway.nix
      ../../profiles/printing-and-scanning.nix
      ../../home/home-manager/nixos
    ];

  home-manager = {
    users.tewi_inaba = import ../../home/home.leon.nix;
    backupFileExtension = "back";
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nixpkgs.overlays =
    let
      nixpkgs-xr = import (builtins.fetchGit {
        url = "https://github.com/nix-community/nixpkgs-xr.git";
        rev = "c47dd7d908997c71b9c0ebfe177f30dff5ccce44";
      });
    in [
      nixpkgs-xr.overlays.default
    ];

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

  programs.gamemode.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [
    {
      name = "amdgpu-ignore-ctx-privileges";
      patch = pkgs.fetchpatch {
        name = "cap_sys_nice_begone.patch";
        url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
        hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
      };
    }
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


  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  programs.adb.enable = true;   # Add ADB for WiVRn etc. to quest 2
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tewi_inaba = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "adbusers" "audio" "video" "kvm" "render" "input" "gamemode" "dialout" ];
    packages = with pkgs; [
      kalendar
      kmail
      kontact
      blender
      # kate
      # thunderbird

      alcom
      unityhub

      xsane
      darktable
      #ansel
      #vkdt

      obs-studio
      mcomix
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # CUDA support in Blender and more (See: https://discourse.nixos.org/t/how-to-get-cuda-working-in-blender/5918/12)




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
    nvtop                       # GPU stats like htop

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

  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-rtsp-bin pkgs.steam-play-none ];
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
  services.wivrn = {
    enable = true;
    openFirewall = true;
    defaultRuntime = true;
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


  services.xserver.videoDrivers = [
   "amdgpu"
    "nvidia"
  ];

  xz.nvidia = {
    enable = true;
    rmIntrLockingMode = true;
    # gspMode = "no-without-modesetting";
    # disableOthers = true;
    #gspMode = "no-without-simpledrm";
    #disableOthers = true;
    gspMode = "yes-with-open-driver";
    disableOthers = false;
   prime = {
     offload.enable = true;
     offload.enableOffloadCmd = true; # Gives us the nvidia-offload convenience script
     amdgpuBusId = "PCI:34:0:0";
     nvidiaBusId = "PCI:1:0:0";
   };
  };

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
