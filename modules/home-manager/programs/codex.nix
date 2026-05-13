{ pkgs, ... }:

let
  vibeIslandHook = {
    type = "command";
    command = "'/Users/flemzord/.vibe-island/bin/vibe-island-bridge' --source codex";
    timeout = 5;
  };
in
{
  home.file.".codex/hooks.json" = {
    force = true;
    source = (pkgs.formats.json { }).generate "codex-hooks" {
      hooks = {
        PermissionRequest = [
          {
            hooks = [ (vibeIslandHook // { timeout = 7200; }) ];
          }
        ];
        SessionStart = [
          {
            hooks = [ vibeIslandHook ];
          }
        ];
        Stop = [
          {
            hooks = [ vibeIslandHook ];
          }
        ];
        UserPromptSubmit = [
          {
            hooks = [ vibeIslandHook ];
          }
        ];
      };
    };
  };

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
      };

      suppress_unstable_features_warning = true;

      features = {
        hooks = true;
        ghost_commit = false;
        unified_exec = true;
        apply_patch_freeform = true;
        skills = true;
        shell_snapshot = true;
        multi_agent = true;
        goals = true;
        remote_connections = true;
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
        notification_condition = "always";
        model_availability_nux = {
          "gpt-5.5" = 4;
        };
      };

      hooks = {
        state = {
          "/Users/flemzord/.codex/hooks.json:permission_request:0:0" = {
            trusted_hash = "sha256:3d0061a85ea39d6d3bfa6e219ab698d8b9017b20eddb8f5783a0c225faf6cc45";
          };
          "/Users/flemzord/.codex/hooks.json:session_start:0:0" = {
            trusted_hash = "sha256:30bc73920013cd895f3d537af2b7f5fdedf936ac3cf2e4af06de83a48781cac3";
          };
          "/Users/flemzord/.codex/hooks.json:user_prompt_submit:0:0" = {
            trusted_hash = "sha256:2f07185689937c0f02741b133ae69523d07576132c0b62f943c46bf9ad90f7ea";
          };
          "/Users/flemzord/.codex/hooks.json:stop:0:0" = {
            trusted_hash = "sha256:b66b86f080b1a83be573b46d9faf799a57cd1610bf9f635ffb7f5922421267d0";
          };
        };
      };

      mcp_servers = {
        "deepwiki" = {
          url = "https://mcp.deepwiki.com/mcp";
        };
        "grafana" = {
          command = "npx";
          args = [
            "-y"
            "mcp-remote"
            "https://grafana-mcp.internal.frmnc.net/sse"
          ];
        };
        "gitnexus" = {
          command = "npx";
          args = [
            "-y"
            "gitnexus@1.6.5-rc.9"
            "mcp"
          ];
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
