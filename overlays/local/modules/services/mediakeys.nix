{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.services.mediakeys;
in {
  options.services.mediakeys = {
    enable = mkEnableOption "mediakeys";

    backlightPath = mkOption {
      type = types.str;
      default = "/sys/class/backlight/intel_backlight";
      description = ''
        Path to backlight device in sysfs
      '';
    };

    backlightStepPercent = mkOption {
      type = types.int;
      default = 3;
      description = ''
        How much to step the backlight for each press of the button
        expressed in percent of the maximum value.
      '';
    };

    keys = mkOption {
      description = "Keyboard scancodes to associate with the media buttons";
      default = {
        mute = 113;
        volumeDown = 114;
        volumeUp = 115;
        micMute = 190;
        brightnessDown = 224;
        brightnessUp = 225;
      };
      type = types.submodule {
        options = {
          mute           = mkOption { type = types.int; };
          volumeDown     = mkOption { type = types.int; };
          volumeUp       = mkOption { type = types.int; };
          micMute        = mkOption { type = types.int; };
          brightnessDown = mkOption { type = types.int; };
          brightnessUp   = mkOption { type = types.int; };
        };
      };
    };
  };

  # TODO: support for specifying whether to use  (amixer) or
  # pamixer (with corresponding config as to what soundcard to poke)
  config = mkIf cfg.enable {
    services.actkbd =
      let
        backlightPath = cfg.backlightPath;
        backlightStepPercent = builtins.toString cfg.backlightStepPercent;
        brightnessUpCmd = pkgs.writeShellScript "brightness_up" ''
          max_brightness="$(cat ${backlightPath}/max_brightness)"
          backlight_step=$(( ${backlightStepPercent} * max_brightness / 100 ))
          x=$(( $(cat "${backlightPath}/brightness") + backlight_step ))
          x=$(( (x > $max_brightness) ? $max_brightness : x ))
          echo "$x" > "${backlightPath}/brightness"
        '';
        brightnessDownCmd = pkgs.writeShellScript "brightness_down" ''
          max_brightness="$(cat ${backlightPath}/max_brightness)"
          backlight_step=$(( ${backlightStepPercent} * max_brightness / 100 ))
          x=$(( $(cat "${backlightPath}/brightness") - backlight_step ));
          x=$(( (x < 0) ? 0 : x ));
          echo "$x" > "${backlightPath}/brightness"
        '';

        fuckingDbus = "${pkgs.systemd}/bin/machinectl shell --uid=tewi_inaba .host";
        mute       = "${fuckingDbus} ${pkgs.pamixer}/bin/pamixer --mute";
        volumeDown = "${fuckingDbus} ${pkgs.pamixer}/bin/pamixer --unmute --decrease 2";
        volumeUp   = "${fuckingDbus} ${pkgs.pamixer}/bin/pamixer --unmute --increase 2";
        micMute    = "${fuckingDbus} ${pkgs.pamixer}/bin/pamixer --default-source --toggle-mute";
        keys = cfg.keys;
      in {
        enable = true;
        bindings = [
          # "Mute" media key
          {
            keys = [ keys.mute ];
            events = [ "key" ];
            command = mute;
          }

          # "Lower Volume" media key
          {
            keys = [ keys.volumeDown ];
            events = [ "key" "rep" ];
            command = volumeDown;
          }

          # "Raise Volume" media key
          {
            keys = [ keys.volumeUp ];
            events = [ "key" "rep" ];
            command = volumeUp;
          }

          # "Mic Mute" media key
          {
            keys = [ keys.micMute ];
            events = [ "key" ];
            command = micMute;
          }

          {
            keys = [ keys.brightnessUp ];
            events = [ "key" "rep" ];
            command = "${brightnessUpCmd}";
          }

          {
            keys = [ keys.brightnessDown ];
            events = [ "key" "rep" ];
            command = "${brightnessDownCmd}";
          }
        ];
      };
  };
}
