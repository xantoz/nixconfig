{ config, pkgs, ... }:

{
  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      # Fix Java on non-reparenting WM:s
      export _JAVA_AWT_WM_NONREPARENTING=1

      # IME
      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
      export CLUTTER_IM_MODULE=fcitx

      # GTK
      export GDK_BACKEND=wayland
      export CLUTTER_BACKEND=wayland

      # Enlightenment
      export ECORE_EVAS_ENGINE=wayland_egl
      export ELM_ENGINE=wayland_egl

      # SDL
      export SDL_VIDEODRIVER=wayland

      # QT
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export QT_WEBENGINE_DISABLE_WAYLAND_WORKAROUND=true

      export XKB_DEFAULT_LAYOUT=us,se
      export XKB_DEFAULT_OPTIONS=grp:shifts_toggle,ctrl:nocaps

      export KITTY_ENABLE_WAYLAND=yes
    '';
    extraPackages = with pkgs; [
      swaybg swaylock swayidle
      waybar
      xwayland rxvt_unicode
      qt5.qtwayland
      dmenu bemenu
      mako
      acpi
      grim
    ];
  };
}
