{ config, pkgs, ... }:

{
  # TODO: fcitx is not the best in wayland in particular, replace fcitx usage with dbus
  i18n.inputMethod.enabled = "fcitx";
  i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc m17n ];

  services.xserver.layout = "se(us)";
  services.xserver.xkbOptions = "ctrl:nocaps";
}
