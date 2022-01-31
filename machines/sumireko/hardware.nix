{ config, pkgs, lib, ... }:

let
  uboot = pkgs.uBootPinebookProExternalFirst;
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ./wip-pinebook-pro/pinebook_pro.nix
  ];

  hardware.enableRedistributableFirmware = true;

  nix.maxJobs = lib.mkDefault 2; # Using more than two threads tends to overload the poor thing (mostly a RAM issue)
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # TODO: replace swap file with a swap partition
  swapDevices = [ { device = "/swapfile"; } ];
  # boot.resumeDevice = "/dev/mmcblk0p1"
  # Gotten with "filefrag -v /swapfile | awk '{if($1=="0:"){print $4}}'"
  # boot.kernelParams = [ "resume_offset=4761600" ];
  boot.kernelParams = [
    "resume=/dev/mmcblk0p1"
    "resume_offset=4761600"

    # "cma=32M"
    "console=ttyS2,1500000n8"
    "earlycon=uart8250,mmio32,0xff1a0000" "earlyprintk"

    # The last console parameter will be where the boot process will print
    # its messages. Comment or move abot ttyS2 for better serial debugging.
    "console=tty0"

  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.consoleLogLevel = lib.mkDefault 7;

  fileSystems."/" = {
    # TODO: change the label...
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };
}
