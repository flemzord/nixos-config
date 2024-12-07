# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ modulesPath, config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./../../shared/cachix
      (modulesPath + "/installer/scan/not-detected.nix")
      (modulesPath + "/profiles/qemu-guest.nix")
      ./disk-config.nix
      ./hardware-configuration.nix
      ./../../pkgs/overlays/server.nix
    ];

  networking.hostName = "srv-project"; # Define your hostname.

  environment.systemPackages = pkgs.callPackage ./packages.nix { };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    persistent = true;
    dates = "03:00";
    operation = "switch";
    flags = [ "--impure" "-L" ];
    flake = "/etc/nixos#srv-project";
  };
}
