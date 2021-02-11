{ config, pkgs, lib, ... }:

let
  uboot = pkgs.uBootPinebookProExternalFirst;
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ./sd-image-aarch64.nix
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
  boot.kernelParams = [ "resume=/dev/mmcblk0p1" "resume_offset=4761600" ];

  sdImage = {
    manipulateImageCommands = ''
      (PS4=" $ "; set -x
      dd if=${uboot}/idbloader.img of=$img bs=512 seek=64 conv=notrunc
      dd if=${uboot}/u-boot.itb of=$img bs=512 seek=16384 conv=notrunc
      )
    '';
    compressImage = lib.mkForce false;
  };
}
