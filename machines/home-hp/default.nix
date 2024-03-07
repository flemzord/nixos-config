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

  systemd.timers."auto-update" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "40m";
      Unit = "auto-update.service";
    };
  };

  systemd.services."auto-update" = {
    script = ''
      cd /etc/nixos/
      /root/.nix-profile/bin/git pull origin main
      /run/current-system/sw/bin/nixos-rebuild switch --flake ".#home-hp"
    '';
    environment = {
      NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM = "1";
    };
    serviceConfig = {
      OnCalendar = "daily";
      Persistent = true;
      User = "root";
    };
  };
}
