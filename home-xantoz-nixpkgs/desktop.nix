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
    mate.atril

    gajim
    libnotify
  ];

  services.dunst.enable = true;
}
