{ pkgs, lib, ... }:

{
  imports = [
    ./emacs.nix
    ./desktop.nix
    ./mpv.nix
    ./common.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    pulseview
  ];

  xsession = {
    enable = true;
    windowManager.command = "/bin/sh ~/.xsession";
    scriptPath = ".xinitrc";
  };

  services.blueman-applet.enable = true;

  # services.kdeconnect = {
  #   enable = false;
  #   indicator = true;
  # };

  services.pasystray.enable = true;
  # Get notifications
  systemd.user.services.pasystray.Service.ExecStart =
    lib.mkOverride 10 "${pkgs.pasystray}/bin/pasystray --notify=all";

  programs.bash.enable = true;
  pam.sessionVariables.LESS = "-R";

  home.file = {
    ".drirc".source = pkgs.writeText "drirc" ''
      <driconf>
        <!-- Please always enable app-specific workarounds for all drivers and
             screens. -->
        <device>
            <application name="all">
                <option name="allow_rgb10_configs" value="true"/>
                <option name="mesa_glthread" value="true"/>
            </application>
        </device>
      </driconf>
     '';

    ".config/ratpoison".source = ./config/ratpoison;
    ".ratpoisonrc".source = pkgs.writeText "dotratpoisonrc" ''
      source .config/ratpoison/ratpoisonrc

      setenv rp_backlight_step_percent 3
      source .config/ratpoison/backlightrc

      source .config/ratpoison/volumerc

      setenv rp_compositor xcompmgr
      setenv rp_compositor_args --
      source .config/ratpoison/compositorrc

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

      xinput set-prop 'PS/2 Generic Mouse' 'libinput Middle Emulation Enabled' 1
      xinput set-prop 'PS/2 Generic Mouse' 'Coordinate Transformation Matrix' 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 0.300000

      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
      export CLUTTER_IM_MODULE=fcitx
      fcitx &

      exec ratpoison
    '';

    ".bashrc".source = pkgs.writeText "dotbashrc" ''
      export HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S - '
      shopt -s histappend
      shopt -s cmdhist
      shopt -s histverify
      HISTSIZE=600000
      HISTFILESIZE=600000
      PROMPT_COMMAND='history -a;history -n'
      export HISTCONTROL=ignoreboth

      alias dush='du -sh * | sort -h'

      0x0()
      {
          curl -F"file=@$1" https://0x0.st
      }

      build_cscope()
      {
          find `pwd` -type f -iname '*.[ch]' -print > cscope.files
          IFS=$'\n' etags $(< cscope.files)
          cscope -qbi cscope.files
      }

      alias mount-patchouli='sshfs -o reconnect patchouli:/ /mnt/patchouli'

      export PATH="$HOME/.local/bin:$PATH"

      export EDITOR='emacsclient -t'
    '';
  };
}
