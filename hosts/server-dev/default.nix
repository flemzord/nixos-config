{ lib, ... }:

{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./../../modules/profiles/nixos/common.nix
    ./../../modules/profiles/nixos/dev.nix
    ./../../modules/services/postgresql.nix
  ];

  # Bootloader - GRUB managed by disko (installed on both NVMe)
  boot.loader.grub.enable = true;

  networking.hostName = "server-dev";

  # Disable NetworkManager — this server uses static IP config
  networking.networkmanager.enable = lib.mkForce false;

  services.nixos-auto-update = {
    enable = true;
    hostname = "server-dev";
  };

  system.stateVersion = "25.11";
}
