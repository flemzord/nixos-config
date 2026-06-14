{ pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code; # From claude-code-nix overlay

    commands = {
      "ci-watch" = ''
        Legacy alias for /gh-ci-watch.

        Use the $github-ci-repair skill on the current branch or PR. Watch
        GitHub checks, inspect failed logs, fix only branch-attributable
        failures, commit and push fixes when appropriate, and stop on external
        or infrastructure failures.
      '';

      "gh-ci-watch" = ''
        Use the $github-ci-repair skill.

        Target may be a PR number, PR URL, branch, or the current branch.
        Watch GitHub checks, inspect failed logs, fix branch-attributable
        failures, commit and push fixes, then continue until checks are green
        or a non-branch blocker is identified.
      '';

      "gh-pr-cycle" = ''
        Use the $github-pr-cycle skill.

        Target may be a PR number, PR URL, branch, or the current branch.
        Optional flags: --review, --inline, --fix, --watch-ci,
        --request-review.

        Run the merged PR loop: orient, inspect review comments and checks,
        make requested fixes when asked, commit, push, update or open the PR,
        and watch CI. Do not merge unless explicitly requested.
      '';

      "gh-pr-fix-comments" = ''
        Use the $github-pr-cycle skill in fix-comments mode.

        Read unresolved GitHub review threads and comments for the target PR,
        implement actionable fixes, run relevant validation, commit and push,
        resolve only threads that are demonstrably fixed, and request re-review
        when appropriate.
      '';

      "gh-ship" = ''
        Use the $github-pr-cycle skill in ship mode.

        Inspect the current worktree, commit the intended changes cleanly,
        push the branch, open or update the PR, write the PR description in
        English, then watch CI. Do not merge unless explicitly requested.
      '';

      "review-pr-inline" = ''
        Use the $github-inline-review skill.

        Review the target PR and prepare precise actionable inline comments.
        If the user asked to post them, submit the GitHub review comments in
        English. Do not edit, commit, push, or resolve threads in this mode.
      '';

      "triage-prs" = ''
        Use the $github-pr-triage skill.

        List and prioritize PRs needing attention: review requests, authored
        PRs with failing checks or requested changes, stale blockers, and PRs
        waiting on others. Keep this command read-only by default.
      '';
    };
  };
}
