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

  systemd.services."auto-update" = {
    script = ''
      cd /etc/nixos/
      git pull origin main
      make switch NIXNAME=home-hp
    '';
    serviceConfig = {
      OnCalendar = "daily";
      Persistent = true;
      User = "root";
    };
  };
}
