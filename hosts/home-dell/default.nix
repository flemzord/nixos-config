{ modulesPath, pkgs, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
    ./../../modules/profiles/nixos/common.nix
    ./../../modules/services/samba.nix
    ./../../modules/services/transmission.nix
    ./../../modules/services/home-assistant.nix
    ./../../modules/services/cloudflared.nix
  ];

  # Bootloader
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "home-dell";

  environment.systemPackages = pkgs.callPackage ./packages.nix { };

  services.nixos-auto-update = {
    enable = true;
    hostname = "home-dell";
  };

  system.stateVersion = "25.11";
}
