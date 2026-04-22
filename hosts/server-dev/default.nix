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

  # Bootstrap: skip the agenix-decrypted github-token until this host's
  # SSH key is added to secrets.nix and secrets are rekeyed. Flip back to
  # true (or drop this line) once server-dev is listed in allKeys.
  flemzord.githubTokenSecret.enable = false;

  system.stateVersion = "25.11";
}
