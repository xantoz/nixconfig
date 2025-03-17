{ config, pkgs, ... }:

{
  imports = [
    ./wayland-general.nix
  ];

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
      sfwbar
      xwayland
      qt5.qtwayland
      mako
      acpi
      grim
      sway-contrib.grimshot

      # TODO: Split out those other compositors to their own profile (or better yet: Make a module for wlroots/other minor compositors?
      #       Even better would be to make a module for all compositors

      # Wayfire stuff
      wayfire-with-plugins wf-config wf-recorder wf-touch

      # niri
    ];
  };
}
