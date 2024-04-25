{ config, pkgs, ... }:

{
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      fcitx5-m17n
    ];
  };

  services.xserver.xkb = {
    layout = "se(us)";
    options = "ctrl:nocaps";
  };
}
