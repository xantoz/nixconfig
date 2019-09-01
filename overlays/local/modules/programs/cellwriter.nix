{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.programs.cellwriter;
in {
  options.programs.cellwriter = {
    enable = mkEnableOption "cellwriter";

    package = mkOption {
      type = types.package;
      default = pkgs.cellwriter;
      description = ''
        cellwriter package to use.
      '';
    };

    profile = mkOption {
      default = "";
      description = "File with cellwriter training data";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "cellwriter" ''
        exec ${cfg.package}/bin/cellwriter --profile=${cfg.profile} "$@"
      '')
    ];
  };
}
