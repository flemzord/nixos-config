{ config, lib, ... }:

{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./../../modules/profiles/nixos/common.nix
    ./../../modules/profiles/nixos/dev.nix
    ./../../modules/services/postgresql.nix
  ];

  # Bootloader — UEFI on Hetzner Cloud ARM vServer
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "server-dev";

  # Use systemd-networkd; disable NetworkManager from the common profile
  networking.networkmanager.enable = lib.mkForce false;

  services.nixos-auto-update = {
    enable = true;
    hostname = "server-dev";
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

  services.hermes-agent = {
    enable = true;
    settings.model = {
      provider = "custom";
      default = "gpt-5.4";
      base_url = "https://api.openai.com/v1";
    };
    environmentFiles = [
      config.age.secrets.openai-api-key.path
      config.age.secrets.hermes-env.path
    ];
    addToSystemPackages = true;
    mcpServers.github = {
      command = "npx";
      args = [ "-y" "@modelcontextprotocol/server-github" ];
      env.GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_PERSONAL_ACCESS_TOKEN}";
    };
    mcpServers.deepwiki = {
      url = "https://mcp.deepwiki.com/mcp";
    };
  };

  system.stateVersion = "25.11";
}
