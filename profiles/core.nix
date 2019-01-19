{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;   # for broadcom_sta, mainly

  environment.systemPackages = with pkgs; [
    wget pv tree htop zile
    screen ag jq file
    (pkgs.runCommand "filtered-busybox" {} "mkdir -p $out/bin && ln -s ${busybox}/bin/{busybox,vi,ash,killall} $out/bin/")
    git tig
    nload
    usbutils
    pciutils
#    gcc
#    gnumake
#    ncurses.dev
    libarchive
    unrar
    unzip
    calc
    sshfs
  ];

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "emacs2";
    defaultLocale = "en_US.UTF-8";
  };

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
  services.openssh.passwordAuthentication = false;

  programs.ssh.askPassword = "";

  security.sudo.extraConfig = "Defaults rootpw";

  programs.command-not-found.enable = true;

  boot.tmpOnTmpfs = true;

  services.logind.extraConfig = ''
    HandleLidSwitch=ignore
    HandlePowerKey=ignore
  '';

  boot.kernel.sysctl = { "net.ipv6.conf.all.use_tempaddr" = 2; };
  networking.dhcpcd.extraConfig = ''
    require dhcp_server_identifier
    clientid
    slaac private
    option rapid_commit
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tewi_inaba = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "systemd-journal" "audio" "video" "render" "dialout" "lp" "cdrom" "floppy" ];
  };

  hardware.opengl.s3tcSupport = true; # Why do I have to enable this? This patent is expired.
}
