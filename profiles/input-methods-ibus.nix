{ config, pkgs, ... }:

{
  # Input method configs
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ mozc m17n ];
  };
  services.xserver.layout = "se(us)";
  services.xserver.xkbOptions = "ctrl:nocaps";
}
