{ pkgs, lib, ... }:

{
  imports = [
    ./emacs.nix
    ./desktop.nix
    ./mpv.nix
    ./common.nix
    ./git.nix
  ];

  services.blueman-applet.enable = true;

  services.wpa_gui = {
    enable = true;
    interface = "wlo1";
    meterInterval = 10;
  };

  # services.kdeconnect = {
  #   enable = false;
  #   indicator = true;
  # };

  services.pasystray.enable = true;
  # Get notifications
  systemd.user.services.pasystray.Service.ExecStart =
    lib.mkOverride 10 "${pkgs.pasystray}/bin/pasystray --notify=all";

  home.file = {
    ".config/ratpoison".source = ./config/ratpoison;
    ".ratpoisonrc".source = pkgs.writeText "dotratpoisonrc" ''
      source .config/ratpoison/ratpoisonrc

      # setenv rp_backlight_step_percent 3
      # source .config/ratpoison/backlightrc

      # source .config/ratpoison/volumerc
      source .config/ratpoison/xbattbarrc

      setenv rp_compositor xcompmgr
      setenv rp_compositor_args --
      source .config/ratpoison/compositorrc

      # This is just to make ratpoison swallow these key inputs so they don't get sent on to other programs
      # They keys are actually handled by actkbd or whatever
      alias noop exec true
      definekey top XF86AudioRaiseVolume noop
      definekey top XF86AudioLowerVolume noop

      alias xterm exec xterm -e '$SHELL -c "xprop -id $WINDOWID -f _NET_WM_WINDOW_OPACITY 32c -set _NET_WM_WINDOW_OPACITY 0xeeeeeeee; exec $SHELL -l"'
      alias reload source .ratpoisonrc
    '';

    ".config/xterm".source = ./config/xterm;
    ".Xresources".source = pkgs.writeText "dotXresources" ''
        #define XTERM_URL_COMMANDS           \
              "webmacs '%URL%'"              \
              "firefox '%URL%'"              \
              "mpv '%URL%'"                  \
              "echo -n '%URL%' | xsel -b"    \
              "xterm -e \\\"youtube-dl -o '/tmp/%(title)s.%(ext)s' '%URL%'\\\""
        #include ".config/xterm/Xresources"
    '';

    ".xsession".source = pkgs.writeText "dotxinitrc" ''
      xrdb -merge ~/.Xresources

      xinput set-prop 'PS/2 Generic Mouse' 'libinput Middle Emulation Enabled' 1
      xinput set-prop 'PS/2 Generic Mouse' 'Coordinate Transformation Matrix' 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 0.300000

      feh --bg-fill ~/Pictures/Wallpapers/Touhou/Du0glW6V4AA2fdz.jpg &

      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
      export CLUTTER_IM_MODULE=fcitx
      fcitx &

      exec ratpoison
    '';
  };
}
