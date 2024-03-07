# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./../../pkgs/overlays/server.nix
      ./../../pkgs/services/docker.nix
      ./../../pkgs/services/n8n.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "home-hp"; # Define your hostname.

  environment.systemPackages = pkgs.callPackage ./packages.nix { };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    persistent = true;
    dates = "03:00";
    flags = [ "--impure", "-L" ];
    flake = "/etc/nixos#home-dell";
  };
}
