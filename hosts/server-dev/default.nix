{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./../../modules/profiles/nixos/common.nix
    ./../../modules/profiles/nixos/dev.nix
    ./../../modules/services/hermes-github-auth.nix
    ./../../modules/services/hermes-kanban.nix
    ./../../modules/services/postgresql.nix
    ./../../modules/services/fail2ban.nix
  ];

  # Bootloader — UEFI on Hetzner Cloud ARM vServer
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "server-dev";

    # Use systemd-networkd; disable NetworkManager from the common profile
    networkmanager.enable = lib.mkForce false;
    firewall.enable = lib.mkForce true;
  };

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
      default = "gpt-5.5";
      base_url = "https://api.openai.com/v1";
    };
    environment = {
      CODEX_HOME = "${config.services.hermes-agent.stateDir}/.codex";
    };
    environmentFiles = [
      config.age.secrets.openai-api-key.path
      config.age.secrets.hermes-env.path
    ];
    extraPackages = [
      pkgs.codex
    ];
    addToSystemPackages = true;
    mcpServers.github = {
      command = "npx";
      args = [
        "-y"
        "@modelcontextprotocol/server-github"
      ];
      env = {
        GITHUB_PERSONAL_ACCESS_TOKEN = "$" + "{GITHUB_" + "TOKEN}";
      };
    };
    mcpServers.deepwiki = {
      url = "https://mcp.deepwiki.com/mcp";
    };
  };

  system.stateVersion = "25.11";
}
