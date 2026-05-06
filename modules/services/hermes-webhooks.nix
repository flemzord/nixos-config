{ config, lib, pkgs, ... }:

let
  cfg = config.services.hermes-agent;
  webhookPort = 8644;
  obsidianVault = "${cfg.stateDir}/Documents/Obsidian Vault";

  obsidianIngestCodex = pkgs.writeShellApplication {
    name = "hermes-obsidian-ingest-codex";
    runtimeInputs = [
      pkgs.codex
      pkgs.coreutils
    ];
    text = ''
      set -euo pipefail

      if [ "$#" -ne 1 ]; then
        echo "Usage: hermes-obsidian-ingest-codex <https-url>" >&2
        exit 64
      fi

      url="$1"
      case "$url" in
        http://*|https://*) ;;
        *)
          echo "Refusing non-HTTP(S) URL" >&2
          exit 65
          ;;
      esac

      case "$url" in
        *[[:space:]]*)
          echo "Refusing URL containing whitespace" >&2
          exit 66
          ;;
      esac

      export HOME=${cfg.stateDir}
      export CODEX_HOME=${cfg.stateDir}/.codex
      export OBSIDIAN_VAULT_PATH="${obsidianVault}"

      install -d -m 700 "$CODEX_HOME" "${obsidianVault}"

      exec codex exec \
        --cd "${obsidianVault}" \
        --sandbox workspace-write \
        -c 'approval_policy="never"' \
        --skip-git-repo-check \
        "\$ingest $url"
    '';
  };
  hermesWebhookCaddyConfig = ''
    route {
      @hermes_webhooks path /webhooks/* /health
      reverse_proxy @hermes_webhooks 127.0.0.1:${toString webhookPort}
      respond 404
    }
  '';
in
{
  age.secrets.hermes-webhook-env = {
    file = ../../secrets/hermes-webhook-env.age;
    owner = cfg.user;
    inherit (cfg) group;
    mode = "0400";
  };

  environment.systemPackages = [ obsidianIngestCodex ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services = {
    caddy = {
      enable = true;
      globalConfig = ''
        auto_https disable_redirects
      '';
      virtualHosts = {
        "ai.maireaux.fr".extraConfig = hermesWebhookCaddyConfig;
        "http://ai.maireaux.fr".extraConfig = hermesWebhookCaddyConfig;
      };
    };

    hermes-agent = lib.mkIf cfg.enable {
      environment = {
        OBSIDIAN_VAULT_PATH = obsidianVault;
        WEBHOOK_ENABLED = "true";
        WEBHOOK_PORT = toString webhookPort;
      };
      environmentFiles = [
        config.age.secrets.hermes-webhook-env.path
      ];
      extraPackages = [ obsidianIngestCodex ];
      settings.platforms.webhook = {
        enabled = true;
        extra = {
          port = webhookPort;
          routes.obsidian-ingest = {
            description = "Apple Shortcut entrypoint for ingesting a URL into the Hermes Obsidian vault via Codex CLI.";
            deliver = "telegram";
            events = [ ];
            prompt = ''
              Ingestion Obsidian demandée depuis le webhook Apple Shortcut.

              URL: {url}

              Lance le flux Codex CLI préparé en exécutant cette commande, sans afficher de secrets:

              ```sh
              hermes-obsidian-ingest-codex {url}
              ```

              Le wrapper lance Codex dans `${obsidianVault}` avec le prompt `$ingest URL` afin de charger le skill d'ingestion Obsidian. Résume ensuite brièvement le résultat.
            '';
            skills = [
              "webhook-subscriptions"
              "obsidian"
              "codex"
            ];
          };
        };
      };
    };
  };
}
