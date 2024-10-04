# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./../../shared/cachix
      ./hardware-configuration.nix
      ./../../pkgs/overlays/server.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "home-hp"; # Define your hostname.

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = pkgs.callPackage ./packages.nix { };

  services.vscode-server.enable = true;

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    persistent = true;
    dates = "03:00";
    operation = "switch";
    flags = [ "--impure" "-L" ];
    flake = "/etc/nixos#home-hp";
  };

  systemd.services.vscode-tunnel = {
    description = "VSCode SSH Tunnel";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.vscode}/bin/code tunnel --name=home --no-sleep";
    };
  };

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-connections
      epiphany # web browser
      gnome.geary # email reader. Up to 24.05. Starting from 24.11 the package name is just geary.
      evince # document viewer
    ];
}
