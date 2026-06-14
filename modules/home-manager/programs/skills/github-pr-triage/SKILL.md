---
name: github-pr-triage
description: Triage GitHub pull requests into an action queue. Use when the user says /triage-prs, quels PR je dois traiter, summarize my PRs, find PRs needing review, find failing/stale PRs, or prioritize GitHub PR work.
---

# GitHub PR Triage

## Overview

Use this skill to scan GitHub PRs and return a prioritized action queue. It is read-only by default.

## Rules

- Do not edit, comment, request review, approve, close, merge, commit, or push during triage.
- Prefer PRs where the user is author, reviewer, requested reviewer, or directly mentioned.
- Treat GitHub-facing follow-up drafts as English by default; user-facing summary stays French.
- Call out stale automation noise separately from human-blocking work.

## Workflow

1. Establish scope.
   - Determine organization/repo filters from the prompt or current checkout.
   - If no scope is given, start with the current repo and then ask only if broader account-level triage is required.

2. Collect PR state.
   - Open PRs authored by the user.
   - Review requests assigned to the user.
   - PRs with requested changes, unresolved comments, failing checks, merge conflicts, or stale approvals.
   - Draft PRs only when they appear blocked or recently active.

3. Prioritize.
   - P0: user is blocking someone else, production or release impact, urgent review request.
   - P1: user's PR needs action, failing CI, requested changes, unresolved comments.
   - P2: stale but not urgent, waiting on others, draft cleanup.
   - FYI: no action needed.

4. Return next actions.
   - Include PR title, repo, link, author, state, why it matters, and recommended next command.
   - Recommend `/gh-pr-cycle`, `/gh-pr-fix-comments`, `/gh-ci-watch`, or `/review-pr-inline` when a PR is ready for action.

## Output Shape

Use concise French sections:

- `A traiter maintenant`
- `A surveiller`
- `En attente de quelqu'un d'autre`
- `Aucune action`
