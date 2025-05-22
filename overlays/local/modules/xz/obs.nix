{ lib, pkgs, config, ... }:

let
  cfg = config.xz.obs;
in {
  options.xz.obs = {
    enable = lib.mkEnableOption "Xantoz custom OBS module";

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ pkgs.obs-studio-plugins.obs-pipewire-audio-capture ];
    };

    loopBackSupport = lib.mkEnableOption "Add things needed for loopbackcamera";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = [
          (pkgs.wrapOBS {
            plugins = cfg.plugins;
          })
        ];
      }
      (lib.mkIf cfg.loopBackSupport {
        # from https://nixos.wiki/wiki/OBS_Studio
        boot.extraModulePackages = with config.boot.kernelPackages; [
          v4l2loopback
        ];
        boot.extraModprobeConfig = ''
          options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
        '';
        security.polkit.enable = true;
      })
    ]
  );
}
