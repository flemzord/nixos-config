# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./../../modules/common/cachix.nix
      ./hardware-configuration.nix
      ./../../modules/roles/server.nix
      ./../../modules/services/docker.nix
      ./../../modules/services/octoprint.nix
      ./../../modules/services/nixos-auto-update.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "home-hp"; # Define your hostname.

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = pkgs.callPackage ./packages.nix { };

  services = {
    vscode-server.enable = true;
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    displayManager.autoLogin = {
      enable = true;
      user = "flemzord";
    };
    teamviewer.enable = true;
  };

  # Auto-update NixOS configuration from git daily at 6 AM
  services.nixos-auto-update = {
    enable = true;
    hostname = "home-hp";
  };

  # Disabled in favor of nixos-auto-update service that includes git pull
  # system.autoUpgrade = {
  #   enable = true;
  #   allowReboot = true;
  #   persistent = true;
  #   dates = "03:00";
  #   operation = "switch";
  #   flags = [ "--impure" "-L" ];
  #   flake = "/etc/nixos#home-hp";
  # };

  systemd.services.vscode-tunnel = {
    description = "VSCode SSH Tunnel";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.vscode}/bin/code tunnel --name=home --no-sleep";
    };
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-connections
    epiphany # web browser
    evince # document viewer
  ];
  i18n.supportedLocales = [ "all" ];
  security.chromiumSuidSandbox.enable = true;
  # systemd.services."getty@tty1".enable = false;
  #  systemd.services."autovt@tty1".enable = false;
}
