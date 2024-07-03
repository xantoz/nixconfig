{ pkgs, lib, ... }:

{
  imports = [
    ./emacs.nix
    ./desktop.nix
    ./dunst.nix
    ./mpv.nix
    ./common.nix
    ./git.nix
    ./gimpscan.nix
  ];

  # Autostart XDG thingies. This will pull in random shit just because
  # they are installed, and it is kind of stupid. Yet let's try it
  # because it is the way XDG thinks it should work?
  #
  # If this turns out to be a terrible idea I'll just go with a script
  # that manually calls `systemctl --user start <service>` for the
  # autogenerated services for XDG-thingies instead.
  #
  # Also maybe in the end I should just dump home-manager and use one
  # of the session manager thingies from nixpkgs instead.
  systemd.user.targets.hm-graphical-session = {
    Unit = {
      Wants = [ "xdg-desktop-autostart.target" ];
    };
  };

  services.network-manager-applet.enable = true;

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

      setenv rp_compositor ${pkgs.xcompmgr}/bin/xcompmgr
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

    # TODO: Set the BG using my ratpoison scripting instead
    #       See if there is no way to run the xinput commands etc. using some home-manager functionality
    #       Run ratpoison as a systemd service
    #       Run stalonetray using the home-manager service that already exists for it
    ".xsession".source = pkgs.writeText "dotxinitrc" ''
      xrdb -merge ~/.Xresources

      xinput set-prop 'PS/2 Generic Mouse' 'libinput Middle Emulation Enabled' 1
      xinput set-prop 'PS/2 Generic Mouse' 'Coordinate Transformation Matrix' 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 0.300000

      feh --bg-fill ~/Pictures/Wallpapers/Touhou/Du0glW6V4AA2fdz.jpg &

      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
      export CLUTTER_IM_MODULE=fcitx
      # # Starts the service generated by systemd-xdg-generator
      # systemctl --user start app-org.fcitx.Fcitx5@autostart.service

      exec ratpoison
    '';
  };

  home.stateVersion = "22.05";
}
