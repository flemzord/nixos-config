# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ modulesPath, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./../../modules/common/cachix.nix
      (modulesPath + "/installer/scan/not-detected.nix")
      (modulesPath + "/profiles/qemu-guest.nix")
      ./disk-config.nix
      ./hardware-configuration.nix
      ./../../modules/roles/server.nix
      #./../../modules/services/docker.nix
      ./../../modules/services/samba.nix
      ./../../modules/services/transmission.nix
      ./../../modules/services/home-assistant.nix
      # ./../../modules/services/mosquitto.nix
      # ./../../modules/services/homebridge.nix
      #./../../modules/services/n8n.nix
      # ./../../modules/services/qdrant.nix
      ./../../modules/services/cloudflared.nix
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

  users.users.flemzord = {
    isNormalUser = true;
    description = "flemzord";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      git
      vim
    ];
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    ensureDatabases = [ "postgres" "kipli" ];
    ensureUsers = [
      {
        name = "postgres";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      local all all md5
      host all all 127.0.0.1/32 md5
      host all all ::1/128 md5
    '';
    settings = {
      listen_addresses = "localhost";
      port = 5432;
    };
    initialScript = pkgs.writeText "backend-initScript" ''
      ALTER USER postgres PASSWORD 'postgres';
    '';
  };

  environment.systemPackages = pkgs.callPackage ./packages.nix { };

  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    persistent = true;
    dates = "03:00";
    operation = "switch";
    flags = [ "--impure" "-L" ];
    flake = "/etc/nixos#home-dell";
  };
}
