# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ modulesPath, config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      (modulesPath + "/installer/scan/not-detected.nix")
      (modulesPath + "/profiles/qemu-guest.nix")
      ./disk-config.nix
      ./hardware-configuration.nix
      ./../../pkgs/overlays/server.nix
      ./../../pkgs/services/docker.nix
      # ./../../pkgs/services/home-assistant.nix
      ./../../pkgs/services/mosquitto.nix
      ./../../pkgs/services/homebridge.nix
    ];

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "home-dell"; # Define your hostname.

  environment.systemPackages = pkgs.callPackage ./packages.nix { };

  systemd.services."auto-update" = {
    script = ''
      cd /etc/nixos/
      git pull origin main
      make switch NIXNAME=home-dell
    '';
    serviceConfig = {
      OnCalendar = "daily";
      Persistent = true;
      User = "root";
    };
  };
}
