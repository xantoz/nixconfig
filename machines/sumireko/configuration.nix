{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../profiles/core.nix
    ../../profiles/graphical.nix
    ../../profiles/input-methods.nix
    ../../profiles/wireless.nix
    ../../profiles/bluetooth.nix
    ../../profiles/laptop.nix
    ../../profiles/sway.nix
    ../../home/home-manager/nixos
  ];

  # nixpkgs.overlays = [
  #   (import ../../overlays/rockchip/pkgs/default.nix)
  # ];
  # nix.nixPath = [
  #   "nixpkgs-overlays=/etc/nixos/overlays/rockchip"
  # ];

  home-manager.users.tewi_inaba = import ../../home/home.sumireko.nix;

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "sumireko";

  services.xserver.videoDrivers = [ "modesetting" ];

  # Set up ZRAM swap devices
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  services.mediakeys = {
    enable = true;
    backlightPath = "/sys/class/backlight/edp-backlight";
  };

  environment.systemPackages = with pkgs; [
    ardour

    # try getting the icons of the home manager services to work this way??
    pasystray
    blueman

    remmina

    nyxt
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  users.users.tewi_inaba = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "systemd-journal" "audio" "video" "render" "dialout" "lp" "cdrom" "floppy" ];
  };
}
