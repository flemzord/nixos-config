{ pkgs, ... }:

{
  programs.codex = {
    enable = true;
    package = pkgs.codex; # From codex-cli-nix overlay

    settings = {
      model = "gpt-5.5";
      model_reasoning_effort = "high";
      personality = "pragmatic";
      approval_mode = "full-auto";
      model_context_window = 1000000;
      model_auto_compact_token_limit = 9000000;
      plan_mode_reasoning_effort = "high";

      projects = {
        "/Users/flemzord/Project" = {
          trust_level = "trusted";
        };
        "/Users/flemzord/Developer/Formance/BankingBridge" = {
          trust_level = "trusted";
        };
        "/Users/flemzord/Developer/Formance/control-plane" = {
          trust_level = "trusted";
        };
        "/Users/flemzord/Developer/Formance/infra2" = {
          trust_level = "trusted";
        };
        "/Users/flemzord/Developer/Formance/internal-skills" = {
          trust_level = "trusted";
        };
        "/Users/flemzord/Developer/Formance/tmp/temporal" = {
          trust_level = "trusted";
        };
        "/Users/flemzord/Documents/Codex/2026-05-04/j-aimerais-dans-atlassian-rovo-plugin" = {
          trust_level = "trusted";
        };
        "/Users/flemzord/Documents/Codex/2026-05-04/slack-plugin-slack-openai-curated-atlassian" = {
          trust_level = "trusted";
        };
        "/Users/flemzord/Library/Mobile Documents/iCloud~md~obsidian/Documents/default" = {
          trust_level = "trusted";
        };
        "/Users/flemzord" = {
          trust_level = "trusted";
        };
        tui = {
          notification_condition = "always";
        };
      };

      suppress_unstable_features_warning = true;

      features = {
        ghost_commit = false;
        unified_exec = true;
        apply_patch_freeform = true;
        skills = true;
        shell_snapshot = true;
        multi_agent = true;
        goals = true;
      };

      plugins = {
        "atlassian-rovo@openai-curated" = {
          enabled = true;
        };
        "build-ios-apps@openai-curated" = {
          enabled = true;
        };
        "build-web-apps@openai-curated" = {
          enabled = true;
        };
        "expo@openai-curated" = {
          enabled = true;
        };
        "notion@openai-curated" = {
          enabled = true;
        };
        "slack@openai-curated" = {
          enabled = true;
        };
      };

      tui = {
        model_availability_nux = {
          "gpt-5.5" = 4;
        };
      };

      mcpServers = {
        "deepwiki" = {
          url = "https://mcp.deepwiki.com/mcp";
        };
        "grafana" = {
          url = "https://grafana-mcp.internal.frmnc.net/sse";
        };
        "signoz" = {
          url = "https://mcp.eu.signoz.cloud/mcp";
          http_headers = {
            "SIGNOZ-API-KEY" = "w+/PKkx450JxNlYaonkxcBV8qYaogz4dY4mmNRnJrDo=";
            "X-SigNoz-URL" = "https://light-monster.eu.signoz.cloud";
          };
        };
      };
    };
  };
}
