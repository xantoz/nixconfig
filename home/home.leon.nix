{ pkgs, lib, config, ... }:

{
  imports = [
    ./emacs.nix
    ./desktop.nix
    ./mpv.nix
    ./common.nix
    ./git.nix
  ];

  # # For Monado:
  # xdg.configFile."openxr/1/active_runtime.json".source = "${pkgs.monado}/share/openxr/1/openxr_monado.json";

  # For WiVRn:
  xdg.configFile."openxr/1/active_runtime.json".source = "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";

  xdg.configFile."openvr/openvrpaths.vrpath".text = ''
    {
      "config" :
      [
        "${config.xdg.dataHome}/Steam/config"
      ],
      "external_drivers" : null,
      "jsonid" : "vrpathreg",
      "log" :
      [
        "${config.xdg.dataHome}/Steam/logs"
      ],
      "runtime" :
      [
        "${pkgs.opencomposite}/lib/opencomposite"
      ],
      "version" : 1
    }
  '';

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

      setenv rp_compositor ${pkgs.picom}/bin/compton
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
              "librewolf '%URL%'"              \
              "mpv '%URL%'"                  \
              "echo -n '%URL%' | xsel -b"    \
              "xterm -e \\\"youtube-dl -o '/tmp/%(title)s.%(ext)s' '%URL%'\\\""
        #include ".config/xterm/Xresources"
    '';

    ".xsession".source = pkgs.writeText "dotxinitrc" ''
      xrdb -merge ~/.Xresources

      export XDG_CURRENT_DESKTOP="ratpoison"
      systemctl --user import-environment XDG_CURRENT_DESKTOP
      dbus-update-activation-environment --systemd XDG_CURRENT_DESKTOP="''${XDG_CURRENT_DESKTOP}"

      xinput set-prop 'HAILUCK CO.,LTD USB KEYBOARD Touchpad' 'Coordinate Transformation Matrix' 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 0.4
      xinput set-prop 'HAILUCK CO.,LTD USB KEYBOARD Touchpad' 'libinput Tapping Enabled' 1

      exec ratpoison
    '';
  };

  home.stateVersion = "24.11";
}
