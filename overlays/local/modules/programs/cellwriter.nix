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
      (pkgs.symlinkJoin {
        name = "cellwriter";
        paths = [ cfg.package ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/cellwriter \
          --add-flags "--profile=${cfg.profile}"
        '';
      })
    ];
  };
}
