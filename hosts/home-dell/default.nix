{ config, modulesPath, pkgs, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
    ./../../modules/profiles/nixos/common.nix
    ./../../modules/services/samba.nix
    ./../../modules/services/transmission.nix
    ./../../modules/services/home-assistant.nix
    ./../../modules/services/cloudflared.nix
    ./../../modules/services/paperclipai.nix
    ./../../modules/services/postgresql.nix
  ];

  # Bootloader
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "home-dell";

  environment.systemPackages = pkgs.callPackage ./packages.nix { };

  services.nixos-auto-update = {
    enable = true;
    hostname = "home-dell";
  };

  services.paperclipai.enable = true;

  age.secrets.hermes-telegram = {
    file = ../../secrets/hermes-telegram.age;
    owner = "hermes";
    group = "hermes";
    mode = "0400";
  };

  services.hermes-agent = {
    enable = true;
    settings.model.default = "gpt-5.4";
    environmentFiles = [
      config.age.secrets.openai-api-key.path
      config.age.secrets.hermes-telegram.path
    ];
    addToSystemPackages = true;
  };

  system.stateVersion = "25.11";
}
