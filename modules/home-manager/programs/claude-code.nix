{ pkgs, config, ... }:

{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code; # From claude-code-nix overlay

    settings = {
      "$schema" = "https://json.schemastore.org/claude-code-settings.json";
      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
        CLAUDE_CODE_NO_FLICKER = "1";
        CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = "1";
      };
      includeCoAuthoredBy = false;
      model = "opus[1m]";
      effortLevel = "high";
      alwaysThinkingEnabled = true;
      skipDangerousModePermissionPrompt = true;
      statusLine = {
        type = "command";
        command = "node /Users/flemzord/.claude/hud/omc-hud.mjs";
      };
      enabledPlugins = {
        "formance-skills@formance-plugins" = true;
        "gopls-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
        "oh-my-claudecode@omc" = true;
        "plannotator@plannotator" = true;
        "code-review@claude-plugins-official" = true;
        "code-simplifier@claude-plugins-official" = true;
        "pr-review-toolkit@claude-plugins-official" = true;
        "coderabbit@claude-plugins-official" = true;
        "posthog@claude-plugins-official" = true;
        "claude-code-setup@claude-plugins-official" = true;
        "claude-md-management@claude-plugins-official" = true;
        "security-guidance@claude-plugins-official" = true;
        "session-report@claude-plugins-official" = true;
        "commit-commands@claude-plugins-official" = true;
        "feature-dev@claude-plugins-official" = true;
        "hookify@claude-plugins-official" = true;
        "semgrep@claude-plugins-official" = true;
        "playground@claude-plugins-official" = true;
        "warp@claude-code-warp" = true;
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
        qmd = {
          command = "npx @tobilu/qmd -y";
          args = ["mcp"];
        };
        gitnexus = {
          command = "npx";
          args = [ "-y" "gitnexus@latest" "mcp" ];
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
