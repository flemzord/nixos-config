---
name: github-pr-cycle
description: Run an end-to-end GitHub PR loop. Use when the user says /gh-pr-cycle, /gh-ship, /gh-pr-fix-comments, /gh-ci-watch, ship this PR, fix PR review comments, commit/push/open a PR, request re-review, or combine review comments, fixes, push, PR description, and CI watching.
---

# GitHub PR Cycle

## Overview

Use this skill to drive one practical GitHub pull request cycle from the current repo or a specified PR: orient, inspect comments/checks, make requested fixes when asked, commit, push, update or open the PR, and watch CI.

This is the merged workflow behind these command aliases:

- `/gh-pr-cycle [pr|branch] [--review] [--inline] [--fix] [--watch-ci] [--request-review]`
- `/gh-ship`
- `/gh-pr-fix-comments <pr>`
- `/gh-ci-watch <pr|branch>`
- `/review-pr-inline <pr>`
- `/triage-prs`

## Operating Rules

- Treat GitHub-facing text as public. Write PR descriptions, review comments, issue comments, and re-review requests in English unless the user explicitly asks otherwise.
- Reply to the user in French unless they ask for another language.
- Start with `git status --short`, current branch, remotes, `gh auth status`, and PR metadata if available.
- Preserve unrelated dirty work. Do not reset, checkout over, rebase, or overwrite user changes.
- Do not merge a PR unless the user explicitly asks for merge.
- Do not commit or push during a review-only request. Commit and push only when the prompt clearly asks to ship, fix, address comments, or watch/repair CI.
- If the repository asks for code intelligence checks, such as GitNexus impact or change detection, run them before edits and before committing where required.

## Mode Selection

Map the user's wording to the narrowest useful mode:

- Ship mode: `/gh-ship`, "ship", "commit/push/open PR". Commit the intended diff, push, create or update the PR, write the PR description, then watch CI.
- Fix-comments mode: `/gh-pr-fix-comments <pr>`, "address review comments". Read unresolved review threads, implement actionable fixes, commit, push, resolve only demonstrably fixed threads, and request re-review when appropriate.
- CI mode: `/gh-ci-watch <pr|branch>`, "watch CI". Monitor checks and repair failures attributable to the branch.
- Inline-review mode: `/review-pr-inline <pr>`, "review and comment inline". Review the diff and post actionable inline comments in English when posting is requested.
- Triage mode: `/triage-prs`. Summarize PRs needing attention without mutating anything unless the user then asks for a specific action.
- Full cycle: `/gh-pr-cycle`. Combine the requested flags; if no flags are supplied, orient, summarize state, fix clearly actionable blockers on the current branch, push, and watch CI.

## Workflow

1. Establish scope.
   - Resolve repo, owner, PR number, base branch, head branch, current local branch, and whether the local checkout matches the PR head.
   - Prefer the GitHub connector when it gives complete PR/review metadata; use `gh` for checks, logs, patch context, and operations not covered by the connector.

2. Build the action list.
   - Read PR description, changed files, review decision, unresolved review threads, latest checks, and requested reviewers.
   - Separate actionable branch issues from external failures, stale comments, or questions needing user/product input.

3. Execute only the requested mutations.
   - For code edits, keep patches surgical and aligned with the repo's existing style.
   - Run the repo's relevant formatter, tests, lint, or targeted validation before commit.
   - Use Conventional Commit style when the repo requires it.

4. Update GitHub.
   - Push the branch after a clean local validation pass.
   - Create or update the PR description with concise English context: what changed, validation, risk, and follow-up.
   - Resolve review threads only when the exact concern is fixed or clearly obsolete.
   - Request re-review only after pushing changes that address requested changes.

5. Watch CI.
   - Wait for new checks to appear after push.
   - If a check fails, fetch the failed logs, identify whether the failure belongs to this branch, and fix only branch-attributable failures.
   - Stop and report when the failure is infrastructure, credentials, flaky external dependency, or the same unknown failure repeats.

## Final Report

End with a compact French summary:

- PR link and branch.
- Commits pushed or confirmation that no mutation was made.
- Review threads resolved or left open.
- CI state and any failing check names.
- Commands run and anything the user must decide.
