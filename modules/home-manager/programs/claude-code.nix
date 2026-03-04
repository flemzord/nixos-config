{ pkgs, config, ... }:

let
  ralphLoopScriptsDir = "${config.home.homeDirectory}/.claude/scripts/ralph-loop";
in
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code; # From claude-code-nix overlay

    memory.text = ''
      ## Language Preferences
      - **Chat/Communication**: Always respond in French (Français)
      - **Code**: Always write code, comments, variable names, and documentation in English

      ## Workflow Orchestration

      ### 1. Plan Mode Default
      - Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
      - If something goes sideways, STOP and re-plan immediately — don't keep pushing
      - Use plan mode for verification steps, not just building
      - Write detailed specs upfront to reduce ambiguity

      ### 2. Subagent Strategy
      - Use subagents liberally to keep main context window clean
      - Offload research, exploration, and parallel analysis to subagents
      - For complex problems, throw more compute at it via subagents
      - One task per subagent for focused execution

      ### 3. Task & Team Management
      - **Always create Tasks** (TaskCreate) for any work involving 2+ steps
      - **Always create Teams** (TeamCreate) when a task benefits from parallel agent work
      - Structure tasks with clear subjects, descriptions, and activeForm labels
      - Set up dependencies (blocks/blockedBy) when tasks have ordering requirements
      - Mark tasks in_progress BEFORE starting, completed AFTER verifying
      - For Teams: create team first, define all tasks, spawn teammates with appropriate agent types
      - Prefer specialized agents: Explore for research, general-purpose for implementation
      - Use TaskList regularly to track progress and find next available work

      ### 4. Self-Improvement Loop
      - After ANY correction from the user: update `tasks/lessons.md` with the pattern
      - Write rules for yourself that prevent the same mistake
      - Ruthlessly iterate on these lessons until mistake rate drops
      - Review lessons at session start for relevant project

      ### 5. Verification Before Done
      - Never mark a task complete without proving it works
      - Diff behavior between main and your changes when relevant
      - Ask yourself: "Would a staff engineer approve this?"
      - Run tests, check logs, demonstrate correctness

      ### 6. Demand Elegance (Balanced)
      - For non-trivial changes: pause and ask "is there a more elegant way?"
      - If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
      - Skip this for simple, obvious fixes — don't over-engineer
      - Challenge your own work before presenting it

      ### 7. Autonomous Bug Fixing
      - When given a bug report: just fix it. Don't ask for hand-holding
      - Point at logs, errors, failing tests — then resolve them
      - Zero context switching required from the user
      - Go fix failing CI tests without being told how

      ## Task Management
      1. **Plan First**: Write plan to `tasks/todo.md` with checkable items
      2. **Verify Plan**: Check in before starting implementation
      3. **Track Progress**: Mark items complete as you go
      4. **Explain Changes**: High-level summary at each step
      5. **Document Results**: Add review section to `tasks/todo.md`
      6. **Capture Lessons**: Update `tasks/lessons.md` after corrections

      ## Core Principles
      - **Simplicity First**: Make every change as simple as possible. Impact minimal code.
      - **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
      - **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
    '';

    settings = {
      includeCoAuthoredBy = false;
      model = "opus[1m]";
      alwaysThinkingEnabled = true;
      skipDangerousModePermissionPrompt = true;
      statusLine = {
        type = "command";
        command = "bun x ccusage statusline";
      };
      enabledPlugins = {
        "formance-skills@formance-plugins" = true;
      };
      mcpServers = {
        chrome-devtools = {
          command = "npx";
          args = [ "-y" "chrome-devtools-mcp@latest" ];
        };
      };
    };

    commands = {
      "loop-review" = ''
        Launch a collaborative review loop between Claude and OpenAI Codex to find and fix issues in the codebase, then commit the fixes.

        ## Configuration
        - **Model**: `gpt-5.3-codex`
        - **Reasoning effort**: `high`
        - **Sandbox**: `read-only`
        - Always use `--skip-git-repo-check`
        - Always append `2>/dev/null` to suppress thinking tokens

        ## Process

        ### Phase 1 — Initial Analysis
        1. Identify the scope of the review:
           - If on a feature branch: review all changes vs the base branch (`git diff main...HEAD`)
           - If on main: review recently modified files (`git diff HEAD~3...HEAD`) or staged changes
           - If the user specified files or directories, focus on those
        2. Summarize the scope to the user before proceeding.

        ### Phase 2 — Codex Review
        3. Send the code to Codex for review:
           ```bash
           echo "Review the following code changes for bugs, security issues, performance problems, and code quality. Be specific about file paths and line numbers. Here are the changes:\n\n$(git diff main...HEAD || git diff HEAD~3...HEAD)" | codex exec --skip-git-repo-check -m gpt-5.3-codex --config model_reasoning_effort="high" --sandbox read-only 2>/dev/null
           ```
        4. Capture and parse Codex's review output.

        ### Phase 3 — Claude Evaluation
        5. Critically evaluate each issue Codex found:
           - **Agree**: If the issue is valid, plan the fix.
           - **Disagree**: If you believe Codex is wrong, challenge it by resuming the session:
             ```bash
             echo "This is Claude (your current model) following up. I disagree with [issue] because [reasoning]. Let's discuss." | codex exec --skip-git-repo-check resume --last 2>/dev/null
             ```
           - **Need more context**: Research using your own tools (Read, Grep, etc.) before deciding.
        6. Repeat the discussion with Codex until both AIs converge on the list of real issues.

        ### Phase 4 — Fix & Commit
        7. For each confirmed issue:
           a. Fix the code.
           b. Verify the fix doesn't break anything (run tests if available).
        8. Stage only the changed files and create a single commit summarizing all review fixes:
           ```
           fix: address issues found during Claude-Codex collaborative review

           - [list each fix briefly]
           ```
        9. Present a summary to the user with:
           - Issues found (and by whom)
           - Issues where Claude and Codex disagreed (and resolution)
           - Changes made
           - Any remaining concerns that need human judgment

        ## Rules
        - **Never ask the user for model/sandbox config** — always use `gpt-5.3-codex`, `high`, `read-only`.
        - **Treat Codex as a peer, not an authority** — challenge wrong suggestions.
        - **Be surgical**: only fix confirmed issues, don't refactor unrelated code.
        - **Each review round should converge** — max 3 back-and-forth exchanges with Codex per issue.
        - **Always show the user what both AIs think** before committing.
        - **Do NOT push** — only commit locally. The user decides when to push.
      '';

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

    agents = {
      "codex-review.md" = ''
        ---
        name: codex-review
        description: Use when the user asks to review code with Codex, run a Codex review, or get a second opinion from Codex on code quality, bugs, or security issues.
        ---

        # Codex Review Agent

        You are a code review coordinator that leverages OpenAI Codex as a second pair of eyes. You run Codex in read-only mode to analyze code and provide a collaborative review.

        ## Fixed Configuration
        - **Model**: `gpt-5.3-codex`
        - **Reasoning effort**: `high`
        - **Sandbox**: `read-only`
        - Always use `--skip-git-repo-check`
        - Always append `2>/dev/null` to suppress thinking tokens
        - **Never ask the user** for model, reasoning effort, or sandbox mode — these are always fixed.

        ## Running a Review

        1. **Determine the review scope**:
           - Check `git status` and `git diff` to understand what has changed
           - If on a feature branch, diff against the base branch
           - If the user specified files, focus on those
           - Summarize the scope before running Codex

        2. **Send to Codex for review**:
           ```bash
           echo "<review prompt with code context>" | codex exec --skip-git-repo-check -m gpt-5.3-codex --config model_reasoning_effort="high" --sandbox read-only 2>/dev/null
           ```

        3. **Evaluate Codex's findings**:
           - For each issue Codex raises, assess it critically using your own knowledge
           - Cross-reference with the actual codebase (read files, check dependencies)
           - Categorize findings: **confirmed**, **disputed**, **needs investigation**

        4. **Handle disagreements**:
           - If you disagree with Codex, resume the session to discuss:
             ```bash
             echo "This is Claude following up. I disagree with [X] because [evidence]. What's your take?" | codex exec --skip-git-repo-check resume --last 2>/dev/null
             ```
           - Max 3 exchanges per disagreement, then present both viewpoints to the user

        5. **Present results to the user**:
           - Organized list of findings with severity (critical / warning / suggestion)
           - For each finding: file path, line number, description, and who found it
           - Any disagreements between Claude and Codex with both perspectives
           - Recommended actions

        ## Critical Evaluation Guidelines

        - **Trust your own knowledge** when confident — Codex can be wrong
        - **Research disagreements** using WebSearch or docs before accepting Codex claims
        - **Remember knowledge cutoffs** — Codex may not know about recent changes
        - **Don't defer blindly** — evaluate suggestions critically, especially for:
          - Model names and capabilities
          - Recent library versions or API changes
          - Best practices that may have evolved

        ## Rules
        - This agent is **read-only** — it never modifies code. Use `/loop-review` if you want automatic fixes.
        - Always provide actionable feedback, not vague suggestions.
        - Group related issues together for clarity.
        - If Codex fails or returns an error, report it and fall back to Claude-only review.
      '';


    };
  };
}
