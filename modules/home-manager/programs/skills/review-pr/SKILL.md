---
name: review-pr
description: Perform an exhaustive, step-by-step pull request review. Use when the user asks to review a PR, audit a PR, inspect a pull request before production, find potential problems, or create/update REVIEW.md with findings. Focus on validated issues including dead code, races, architecture problems, regressions, missing tests, rollout risks, and production-readiness concerns, using GitNexus when available.
---

# Review PR

## Overview

Use this skill to review a pull request deeply and incrementally. The goal is to find real, actionable problems, validate each one from source context, and keep a running `REVIEW.md` document with the full review record.

## Review Workflow

1. Identify the PR scope.
   - Determine the base branch, head branch, changed files, and commits.
   - If the user provided a PR number or URL, fetch the PR metadata and diff with the available GitHub tools or `gh`.
   - If the branch is already checked out, use `git status`, `git branch --show-current`, `git merge-base`, `git diff --stat`, and targeted diffs to establish scope.
   - Preserve unrelated local changes. Do not reset or overwrite user work.

2. Initialize `REVIEW.md` immediately.
   - Create or update the file before the review is complete.
   - Track scope, commands run, files reviewed, GitNexus results, findings, open questions, and investigated non-issues.
   - Keep appending or refining as evidence changes; do not wait until the final answer.

3. Use GitNexus for code intelligence.
   - If GitNexus reports a stale index, run `npx gitnexus analyze` before relying on results.
   - Run change detection for the PR diff when possible, using the base ref or current uncommitted/staged scope.
   - For changed symbols, use impact analysis upstream and context views to identify direct callers, affected flows, modules, and blast radius.
   - Use GitNexus query for unfamiliar concepts, cross-cutting flows, or architecture questions.
   - Use API impact or shape checks when API handlers, routes, clients, response contracts, or generated types are touched.
   - Record high-risk or surprising GitNexus results in `REVIEW.md`, even when they become open questions rather than findings.

4. Build a review map before judging.
   - Read the PR description, linked issue/spec when available, changed files, tests, migrations, config, generated files, and dependency changes.
   - Group changes by behavior or subsystem instead of only by file.
   - Identify expected runtime flows and production rollout path.

5. Audit in focused passes.
   - Correctness: edge cases, invariants, error paths, backwards compatibility, idempotency, partial failures.
   - Dead code: unreachable branches, unused exported APIs, stale flags, unused config, duplicated logic, dead migrations, generated drift.
   - Concurrency and races: async lifecycle, shared mutable state, locks, goroutines/tasks, cancellation, retries, transactions, cache invalidation, ordering assumptions.
   - Architecture: ownership boundaries, layering, API contracts, data model fit, coupling, long-term maintenance risks.
   - Production readiness: rollout safety, feature flags, migrations/backfills, observability, alerts, logging, metrics, operational recovery, performance and scaling.
   - Security and privacy: authn/authz, input validation, secret handling, tenant isolation, injection, data exposure.
   - Tests: missing regression tests, insufficient fixtures, nondeterministic tests, coverage of failures and migrations.

6. Validate every finding before writing it as a finding.
   - Re-read the surrounding code and callers.
   - Check the relevant execution path, tests, config, and runtime assumptions.
   - Prefer reproduction via tests, typecheck, lint, local commands, or small targeted scripts when feasible.
   - Do not include speculative concerns as findings. Move uncertain items to open questions or investigated non-issues.
   - Include exact file and line references for each finding.

7. Keep iterating.
   - Revisit earlier conclusions after reading later files.
   - Search for existing patterns before calling something inconsistent.
   - Compare old and new behavior from the diff, not just the final code.
   - Do at least one final pass over all findings to verify severity, evidence, and recommendation.

## REVIEW.md Structure

Use this structure unless the repository already has a stronger review template:

```markdown
# PR Review

## Scope
- PR:
- Base:
- Head:
- Reviewed at:

## Summary
- Overall risk:
- Main areas touched:
- Production-readiness notes:

## GitNexus
- Change detection:
- Impact analysis:
- Affected flows:

## Findings

### [Severity] Finding title
- Location: `path/to/file.ext:line`
- Impact:
- Evidence:
- Recommendation:
- Validation:

## Open Questions
- Question, owner/context, and why it matters.

## Investigated And Cleared
- Concern checked, evidence reviewed, and why it is not a finding.

## Checks Run
- Command/tool and result.

## Files And Flows Reviewed
- Files, symbols, processes, routes, migrations, configs, or tests reviewed.
```

Severity guidance:

- Critical: likely production outage, data loss, security breach, or migration breakage.
- High: likely user-visible regression, correctness issue, race, data inconsistency, or unsafe rollout.
- Medium: plausible bug or maintainability issue with bounded blast radius.
- Low: small correctness, test, observability, or cleanup issue worth addressing.

## Reporting Back

Lead with findings, ordered by severity. If no valid findings remain after validation, state that clearly and mention residual risk or test gaps. Summarize commands run and the final `REVIEW.md` location.
