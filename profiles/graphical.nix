{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    webmacs
    firefox

    xkbset
    xss-lock
    ratpoison
    icewm
    xorg.twm
    xsel
    glxinfo
    xfontsel
    pavucontrol
    pamixer
    pulsemixer
    ponymix
    mpv
  ];

  fonts.fonts = with pkgs; [
    corefonts
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
    source-han-serif-japanese

    source-han-sans-korean
    source-han-serif-korean

    source-han-sans-simplified-chinese
    source-han-serif-simplified-chinese

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
  sound = {
    enable = true;
    enableOSSEmulation = true;
  };
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
