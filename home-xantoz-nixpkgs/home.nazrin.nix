{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./emacs.nix
    ./desktop.nix
    ./mpv.nix
  ];

  programs.bash.enable = true;
  pam.sessionVariables.LESS = "-R";

  home.file =
  {
    ".config/ratpoison".source = ./config/ratpoison;
    ".ratpoisonrc".source = pkgs.writeText "dotratpoisonrc" ''
      source .config/ratpoison/ratpoisonrc

      setenv rp_backlight_step_percent 3
      source .config/ratpoison/backlightrc

      source .config/ratpoison/volumerc

      source .config/ratpoison/xbattbarrc

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

    # lib.elemAt (builtins.filter (u: u.isNormalUser) (lib.attrValues config.users.users)) 0

    ".xinitrc".source = pkgs.writeText "dotxinitrc" ''
      xrdb -merge ~/.Xresources

      xinput set-prop 'PS/2 Generic Mouse' 'libinput Middle Emulation Enabled' 1
      xinput set-prop 'PS/2 Generic Mouse' 'Coordinate Transformation Matrix' 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 0.300000

      xcompmgr &

      feh --bg-fill ~/Pictures/Wallpapers/Touhou/Du0glW6V4AA2fdz.jpg &

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

      build_cscope()
      {
          find `pwd` -type f -iname '*.[ch]' -print > cscope.files
          IFS=$'\n' etags $(< cscope.files)
          cscope -qbi cscope.files
      }
    '';

    ".screenrc".source = pkgs.writeText "dotscreenrc" ''
      hardstatus alwayslastline
      hardstatus string '%{gk}[ %{G}%H %{g}][%= %{wk}%?%-Lw%?%{=b kR}(%{W}%n*%f %t%?(%u)%?%{=b kR})%{= kw}%?%+Lw%?%?%= %{g}][%{Y}%l%{g}]%{=b C}[ %m/%d %c ]%{W}'

      #kill screen's startup message
      startup_message off

      # define a bigger scrollback, default is 100 lines
      # defscrollback 1024
      defscrollback 4192

      # An alternative hardstatus to display a bar at the bottom listing the
      # window names and highlighting the current window name in blue.
      #hardstatus on
      #hardstatus alwayslastline
      #hardstatus string "%{.bW}%-w%{.rW}%n %t%{-}%+w %=%{..G} %H %{..Y} %m/%d %C%a "

      # Execute .bash_profile on startup
      shell -$SHELL

      # Use C-z instead of C-a as this makes more sense for Emacs
      escape ^z^z

      bind s split
      bind S split -v

      bind { resize -4
      bind } resize +4

      # terminfo and termcap for nice 256 color terminal
      # allow bold colors - necessary for some reason
      attrcolor b ".I"
      # tell screen how to set colors. AB = background, AF=foreground
      termcapinfo xterm 'Co#256:AB=\E[48;5;%dm:AF=\E[38;5;%dm'
      # erase background with current bg color
      defbce "on"
    '';
  };
}
