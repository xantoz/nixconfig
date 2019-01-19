{ config, pkgs, ... }:

{
  i18n.inputMethod.enabled = "fcitx";
  i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc m17n ];

  services.xserver.layout = "se(us)";
  services.xserver.xkbOptions = "ctrl:nocaps";
}
