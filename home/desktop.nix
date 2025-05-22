{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xorg.transset
    stalonetray
    dmenu
    wmname
    redshift
    xtermcontrol

    scrot
    gimp
    feh
    pqiv
    #imv  # not on aarch64
    transmission_4-gtk
    yt-dlp
    gallery-dl
    # mate.atril
    evince
    gajim

    remmina

    # mcomix3
    # qcomicbook
    # comical
    # yacreader

    # discord   # not on aarch64
    # tdesktop
    # slack     # same

    # audacity

    (writeShellScriptBin "partycow" ''
      while true; do printf 'Hello World!' | ${cowsay}/bin/cowsay | ${lolcat}/bin/lolcat; printf '\e[F\e[F\e[F\e[F\e[F\e[F\e[F\e[F'; done
    '')

    (writeShellScriptBin "partycow1" ''
      while true; do printf 'Hello World!' | ${cowsay}/bin/cowsay | ${lolcat}/bin/lolcat; printf '\e[F\e[F\e[F\e[F\e[F\e[F\e[F'; done
    '')

    (writeShellScriptBin "rtorrent" ''
      ${xtermcontrol}/bin/xtermcontrol --title=rtorrent
      exec ${rtorrent}/bin/rtorrent "$@"
    '')

    libnotify                   # notify-send

    pulseview
  ];

  # TODO: Might be a nicer way to do this? Also maybe try to run the WM as a service or so?
  xsession = {
    enable = true;
    windowManager.command = "/bin/sh ~/.xsession";
    scriptPath = ".xinitrc";
  };

  programs.bash.enable = true;
  pam.sessionVariables.LESS = "-R";

  # ah... dconf/gsettings. Re-inventing the windows registry, but worse!
  dconf = {
    enable = true;
    settings = {
      "org/gtk/settings/file-chooser" = {
        sort-directories-first = true;
      };
    };
  };

  home.file = {
   ".webmacs/init".source = ./config/webmacs;
  };

  # i18n.inputMethod = {
  #   enabled = "fcitx5";
  #   fcitx5.addons = with pkgs; [
  #     fcitx5-mozc
  #     fcitx5-gtk
  #     fcitx5-m17n
  #   ];
  # };
}
