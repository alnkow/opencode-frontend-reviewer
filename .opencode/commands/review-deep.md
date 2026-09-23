---
description: Deep review of the entire feature branch against its base branch
agent: reviewer
subagent: true
---

Perform a deep code review of the entire current feature branch.

## Scope

This is a PR-style review.

Do NOT review only the current working tree or the last commit.

Determine the complete set of changes introduced by the current branch
since it diverged from its base branch.

### 1. Determine the base branch

Try to determine the appropriate base branch from the repository.

Prefer, in order:

1. the repository's configured default/upstream base branch if it can be determined;
2. `master` if it exists;
3. `main` if it exists;
4. `develop` if that is clearly the project's integration branch.

Do not blindly assume a base branch if repository information shows otherwise.

### 2. Determine the merge base

Find the merge-base between the current branch and the base branch.

Conceptually:

git merge-base HEAD <base>

### 3. Review the complete feature diff

Review the equivalent of:

git diff <merge-base>...HEAD

The goal is to answer:

"What will this feature branch introduce into the base branch?"

If the branch contains 10 commits, review their FINAL combined result,
not each commit independently.

Code introduced in an earlier commit and removed in a later commit
should not be reviewed.

### 4. Include uncommitted work separately

Check whether there are staged or unstaged changes that are NOT included
in HEAD.

If such changes exist:

- mention clearly that they are uncommitted;
- review them in a separate section;
- do not silently mix them with the committed feature diff.

## Repository investigation

The feature diff defines the PRIMARY review scope.

However, you MUST inspect unchanged repository code when necessary to
understand or validate the changes.

In particular, search the repository when needed for:

- existing components
- shared UI components
- hooks
- utilities
- types
- constants
- selectors
- stores
- RTK Query APIs/endpoints
- similar business logic
- existing architectural patterns
- existing tests

Do this especially when new abstractions or reusable code are introduced.

Do NOT report that something duplicates existing functionality unless you
have actually found the existing implementation.

## Review areas

Apply the frontend-review skill and check:

- correctness and real bugs
- React lifecycle and hooks
- TypeScript correctness
- async behavior and race conditions
- memory/resource leaks
- Redux Toolkit and RTK Query
- performance
- security
- accessibility
- error handling
- tests and missing important cases

Also check:

- modified FSD architecture and module boundaries
- module/slice isolation
- dependency direction
- inappropriate deep imports
- misplaced responsibilities
- reuse of existing project solutions
- SOLID
- DRY
- KISS
- YAGNI
- unnecessary abstractions
- unnecessary complexity

Pay explicit attention to JavaScript fallback semantics:

- `||` vs `??`
- whether `0`, `false`, or `""` are valid values
- do not recommend replacing one with the other without checking semantics

## Avoid noisy review

Do not report:

- formatting handled by project tooling
- subjective naming preferences
- purely stylistic preferences
- speculative problems without evidence
- DRY violations just because two small pieces of code look similar
- theoretical security issues that are not applicable to the actual code

Prioritize real defects, regressions, architectural problems,
maintainability risks, and meaningful opportunities for reuse.

## Output

Start with:

# Deep Review

Base branch: <branch>
Merge base: <commit>
Commits in feature: <count>
Changed files: <count>

Then group findings by severity:

## Critical
## High
## Medium
## Low

For every finding provide:

- severity
- file and line/range
- problem
- why it matters
- evidence/context
- minimal recommended fix

If repository reuse is involved, include the existing implementation
that should be considered.

Then provide:

## Uncommitted changes

State whether additional staged/unstaged changes exist and summarize
their review separately.

Finally:

## Summary

- Critical: N
- High: N
- Medium: N
- Low: N

## Verdict

READY
or
NEEDS FIXES