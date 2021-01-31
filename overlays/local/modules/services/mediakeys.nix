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

    keys = mkOption {
      description = "Keyboard scancodes to associate with the media buttons";
      type = types.submodule {
        options = {
          mute = mkOption           { type = types.int; default = 113; };
          volumeDown = mkOption     { type = types.int; default = 114; };
          volumeUp = mkOption       { type = types.int; default = 115; };
          micMute = mkOption        { type = types.int; default = 190; };
          brightnessDown = mkOption { type = types.int; default = 224; };
          brightnessUp = mkOption   { type = types.int; default = 225; };
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
        backlightStep = "28";         # TODO: really want to be able to specify this in percent. Also for it to be a configurable.
        brightnessUpCmd = pkgs.writeShellScript "brightness_up" ''
          max_brightness="$(cat ${backlightPath}/max_brightness)"
          x=$(( $(cat "${backlightPath}/brightness") + ${backlightStep} ))
          x=$(( (x > $max_brightness) ? $max_brightness : x ))
          echo "$x" > "${backlightPath}/brightness"
        '';
        brightnessDownCmd = pkgs.writeShellScript "brightness_down" ''
          x=$(( $(cat "${backlightPath}/brightness") - ${backlightStep} ));
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
