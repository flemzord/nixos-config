{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./../../modules/profiles/nixos/common.nix
    ./../../modules/services/postgresql.nix
  ];

  # Bootloader
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "dev-server";

  environment.systemPackages = pkgs.callPackage ./packages.nix { };

  services.nixos-auto-update = {
    enable = true;
    hostname = "dev-server";
  };

  system.stateVersion = "25.11";
}
