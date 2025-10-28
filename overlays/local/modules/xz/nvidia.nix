{ lib, pkgs, config, ... }:

let
  cfg = config.xz.nvidia;
in {
  options.xz.nvidia = {
    enable = lib.mkEnableOption "Xantoz custom nvidia module";

    rmIntrLockingMode = lib.mkEnableOption ''
      Whether to use nvidia.NVreg_RegistryDwords=RMIntrLockingMode=1 or not.
      This options exists since nvidia driver 570, and gives potentially less stuttering in VR.
      It has issues with VRR displays though.
    '';
    gspMode = lib.mkOption {
      type = lib.types.enum [
        "no"
        # Option to even disable modesetting (probably not possible to use wayland in such a conf)
        # this will require some more smarts with offload config and such though than the simple passing on we currently do
        # as we'd like kernel params nvidia-drm.modeset=0 nvidia-drm.fbdev=0 basically, but hardware.nvidia.offloadCfgEnable adds those.
        # I guess we could have such a setup in theory with GSP or even the open driver. But I'm not interested in trying/supporting that possible combo anyway. If I'm using the open driver I want all the modernities I think.
        "no-without-modesetting"
        "no-without-simpledrm"
        "yes"
        "yes-with-open-driver"
      ];
      default = "yes-with-open-driver";
    };

    # TODO: support various modes such as: AMD drivers only, nouveau/nvk only, nouveau/nvk + amd, nvidia + amd
    #       probalby also set services.xserver.videoDrivers based on that?
    disableOthers = lib.mkEnableOption ''
      disable e.g. AMD or intel drivers?"
    '';
    # disableNouveau = mkEnableOption "disable the nouveau driver entirely?";

    prime = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Just passed on to hardware.nvidia.modprime
      '';
    };
  };

  config =
    let
      disableSimpleDrm = (cfg.gspMode == "no-without-simpledrm" || cfg.gspMode == "no-without-modesetting"); # The simpledrm driver needs to be disabled if using the nvidia driver in non-modesetting mode, lest things get confusing (avoid having three /dev/dri/cardX)
      noModeSetting = (cfg.gspMode == "no-without-modesetting");
      gspEnabled = (cfg.gspMode == "yes" || cfg.gspMode == "yes-with-open-driver");
      useOpenModule = (cfg.gspMode == "yes-with-open-driver");
    in lib.mkIf cfg.enable {
      nixpkgs.config.cudaSupport = true;

      # Add the nix-community cachix. This should hopefully give me binary cache for packages built with cuda enabled, so I don't have to rebuild blender all the time
      nix.settings.substituters = [
        "https://nix-community.cachix.org"
      ];
      nix.settings.trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      boot.kernelParams =
        lib.optional (!gspEnabled) "NVreg_EnableGpuFirmware=0"
        ++ lib.optionals cfg.rmIntrLockingMode [
          "nvidia.NVreg_RegistryDwords=RMIntrLockingMode=1"
          "nvidia-modeset.conceal_vrr_caps=1"  # (This option doesn't actually exist yet in 570 beta, but we wish for it to exist soon as a way to disable VRR...)
        ] ++ lib.optionals noModeSetting [
          "nvidia-drm.modeset=0"
          "nvidia-drm.fbdev=0"
        ];
      hardware.graphics.enable = true;
      hardware.graphics.enable32Bit = true;

      hardware.nvidia = {
        # Hopefully this is 570.
        package = config.boot.kernelPackages.nvidiaPackages.latest;
        # We patch the open kernel module to behave like CAP_SYS_NICE is always set for the benefit of SteamVR (since NixOS bwraps it and stuff)
        # FIXME: I'm not too sure that this actually applies the overriden package where we want it
        # package =
        #   let
        #     nvidiaPkg = config.boot.kernelPackages.nvidiaPackages.beta;
        #   in nvidiaPkg.overrideAttrs (old: {
        #     patches = old.patches ++ [ ./0001-behave-like-cap_sys_nice-is-always-set.patch ];
        #     # patchesOpen = old.patchesOpen ++ [ ./0001-behave-like-cap_sys_nice-is-always-set.patch ];
        #   });
        modesetting.enable = (!noModeSetting);
        gsp.enable = gspEnabled;
        open = useOpenModule;
        powerManagement.enable = true; # Should help with graphics going derp on suspend?
        prime = lib.mkIf (!noModeSetting) cfg.prime;
      };
      # # Ugly-hack the extraModules setting because the override above doesn't quite work
      # boot.extraModulePackages = lib.mkForce [
      #   (config.boot.kernelPackages.nvidiaPackages.beta.open.overrideAttrs(old: {
      #     patches = old.patches ++ [ ./0001-behave-like-cap_sys_nice-is-always-set.patch ];
      #   }))
      # ];

      boot.blacklistedKernelModules = lib.optionals (cfg.disableOthers || noModeSetting) [
        "amdgpu"
        "i915"
      ];

      boot.kernelPatches =
        lib.optional disableSimpleDrm {
          name = "disable_simpledrm";
          patch = null;
          # Disable simpledrm and use FB_SIMPLE for a simple framebuffer thingy
          # Or should we be using EFIFB here?
          extraConfig = ''
            DRM_SIMPLEDRM n
            FB_SIMPLE y
          '';
          # extraConfig = ''
          #   DRM_SIMPLEDRM n
          #   FB_EFIFB y
          # '';
        };
    };
}
