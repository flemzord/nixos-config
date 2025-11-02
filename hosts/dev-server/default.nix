# Configuration for dev-server - Remote development server
# Minimal, headless NixOS system with core development tools

{ modulesPath, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ./networking.nix

    # Shared modules
    ./../../modules/common/cachix.nix
    ./../../modules/roles/server.nix
    ./../../modules/services/docker.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "dev-server";

  # User configuration
  users.users.flemzord = {
    isNormalUser = true;
    description = "flemzord";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      git
      vim
    ];
  };

  # Development packages
  environment.systemPackages = pkgs.callPackage ./packages.nix { };

  # DNS configuration
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  # No automatic upgrades - manual control for dev server
  # system.autoUpgrade.enable = false;
}
