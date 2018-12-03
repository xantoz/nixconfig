{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # graphical only from here
    emacs # TODO: how to into non-graphical emacs? also get rid of the gtk dependency. also user daemon.
    ratpoison  # TODO: make a custom vers ion which is git master + some patches
    icewm
    xorg.twm
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us,se";
  services.xserver.xkbOptions = "ctrl:nocaps,grp:shifts_toggle";
  services.xserver.autorun = false;
  services.xserver.displayManager.startx.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  # hardware.pulseaudio.enable = true;
}