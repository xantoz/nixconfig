{ config, lib, pkgs, ... }:

with lib;

{
  options = {
    services.easystroke = {
      enable = mkEnableOption "Easystroke gesture recognition";
    };
  };

  config = mkIf config.services.easystroke.enable {
    systemd.user.services.easystroke = {
      Unit = {
        Description = "Easystroke gesture recognition";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.stdenv.shell} -l -c 'exec ${pkgs.easystroke}/bin/easystroke'";
        Restart = "on-failure";
      };
    };
  };
}
