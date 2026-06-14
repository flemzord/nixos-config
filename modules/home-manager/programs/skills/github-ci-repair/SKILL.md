---
name: github-ci-repair
description: Watch GitHub Actions checks for a PR or branch, inspect failed logs, and repair branch-attributable CI failures. Use when the user says /gh-ci-watch, watch CI, fix failing GitHub checks, debug PR checks, or keep looping until the branch is green.
---

# GitHub CI Repair

## Overview

Use this skill to monitor GitHub Actions for a PR or branch and fix failures that belong to the code under review. The goal is a green branch, with clear stops for infrastructure or external failures.

## Rules

- Start read-only: identify the PR or branch, latest commit SHA, current checks, and whether a newer run is expected.
- Commit and push fixes only when the user asked to repair CI or ship the branch.
- Keep each fix surgical and attributable to a specific failed check.
- Do not hide, skip, or weaken tests unless the user explicitly approves and the reason is documented.
- Stop instead of guessing when the failure is credentials, hosted runner capacity, external service outage, missing secrets, or unrelated base-branch breakage.

## Workflow

1. Identify the target.
   - Use `gh pr view`, `gh pr checks`, `gh run list`, and current branch information.
   - Confirm the run SHA matches the branch head. Wait briefly if checks have not started after a push.

2. Inspect failures.
   - Prefer failed job logs over summaries.
   - Use `gh run view --log-failed` or equivalent connector data.
   - Extract the first actionable failure, not just the final cascade.

3. Repair locally.
   - Read the relevant code and tests.
   - Make the minimal branch fix.
   - Run the closest local validation command before committing.

4. Commit and push.
   - Use repo commit conventions.
   - Push the branch and watch the new run.
   - If a different failure appears, repeat from log inspection.

5. Stop conditions.
   - Same unexplained failure repeats after focused attempts.
   - Failure is outside branch control.
   - The fix needs product, security, migration, or release approval.

## Final Report

Report in French:

- Latest commit SHA and PR/branch.
- Check names and final state.
- Failed log evidence used.
- Fix commits pushed.
- Remaining blockers, if any.
