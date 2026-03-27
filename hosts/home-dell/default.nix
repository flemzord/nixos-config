{ modulesPath, pkgs, ... }:

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
  ];

  # Bootloader
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "home-dell";

  environment.systemPackages = pkgs.callPackage ./packages.nix { };

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

  services.nixos-auto-update = {
    enable = true;
    hostname = "home-dell";
  };

  system.stateVersion = "25.11";
}
