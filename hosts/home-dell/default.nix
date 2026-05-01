{ config
, modulesPath
, pkgs
, ...
}:

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
    ./../../modules/services/hermes-github-auth.nix
    ./../../modules/services/hermes-kanban.nix

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

  age.secrets.openai-api-key = {
    file = ../../secrets/openai-api-key.age;
    owner = "hermes";
    group = "hermes";
    mode = "0400";
  };

  age.secrets.hermes-env = {
    file = ../../secrets/hermes-env.age;
    owner = "hermes";
    group = "hermes";
    mode = "0400";
  };

  system.stateVersion = "25.11";
}
