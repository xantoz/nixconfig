{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    webmacs
    librewolf

    #alacritty
    # kitty

    xorg.xeyes
    xorg.xkill
    xkbset
    xss-lock
    ratpoison
    icewm
    xorg.twm
    xsel xclip
    glxinfo
    # drm_info
    vulkan-tools
    xfontsel
    mpv

    qt5.qtbase # for some reason I need to add this manually now to have xcb platform

    tigervnc

    dmenu

    ################################################################################
    ## Pulseaudio mixers etc
    ################################################################################
    pavucontrol
    pamixer
    pulsemixer
    ponymix
    ################################################################################
    ## Pipewire mixers and patchbays etc.
    ################################################################################
    patchage # JACK patchbay thingy (usable for parts of pipewire due to backwards compat)
    qpwgraph # pipewire patchbay thingy
    helvum # another pipewire patchbay thingy
    coppwr # another patchbay thingy/low-level control
    sonusmix # another thing to control pipewire connections, but now different
    # pwvucontrol # pipewire replpacement for pavucontrol
  ];

  fonts.packages = with pkgs; [
    corefonts
    emacs-all-the-icons-fonts

    source-code-pro
    source-sans-pro
    source-serif-pro

    dejavu_fonts

    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    noto-fonts-extra

    source-han-code-jp
    source-han-sans
    source-han-serif

    unifont
    unifont_upper
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
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  # Enable touchpad support.
  services.libinput.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Needed by the home-manager dconf module
  services.dbus.packages = with pkgs; [ dconf ];

  # Audio settings (pipewire)
  services.pulseaudio.enable = false; # Because we want pipewire instead
  services.pipewire = {
    enable = true;
    systemWide = true;          # Let's run pipewire system-wide, yay
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

  # Fixing xwayland font shenanigans? At least partially?
  # from here: https://github.com/NixOS/nixpkgs/issues/155044
  programs.xwayland.enable = true; # I think this one is actually set already by default
  fonts.fontDir.enable = true;
  fonts.enableGhostscriptFonts = true;
  fonts.fontconfig.allowType1 = true;
}
