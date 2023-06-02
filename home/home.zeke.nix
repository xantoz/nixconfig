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

  # services.wpa_gui = {
  #   enable = true;
  #   interface = "wlan0";
  # };

  # services.kdeconnect = {
  #   enable = false;
  #   indicator = true;
  # };

  # services.pasystray.enable = true;
  # # Get notifications
  # systemd.user.services.pasystray.Service.ExecStart =
  #   lib.mkOverride 10 "${pkgs.pasystray}/bin/pasystray --notify=all";

  home.file = {
    ".config/ratpoison".source = ./config/ratpoison;
    ".ratpoisonrc".source = pkgs.writeText "dotratpoisonrc" ''
      source .config/ratpoison/ratpoisonrc

      source .config/ratpoison/xbattbarrc

      setenv rp_compositor compton
      setenv rp_compositor_args --glx-no-stencil --backend glx --opengl --vsync
      source .config/ratpoison/compositorrc

      # This is just to make ratpoison swallow these key inputs so they don't get sent on to other programs
      # They keys are actually handled by actkbd or whatever
      alias noop exec true
      definekey top XF86AudioRaiseVolume noop
      definekey top XF86AudioLowerVolume noop

      # Emacs battery module is not working right on PBP (maybe you could reconfig emacs to use upower?)
      alias battery exec ratpoison -c "echo $(upower -i /org/freedesktop/UPower/devices/battery_cw2015_battery)"

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

      xinput set-prop 'HAILUCK CO.,LTD USB KEYBOARD Touchpad' 'Coordinate Transformation Matrix' 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 0.4
      xinput set-prop 'HAILUCK CO.,LTD USB KEYBOARD Touchpad' 'libinput Tapping Enabled' 1

      feh --bg-fill ~/Pictures/Wallpapers/Touhou/Du0glW6V4AA2fdz.jpg &

      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
      export CLUTTER_IM_MODULE=fcitx
      fcitx &

      exec ratpoison
    '';
  };
}
