---
description: Deep review of the entire feature branch against its base branch. Optional argument - base branch name.
agent: reviewer
subtask: false
---

Perform a deep PR-style review of the entire current feature branch: what will this branch introduce into the base branch if it is merged now?

Review the FINAL combined diff of all feature commits, not each commit separately. Code added in one commit and removed in a later one is not part of the review.

Review checklist (attached): @.opencode/skills/frontend-review/SKILL.md

## Git context

!`sh "$(git rev-parse --show-toplevel)/.opencode/scripts/review-context.sh" branch $1`

If the git context shows an ERROR, report it and stop. If it shows a WARNING, copy it to the top of the report and continue. If the auto-detected base branch looks wrong, say so at the top of the report and suggest running `/review-deep <base-branch>`.

If "Commits in feature" is 0, the current branch has no commits on top of the base (for example, you are on the base branch itself). Say so, and review only the uncommitted changes if there are any.

## How to get the code

1. Run the "Diff command" from the git context. If the output is truncated, run it per file: `git diff <merge-base> HEAD -- <file>`.
2. Read every changed file in full at its current state.
3. Ignore lockfiles, generated files and the `.opencode` folder.
4. Uncommitted changes are NOT part of the feature diff. If the git context lists any, review them separately: `git diff HEAD` for tracked files, and read untracked files in full.

## How to investigate

- Start from the feature diff.
- Open unchanged files only to confirm a specific finding or to find an existing implementation.
- Use targeted searches by name and synonyms in the relevant places. Do not scan the whole repository and do not analyze unrelated modules.
- For new code, check whether it duplicates existing components, shared UI, hooks, utilities, types, constants, selectors, stores, RTK Query endpoints, business logic or tests.
- Do not repeat checks you have already done.

## Output format

```
# Deep Review

<WARNING from the git context, if any>

Current branch: <branch>
Base branch: <branch>
Merge base: <commit>
Diff range: <base>...HEAD
Commits in feature: <number>
Changed files: <number>

## Critical
## High
## Medium
## Low
## Conventions

## Uncommitted changes
<"None" or the separate review of uncommitted changes, in the same finding format>

## Summary
- Critical: N
- High: N
- Medium: N
- Low: N
- Conventions: N

## Verdict
READY | NEEDS FIXES
```

Omit empty severity sections and an empty Conventions section. The Summary and Verdict cover the feature diff and the uncommitted changes together.
