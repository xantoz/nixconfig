{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # transset
    xcompmgr
    compton
    stalonetray
    dmenu
    wmname
    redshift

    firefox
    scrot
    gimp
    feh
    unrar
    unzip
    transmission_gtk
    rtorrent
    youtube-dl
    mpv # TODO: custom build from some WIP branch of mine
  ];
}
