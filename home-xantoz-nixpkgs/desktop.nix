{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lm_sensors

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
    transmission_gtk
    rtorrent
    youtube-dl
    mpv # TODO: custom build from some WIP branch of mine
    mate.atril

    gajim
  ];
}
