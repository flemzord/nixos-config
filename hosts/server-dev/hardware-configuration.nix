{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
    initrd.kernelModules = [ "dm-raid" "md_mod" "raid1" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  # Disko manages filesystems
  # fileSystems and swapDevices are declared in disk-config.nix

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
