{ pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code; # From claude-code-nix overlay

    settings = {
      awsAuthRefresh = "aws sso login";
      env = {
        AWS_PROFILE = "staging-FormanceBedrockAccess";
        AWS_REGION = "eu-west-1";
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
        # CLAUDE_CODE_USE_BEDROCK=  "1";
        CLAUDE_CODE_ENABLE_TELEMETRY = "1";      
        OTEL_EXPORTER_OTLP_ENDPOINT = "https://claude.internal.frmnc.net";
        OTEL_EXPORTER_OTLP_PROTOCOL = "http/protobuf";
        OTEL_METRICS_EXPORTER = "otlp";
        OTEL_METRIC_EXPORT_INTERVAL = "10000";
        OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE = "cumulative";
        OTEL_RESOURCE_ATTRIBUTES = "user=$USER";
      };
      includeCoAuthoredBy = false;
      model = "eu.anthropic.claude-opus-4-6-v1[1m]";
      alwaysThinkingEnabled = true;
      skipDangerousModePermissionPrompt = true;
      statusLine = {
        type = "command";
        command = "node /Users/flemzord/.claude/hud/omc-hud.mjs";
      };
      enabledPlugins = {
        #"formance-skills@formance-plugins" = true;
        "gopls-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
        "oh-my-claudecode@omc" = true;
      };
      mcpServers = {
        chrome-devtools = {
          command = "npx";
          args = [ "-y" "chrome-devtools-mcp@latest" ];
        };
        kipli = {
          type = "url";
          url = "https://mcp.kipli.dev/mcp";
        };
      };
    };


    commands = {
      "ci-watch" = ''
        Watch the CI pipeline for the current branch and ensure it passes.
        Use the GitHub CLI (`gh`) to monitor workflow runs.

        ## Process

        1. **Identify the current branch** with `git branch --show-current`
        2. **Get the latest workflow run** for this branch:
           ```
           gh run list --branch <branch> --limit 1 --json databaseId,status,conclusion
           ```
        3. **Watch the run in real-time** until it completes:
           ```
           gh run watch <run-id> --exit-status
           ```
        4. **If the run succeeds** (exit code 0): report success and stop.
        5. **If the run fails**:
           a. Retrieve the failed job logs:
              ```
              gh run view <run-id> --log-failed
              ```
           b. Analyze the errors and fix the code.
           c. Commit the fix with a clear message describing what was fixed.
           d. Push to the current branch.
           e. Wait a few seconds for the new run to be triggered, then go back to step 2.

        ## Rules

        - **Never give up**: keep looping until CI is fully green.
        - **Each fix should be a separate commit** with a descriptive message.
        - **Be surgical**: only change what is needed to fix the failing step.
        - **If stuck after 5 consecutive failed attempts on the same error**, stop and ask the user for guidance.
      '';
    };
  };
}
