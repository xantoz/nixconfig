{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ lact ];

  # nouveau/NVK settings
  # services.xserver.videoDrivers = [
  #   "amdgpu"
  #   "nouveau"
  # ];

  # TODO: Perhaps make this into a machine-specific module (still leveraging my xz.nvidia which is a bit more generic)

  #################################################################################
  ## settings for amdgpu main with nvidia offload (might happen to work even if mux set to nvidia if you are lucky)
  #################################################################################
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

  #################################################################################
  ## settings for nvidia only, amdgpu completely disabled
  #################################################################################
  # services.xserver.videoDrivers = [
  #   "nvidia"
  # ];
  # xz.nvidia = {
  #   enable = true;
  #   rmIntrLockingMode = true;
  #   gspMode = "yes-with-open-driver";
  #   disableOthers = true;
  #   prime = {
  #     offload.enable = true;
  #     offload.enableOffloadCmd = true; # Gives us the nvidia-offload convenience script
  #     amdgpuBusId = "PCI:34:0:0";
  #     nvidiaBusId = "PCI:1:0:0";
  #   };
  # };

  #################################################################################
  ## settings for amdgpu only, nvidia completely disabled
  #################################################################################
  # services.xserver.videoDrivers = [
  #  "amdgpu"
  # ];
  # xz.nvidia.enable = false;
  # hardware.nvidiaOptimus.disable = true;
  # boot.kernelPatches = [
  #   {
  #     name = "amdgpu-ignore-ctx-privileges";
  #     patch = pkgs.fetchpatch {
  #       name = "cap_sys_nice_begone.patch";
  #       url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
  #       hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
  #     };
  #   }
  # ];


}
