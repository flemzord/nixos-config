# PLACEHOLDER: This file should be replaced with the output of 'nixos-generate-config'
# during installation on the actual hardware.
#
# To generate the correct hardware configuration:
#   nixos-generate-config --show-hardware-config > hardware-configuration.nix

{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];


  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" "usb_storage" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
  };

  # Enable DHCP on all network interfaces by default
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Generic hardware settings - will be replaced by actual scan
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
