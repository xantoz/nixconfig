{ config, pkgs, ... }:

{
  # Input method configs
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ mozc m17n ];
  };
  services.xserver.xkb = {
    layout = "se(us)";
    options = "ctrl:nocaps";
  };
}
