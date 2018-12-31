{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
  let
    my_ratpoison = ratpoison.overrideAttrs(old: {
        src = fetchFromGitHub {
          repo = "ratpoison";
          owner = "xantoz";
          rev = "wip";
          sha256 = "1gz3dj15pa2mxndhkbr3ls9i7x3g6f4bxk4ifnpa3igl0p36j6gk";
        };
        buildInputs = old.buildInputs ++ [autoreconfHook texinfo];
        version = "1.4.10";
        name = "ratpoison-1.4.10";
    });
  in [
    # graphical only from here
    xss-lock
    emacs # TODO: how to into non-graphical emacs? also get rid of the gtk dependency. also user daemon.
    my_ratpoison
    icewm
    xorg.twm
    xsel
    glxinfo
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
  hardware.pulseaudio.enable = true;

  # Enable physlock
  services.physlock.enable = true;
  services.physlock.allowAnyUser = true;
}
