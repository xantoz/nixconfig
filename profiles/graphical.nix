{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    webmacs
    firefox

    #alacritty
    kitty

    xorg.xeyes
    xorg.xkill
    xkbset
    xss-lock
    ratpoison
    icewm
    xorg.twm
    xsel
    glxinfo
    # drm_info
    vulkan-tools
    xfontsel
    pavucontrol
    pamixer
    pulsemixer
    ponymix
    mpv

    qt5.qtbase # for some reason I need to add this manually now to have xcb platform

    tigervnc
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

    qpwgraph # pipewire patchbay thingy
    helvum # another pipewire patchbay thingy
  ];

  # Subpixel hinting always manages to look bad for some reason
  fonts.fontconfig.subpixel = {
    rgba = "none";
    lcdfilter = "none";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.autorun = false;
  services.xserver.displayManager.startx.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Portals seem to be kinda broken on NixOs, so disable them. In particular
  # with GTK_USE_PORTAL=1 (which will be set in the environment if portals are
  # enabled, see the xdg.portal nix module), modern version of firefox will try
  # to use the org.freedesktop.portal.FileChooser API and not find it.
  #
  # Trying to add pkgs.xdg-desktop-portal-gtk or pkgs.xdg-desktop-portal-kde to
  # xdg.portal.extraPortals does not help. Starting the
  # xdg-desktop-portal-{gtk,kde} binary manually only gives me
  # org.freedesktop.impl.portal.desktop.{gtk,kde} which is not what firefox is
  # looking for.
  xdg.portal.enable = false;
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Needed by the home-manager dconf module
  services.dbus.packages = with pkgs; [ dconf ];

  # Enable sound.
  sound = {
    enable = true;
    enableOSSEmulation = true;
  };
  hardware.pulseaudio.enable = false; # Because we want pipewire instead
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    # media-session.config.bluez-monitor = {
    #   properties = {
    #     "bluez5.sbc-xq-support" = true;
    #     "bluez5.headset-roles" = [
    #       # "hsp_hs"
    #       # "hsp_ag"
    #       "hfp_hf"
    #       "hfp_ag"
    #     ];
    #   };

    #   rules = [{
    #     matches = [{
    #       # This matches all cards.
    #       "device.name" = "~bluez_card.*";
    #     }];
    #     actions.update-props."bluez5.msbc-support" = true;
    #   }];
    # };
  };

  # Enable physlock
  services.physlock.enable = true;
  services.physlock.allowAnyUser = true;
}
