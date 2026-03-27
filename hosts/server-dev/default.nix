{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./../../modules/profiles/nixos/common.nix
    ./../../modules/profiles/nixos/dev.nix
    ./../../modules/services/postgresql.nix
  ];

  # Bootloader
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "server-dev";

  services.nixos-auto-update = {
    enable = true;
    hostname = "server-dev";
  };

  system.stateVersion = "25.11";
}
