{ ... }:

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

  services.nixos-auto-update = {
    enable = true;
    hostname = "server-dev";
  };

  system.stateVersion = "25.11";
}
