# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";

    # We don't raid the boot parts, instead we copy everything
    # over to the second disk
    mirroredBoots = [{
      devices = [ "/dev/nvme1n1" ];
      path = "/boot";
    }];
  };
   boot.swraid.enable = true;
   boot.swraid.mdadmConf = ''
     HOMEHOST srv-project
   '';

  services.mdadm = {
    enable = true;
    mailAddr = "root";
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  #networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
  networking = {
      useDHCP = false;
      interfaces."enp4s0" = {
        ipv4.addresses = [{ address = "37.27.100.113"; prefixLength = 26; }];
#        ipv6.addresses = [{ address = "2a01:xx:xx::1"; prefixLength = 64; }];
      };
      defaultGateway = "37.27.100.65";
#      defaultGateway6 = { address = "fe80::1"; interface = "enp35s0"; };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
