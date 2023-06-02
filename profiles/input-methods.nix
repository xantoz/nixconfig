{ config, pkgs, ... }:

{
  # TODO: consider going with more widely supported ibus instead? although at least we are at fcitx5 now, which should work better in wayland?
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      fcitx5-m17n
    ];
  };

  services.xserver.layout = "se(us)";
  services.xserver.xkbOptions = "ctrl:nocaps";
}
