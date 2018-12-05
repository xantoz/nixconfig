{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;   # for broadcom_sta, mainly

  environment.systemPackages = with pkgs; [
    wget pv tree htop zile
    screen ag jq file
    (pkgs.runCommand "filtered-busybox" {} "mkdir -p $out/bin && ln -s ${busybox}/bin/{busybox,vi,ash} $out/bin/")
    git tig
  ];

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "emacs2";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tewi_inaba = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "systemd-journal" "audio" "video" "render" "dialout" "lp" "input" "cdrom" "floppy" ];
  };
}
