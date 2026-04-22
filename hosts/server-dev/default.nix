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

  # Bootloader — UEFI on Hetzner Cloud ARM vServer
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "server-dev";

  # Use systemd-networkd; disable NetworkManager from the common profile
  networking.networkmanager.enable = lib.mkForce false;

  services.nixos-auto-update = {
    enable = true;
    hostname = "server-dev";
  };

  system.stateVersion = "25.11";
}
