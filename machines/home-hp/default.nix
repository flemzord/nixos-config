# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./../../pkgs/overlays/default.nix
      ./../../pkgs/services/tailscale.nix
      ./../../pkgs/services/docker.nix
      ./../../pkgs/services/goproxy.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.flemzord = {
    isNormalUser = true;
    description = "flemzord";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
  environment = {
    systemPackages = pkgs.callPackage ./packages.nix { };
  };
  system.stateVersion = "23.05"; # Did you read the comment?
}
