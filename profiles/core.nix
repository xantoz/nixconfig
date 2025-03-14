{ config, pkgs, ... }:

let
  # flake-compat freaks out when it sees the .git in my submodule... For now lets just continue getting this submodule using fetchGit. I'm going to have to use a patched flake-compat eventually
  # nixpkgs-xr = (import ../overlays/nixpkgs-xr);
  nixpkgs-xr = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixpkgs-xr.git";
    rev = "99383a8dda24c47f13418c505937338cbb05194e";
  });
in {
  nixpkgs.config.allowUnfree = true;   # for broadcom_sta, mainly

  nixpkgs.overlays = [
    nixpkgs-xr.outputs.overlays.default
    (import ../overlays/local/pkgs/default.nix)
  ];
  imports = import ../overlays/local/modules/module-list.nix;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # Use local nixpkgs checkout
    nixPath = [
      "/etc/nixos"
      "nixpkgs=/etc/nixos/nixpkgs"
      "nixpkgs-overlays=/etc/nixos/overlays/local"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
    settings = {
      sandbox = true;
      auto-optimise-store = true;
    };
  };

  environment.systemPackages = with pkgs; [
    appimage-run
    nix-btm nix-output-monitor
    wget pv tree htop btop zile
    silver-searcher jq file
    fd # that rust-based find replacement that is faster than regular find, but has different syntax that is "better" (I kinda wish there was a drop-in replacement tbh)
    (pkgs.runCommand "filtered-busybox" {} "mkdir -p $out/bin && ln -s ${busybox}/bin/{busybox,vi,ash,killall} $out/bin/")
    git tig
    nload
    lm_sensors
    usbutils
    pciutils
    libarchive
    unrar
    unzip
    unar
    calc
    sshfs
    lshw
    lsof
    psmisc # for fuser
    keyutils
    f2fs-tools
    exfat
    smartmontools
    nix-prefetch-git
    nix-prefetch-github
    libsixel
    graphviz # for visualizing closures
    progress
    cifs-utils   # for mounting SMB shares

    unixtools.fdisk
    gptfdisk
    ntfsprogs

    poppler_utils # for pdfimages
    lsix

    # man page havings
    linux-manual man-pages man-pages-posix

    # Have a python interpreter at hand
    python3

    doas-sudo-shim

    # Useful alias for nix repl automatically loading default nixpkgs and also config
    (writeShellScriptBin "nr" ''
      exec nix repl --file \<nixpkgs\> "$@"
    '')
    (writeShellScriptBin "nro" ''
      exec nix repl --file \<nixpkgs/nixos\> "$@"
    '')
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "libsixel-1.8.6" # CVE-2020-11721 and CVE-2020-19668
  ];

  # programs.simpleserver.enable = true;

  programs.screen.screenrc = builtins.readFile ../home/config/dotfiles/src/.screenrc;
  programs.screen.enable = true;

  services.gpm.enable = true;

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "emacs2";
  };

  services.dbus.enable = true;

  # TODO: Switch over to the service in the nixpkgs "ssh" module?
  #       Or the one in home-manager?
  #       Or do we switch to use gpg-agent?
  systemd.user.services.ssh-agent = {
    enable = true;
    description="SSH key agent";
    serviceConfig = {
      Type="simple";
      Environment="SSH_AUTH_SOCK=%t/ssh-agent.socket";
      ExecStart="${pkgs.openssh}/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
    };
    wantedBy = [ "default.target" ];
  };
  environment.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  programs.ssh.askPassword = "";

  # CVE-2021-3516 was the straw the broke the camels back. How many
  # more bugs are hiding in there? Just say no to usdo!
  security.sudo.enable = false;

  # Enable doas to replace sudo
  security.doas.enable = true;
  security.doas.extraRules = [
    { groups = [ "wheel" ]; noPass = false; persist = true; setEnv = [ "NIX_PATH" ]; }
  ];

  programs.command-not-found.enable = true;

  services.logind.extraConfig = ''
    HandleLidSwitch=ignore
    HandleLidSwitchDocked=ignore
    HandleLidSwitchExternalPower=ignore
    HandlePowerKey=ignore
  '';

  boot.kernel.sysctl."kernel.sysrq" = 502; # Enables more sysrq stuff

  boot.kernel.sysctl = { "net.ipv6.conf.all.use_tempaddr" = 2; };
  networking.dhcpcd.extraConfig = ''
    require dhcp_server_identifier
    clientid
    slaac private
    option rapid_commit
  '';

  services.udev.extraRules = ''
    SUBSYSTEM=="backlight", ACTION=="add", \
      RUN+="${pkgs.coreutils}/bin/chgrp wheel %S%p/brightness", \
      RUN+="${pkgs.coreutils}/bin/chmod g+w %S%p/brightness"

    # gamecube wii u usb adapter
    ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0337", MODE="666", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device" TAG+="uaccess"
    # This rule is needed for basic functionality of the controller in Steam and keyboard/mouse emulation
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
    # This rule is necessary for gamepad emulation; make sure you replace 'pgriffais' with a group that the user that runs Steam belongs to
    KERNEL=="uinput", MODE="0660", GROUP="wheel", OPTIONS+="static_node=uinput"
    # Nintendo Switch Pro Controller over USB hidraw
    KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666"
    # Nintendo Switch Pro Controller over bluetooth hidraw
    KERNEL=="hidraw*", KERNELS=="*057E:2009*", MODE="0666"
  '';

  # Have man pages, in particular for C and POSIX functions etc.
  documentation = {
    enable = true;
    man.enable = true;
    dev.enable = true;
    info.enable = true;
    doc.enable = true;
    # Enabling the below apparently helps whatis and apropos a bit. Unfortunately it also makes build times very long, so do not enable it for now
    # man.generateCaches = true;
  };
}
