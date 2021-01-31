{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.wpa_gui;
in {
  options = {
    services.wpa_gui = {
      enable = mkEnableOption "WPA Graphical User Interface";

      startInTray = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Starts minimized to system tray if true (default).
        '';
      };

      meterInterval = mkOption {
        type = types.int;
        default = -1;
        description = ''
          Set the update interval in seconds for the signal strength
          meter. If not set to a positive integer the signal strength
          meter is not enabled (default).
        '';
      };

      interface = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Specify the interface that is being configured. By default,
          choose the first interface found with a control socket in the
          socket path.
        '';
      };
    };
  };

  config = mkIf config.services.wpa_gui.enable {
    systemd.user.services.wpa_gui = {
      Unit = {
        Description = "WPA Graphical User Interface";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.stdenv.shell} -l -c 'exec ${pkgs.wpa_supplicant_gui}/bin/wpa_gui ${optionalString (cfg.interface != null) "-i${cfg.interface}"} -m${cfg.meterInterval} ${optionalString (cfg.startInTray) "-t"}'";
        Restart = "on-failure";
      };
    };
  };
}
