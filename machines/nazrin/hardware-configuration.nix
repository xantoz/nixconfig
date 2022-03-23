# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [
    "kvm-intel"
    # "wl"
  ];
  # boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c764057f-5e76-4d1f-8396-d94f8d2a7447";
      fsType = "xfs";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/912A-DB02";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/f17d4220-f9b6-4652-adbb-44e5bfdbeada"; }
    ];

  nix.settings.max-jobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel ];
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.cpu.intel.updateMicrocode = true;
}
