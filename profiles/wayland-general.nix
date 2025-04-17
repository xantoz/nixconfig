{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    waypipe
    bemenu

    # Usable minimal wayland-native terminals
    foot
    #stupidterm

    wev

    wl-clipboard                # Clipboard management and stuff
    # wl-clip-persist
    # cliphist                  # more fancy clipboard manager. home-manager module exists
    # clipman                   # another more fancy clipboard manager. home-manager module exists
    # clipmon                   # supports persisting after app exists and supports more than text?
  ];
}
