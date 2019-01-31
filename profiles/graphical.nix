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
    my_mpv = mpv.overrideAttrs(old: {
        src = fetchFromGitHub {
          repo = "mpv";
          owner = "xantoz";
          rev = "drm-presentation-feedback";
          sha256 = "1fdzqxzyzwnxav8sw4649z881frdnn5jj94ngk42bm46l88ry0r1";
        };
        version = "0.29.1-git";
        name = "mpv-0.29.1-git";
        buildInputs = old.buildInputs ++ [
          mesa_noglu
        ];
    });
  in [
    webmacs
    xss-lock
    emacs # TODO: how to into non-graphical emacs? also get rid of the gtk dependency. also user daemon.
    my_ratpoison
    icewm
    xorg.twm
    xsel
    glxinfo
    xfontsel
    pavucontrol
    my_mpv
  ];

  fonts.fonts = with pkgs; [
    emacs-all-the-icons-fonts

    source-code-pro
    source-sans-pro
    source-serif-pro

    dejavu_fonts

    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra

    source-han-code-jp

    source-han-sans-japanese
    source-han-sans-japanese
    source-han-serif-japanese

    source-han-sans-korean
    source-han-sans-korean
    source-han-serif-korean

    source-han-sans-simplified-chinese
    source-han-sans-simplified-chinese
    source-han-serif-simplified-chinese

    source-han-sans-traditional-chinese
    source-han-sans-traditional-chinese
    source-han-serif-traditional-chinese

    unifont
    unifont_upper
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.autorun = false;
  services.xserver.displayManager.startx.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  # Enable pulse with all the modules
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];

    daemon.config = {
      flat-volumes = "no";
      default-sample-format = "s24le";
      default-sample-rate = "192000";
      resample-method = "speex-float-10";
      avoid-resampling = "true";
    };

    package = pkgs.pulseaudioFull;
  };

  # Enable physlock
  services.physlock.enable = true;
  services.physlock.allowAnyUser = true;
}
