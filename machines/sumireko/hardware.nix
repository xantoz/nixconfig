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
