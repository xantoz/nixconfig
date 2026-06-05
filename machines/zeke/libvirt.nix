{ config, pkgs, ... }:

{
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    parallelShutdown = 4;
    shutdownTimeout = 100;
    qemu = {
      runAsRoot = false;        # Run as unprivileged user qemu-libvirtd (should be fine unless I want to have VMs with direct disk access?)
    };
    nss = {
      enable = false;
      enableGuest = true;       # Use only the newer NSS module that uses the libvirt guest name
    };
  };
}
