---
description: Review all current uncommitted changes (staged, unstaged, untracked)
agent: reviewer
subtask: false
---

Review ALL current uncommitted changes: staged, unstaged and untracked files. Do not review commits that are already in HEAD.

This is a development-time review, run often while coding. Stay focused on the changed code and its direct impact. It is not a full PR audit; that is what `/review-deep` is for.

Review checklist (attached): @.opencode/skills/frontend-review/SKILL.md

## Git context

!`sh "$(git rev-parse --show-toplevel)/.opencode/scripts/review-context.sh" local`

## How to get the code

1. Run `git diff HEAD` once. It contains staged and unstaged changes together. If the output is truncated, run `git diff HEAD -- <file>` for each file from the list above.
2. Read every untracked file from the list above in full. They are new files and are not in `git diff`.
3. Ignore lockfiles, generated files and the `.opencode` folder.

## Additional focus from the user (may be empty)

$ARGUMENTS

## Output format

```
# Code Review

Scope:
- Staged files: <number from git context>
- Unstaged files: <number from git context>
- Untracked files: <number from git context>

## Critical
## High
## Medium
## Low
## Conventions

## Summary
- Critical: N
- High: N
- Medium: N
- Low: N
- Conventions: N

## Verdict
READY | NEEDS FIXES
```

Omit empty sections. If there are no findings and no convention violations, write "No significant issues found." and the verdict `READY`.
