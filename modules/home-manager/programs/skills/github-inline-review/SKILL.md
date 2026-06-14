---
name: github-inline-review
description: Review a GitHub pull request and prepare or post actionable inline review comments. Use when the user says /review-pr-inline, review + GitHub inline comments, comment this PR inline, or asks for review findings to be placed directly on a PR.
---

# GitHub Inline Review

## Overview

Use this skill for review-only GitHub PR feedback that should become precise inline comments. It is for finding real issues and placing them on the affected lines, not for fixing the branch.

## Rules

- Write GitHub comments in English by default.
- Reply to the user in French by default.
- Do not edit files, commit, push, resolve threads, or request re-review during an inline-review task unless the user explicitly asks for that follow-up.
- Avoid duplicate comments. Check existing review threads before posting.
- Only post actionable, validated findings. Put uncertain concerns in the chat summary instead of GitHub.

## Workflow

1. Resolve PR context.
   - Identify owner, repo, PR number, base/head branches, changed files, and existing review comments.
   - Fetch the PR diff and line mapping with the GitHub connector or `gh`.

2. Review with evidence.
   - Read surrounding code, tests, config, migrations, and callers for each suspected issue.
   - Use repo-specific review guidance and code intelligence tools when available.
   - Validate severity before writing a comment.

3. Draft inline comments.
   - Keep each comment short, concrete, and tied to one line or tight range.
   - Include impact and the requested change.
   - Prefer one high-signal comment over many broad comments.

4. Post or return drafts.
   - If the user asked to post inline comments, submit a GitHub review with the inline comments.
   - If posting is not explicit, return the draft comments with file and line references for confirmation.
   - Use a top-level review summary only when it helps connect multiple comments.

## Comment Shape

Use this shape for each GitHub comment:

```text
This can <impact> when <condition>. <Specific reason from code>. Consider <specific fix or test>.
```

Do not include French in GitHub comments unless explicitly requested.
