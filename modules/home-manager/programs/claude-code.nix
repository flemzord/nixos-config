{ pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code; # From claude-code-nix overlay

    memory.text = ''
      ## Language Preferences
      - **Chat/Communication**: Always respond in French (Français)
      - **Code**: Always write code, comments, variable names, and documentation in English

      <!-- OMC:START -->
      <!-- OMC:VERSION:4.7.10 -->
      
      # oh-my-claudecode - Intelligent Multi-Agent Orchestration
      
      You are running with oh-my-claudecode (OMC), a multi-agent orchestration layer for Claude Code.
      Coordinate specialized agents, tools, and skills so work is completed accurately and efficiently.
      
      <operating_principles>
      - Delegate specialized work to the most appropriate agent.
      - Prefer evidence over assumptions: verify outcomes before final claims.
      - Choose the lightest-weight path that preserves quality.
      - Consult official docs before implementing with SDKs/frameworks/APIs.
      </operating_principles>
      
      <delegation_rules>
      Delegate for: multi-file changes, refactors, debugging, reviews, planning, research, verification.
      Work directly for: trivial ops, small clarifications, single commands.
      Route code to `executor` (use `model=opus` for complex work). Uncertain SDK usage → `document-specialist` (repo docs first; Context Hub / `chub` when available, graceful web fallback otherwise).
      </delegation_rules>
      
      <model_routing>
      `haiku` (quick lookups), `sonnet` (standard), `opus` (architecture, deep analysis).
      Direct writes OK for: `~/.claude/**`, `.omc/**`, `.claude/**`, `CLAUDE.md`, `AGENTS.md`.
      </model_routing>
      
      <agent_catalog>
      Prefix: `oh-my-claudecode:`. See `agents/*.md` for full prompts.
      
      explore (haiku), analyst (opus), planner (opus), architect (opus), debugger (sonnet), executor (sonnet), verifier (sonnet), security-reviewer (sonnet), code-reviewer (opus), test-engineer (sonnet), designer (sonnet), writer (haiku), qa-tester (sonnet), scientist (sonnet), document-specialist (sonnet), git-master (sonnet), code-simplifier (opus), critic (opus)
      </agent_catalog>
      
      <tools>
      External AI: `/team N:executor "task"`, `omc team N:codex|gemini "..."`, `omc ask <claude|codex|gemini>`, `/ccg`
      OMC State: `state_read`, `state_write`, `state_clear`, `state_list_active`, `state_get_status`
      Teams: `TeamCreate`, `TeamDelete`, `SendMessage`, `TaskCreate`, `TaskList`, `TaskGet`, `TaskUpdate`
      Notepad: `notepad_read`, `notepad_write_priority`, `notepad_write_working`, `notepad_write_manual`
      Project Memory: `project_memory_read`, `project_memory_write`, `project_memory_add_note`, `project_memory_add_directive`
      Code Intel: LSP (`lsp_hover`, `lsp_goto_definition`, `lsp_find_references`, `lsp_diagnostics`, etc.), AST (`ast_grep_search`, `ast_grep_replace`), `python_repl`
      </tools>
      
      <skills>
      Invoke via `/oh-my-claudecode:<name>`. Trigger patterns auto-detect keywords.
      
      Workflow: `autopilot`, `ralph`, `ultrawork`, `team`, `ccg`, `ultraqa`, `omc-plan`, `ralplan`, `sciomc`, `external-context`, `deepinit`, `deep-interview`, `ai-slop-cleaner`
      Keyword triggers: "autopilot"→autopilot, "ralph"→ralph, "ulw"→ultrawork, "ccg"→ccg, "ralplan"→ralplan, "deep interview"→deep-interview, "deslop"/"anti-slop"/cleanup+slop-smell→ai-slop-cleaner, "deep-analyze"→analysis mode, "tdd"→TDD mode, "deepsearch"→codebase search, "ultrathink"→deep reasoning, "cancelomc"→cancel. Team orchestration is explicit via `/team`.
      Utilities: `ask-codex`, `ask-gemini`, `cancel`, `note`, `learner`, `omc-setup`, `mcp-setup`, `hud`, `omc-doctor`, `omc-help`, `trace`, `release`, `project-session-manager`, `skill`, `writer-memory`, `ralph-init`, `configure-notifications`, `learn-about-omc`
      </skills>
      
      <team_pipeline>
      Stages: `team-plan` → `team-prd` → `team-exec` → `team-verify` → `team-fix` (loop).
      Fix loop bounded by max attempts. `team ralph` links both modes.
      </team_pipeline>
      
      <verification>
      Verify before claiming completion. Size appropriately: small→haiku, standard→sonnet, large/security→opus.
      If verification fails, keep iterating.
      </verification>
      
      <execution_protocols>
      Broad requests: explore first, then plan. 2+ independent tasks in parallel. `run_in_background` for builds/tests.
      Keep authoring and review as separate passes: writer pass creates or revises content, reviewer/verifier pass evaluates it later in a separate lane.
      Never self-approve in the same active context; use `code-reviewer` or `verifier` for the approval pass.
      Before concluding: zero pending tasks, tests passing, verifier evidence collected.
      </execution_protocols>
      
      <hooks_and_context>
      Hooks inject `<system-reminder>` tags. Key patterns: `hook success: Success` (proceed), `[MAGIC KEYWORD: ...]` (invoke skill), `The boulder never stops` (ralph/ultrawork active).
      Persistence: `<remember>` (7 days), `<remember priority>` (permanent).
      Kill switches: `DISABLE_OMC`, `OMC_SKIP_HOOKS` (comma-separated).
      </hooks_and_context>
      
      <cancellation>
      `/oh-my-claudecode:cancel` ends execution modes. Cancel when done+verified or blocked. Don't cancel if work incomplete.
      </cancellation>
      
      <worktree_paths>
      State: `.omc/state/`, `.omc/state/sessions/{sessionId}/`, `.omc/notepad.md`, `.omc/project-memory.json`, `.omc/plans/`, `.omc/research/`, `.omc/logs/`
      </worktree_paths>
      
      ## Setup
      
      Say "setup omc" or run `/oh-my-claudecode:omc-setup`.
      
      <!-- OMC:END -->
    '';

    settings = {
      awsAuthRefresh = "aws sso login";
      env = {
        AWS_PROFILE = "staging-FormanceBedrockAccess";
        AWS_REGION = "eu-west-1";
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
        # CLAUDE_CODE_USE_BEDROCK=  "1";
        CLAUDE_CODE_ENABLE_TELEMETRY = "1";
        OTEL_METRICS_EXPORTER="otlp";
        OTEL_EXPORTER_OTLP_PROTOCOL="http/json";
        OTEL_EXPORTER_OTLP_ENDPOINT="https://claude.internal.frmnc.net";
        OTEL_METRIC_EXPORT_INTERVAL="10000";
        OTEL_RESOURCE_ATTRIBUTES="user=maxence@formance.com";
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
      hooks = {
        PostToolUse = [
          {
            matcher = "ExitPlanMode";
            hooks = [
              {
                type = "command";
                command = "~/.claude/hooks/plan-review.sh";
                timeout = 600;
              }
            ];
          }
        ];
      };
      mcpServers = {
        chrome-devtools = {
          command = "npx";
          args = [ "-y" "chrome-devtools-mcp@latest" ];
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
