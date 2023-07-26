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

  # services.kdeconnect = {
  #   enable = false;
  #   indicator = true;
  # };

  services.pasystray.enable = true;
  # Get notifications
  systemd.user.services.pasystray.Service.ExecStart =
    lib.mkOverride 10 "${pkgs.pasystray}/bin/pasystray --notify=all";

  services.easystroke.enable = true;

  home.file = {
    ".config/ratpoison".source = ./config/ratpoison;
    ".ratpoisonrc".source = pkgs.writeText "dotratpoisonrc" ''
      # Bit of an ugly hack to use the ids, since the long names contain spaces and the scripting in ratpoisonrc is not equipped to handle this
      setenv rp_wacomdevices 12 13
      source .config/ratpoison/ratpoisonrc

      source .config/ratpoison/volumerc

      setenv rp_compositor ${pkgs.xcompmgr}/bin/xcompmgr
      setenv rp_compositor_args --
      source .config/ratpoison/compositorrc

      source .config/ratpoison/cellwriterrc

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
              "echo -n '%URL%' | xsel -i"    \
              "xterm -e \\\"youtube-dl -o '/tmp/%(title)s.%(ext)s' '%URL%'\\\""
        #include ".config/xterm/Xresources"
    '';

    ".xsession".source = pkgs.writeText "dotxinitrc" ''
      xrdb -merge ~/.Xresources

      feh --bg-fill ${./wallpapers/Touhou.full.1536689.jpg} &

      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
      export CLUTTER_IM_MODULE=fcitx
      fcitx &

      # WACOM_IDS="12 13"
      # for i in $WACOM_IDS; do xsetwacom --set $i Threshold 1000; done
      # for i in $WACOM_IDS; do xsetwacom --set $i Threshold 800; done
      # for i in $WACOM_IDS; do xsetwacom --set $i Threshold 400; done
      # for i in $WACOM_IDS; do xsetwacom set $i Area 59 -60 24576 18288; done
      # for i in $WACOM_IDS; do xsetwacom set $i Area 30 -99 24639 18293; done
      # for i in $WACOM_IDS; do xsetwacom set $i Area 29 -102 24685 18262; done
      # for i in $WACOM_IDS; do xsetwacom set $i Area 56 -45 24788 18277; done
      xsetwacom --set 13 Button 1 2  # make the eraser do a middle-click

      exec ratpoison
    '';
  };

  home.stateVersion = "22.05";
}
