---
description: Review all current uncommitted changes
agent: reviewer
subagent: true
---

Perform a focused code review of ALL current uncommitted changes.

This command is intended to be used frequently during development.

## Scope

Review everything the developer has changed since HEAD that has not yet
been committed.

This includes:

1. unstaged changes;
2. staged changes;
3. new untracked files that are part of the current work.

Do NOT review previous committed changes.

Conceptually, the primary scope is:

- `git diff` — unstaged changes
- `git diff --cached` — staged changes
- `git status --short` — identify untracked files

For relevant untracked source files, inspect their contents as part of
the review.

Do not assume that `git diff` alone represents all current work.

## Keep this review focused

This is a development-time review, not a full PR audit.

Start from the changed code.

Inspect surrounding code when necessary to understand the change.

Search the wider repository when necessary to verify:

- whether a component already exists;
- whether a hook already exists;
- whether a utility/helper already exists;
- whether a type already exists;
- whether a constant already exists;
- whether a selector/store solution already exists;
- whether an RTK Query endpoint/API solution already exists;
- whether similar business logic is already implemented;
- whether the change follows an established project pattern.

Do NOT claim that something should be reused unless you actually found
an existing implementation.

## Review priorities

Apply the `frontend-review` skill.

Prioritize findings in this order:

1. Correctness and real bugs
2. Security vulnerabilities
3. React lifecycle problems
4. Async/race-condition problems
5. Memory and resource leaks
6. TypeScript correctness
7. Redux Toolkit / RTK Query correctness
8. FSD/module boundary violations
9. Reuse of existing project code
10. Performance regressions
11. Error handling
12. Accessibility
13. Tests / important missing test cases
14. Maintainability

## Memory and resource leaks

Pay particular attention to lifecycle/resource management, including:

- event listeners
- timers and intervals
- requestAnimationFrame
- IntersectionObserver
- ResizeObserver
- MutationObserver
- subscriptions
- WebSocket
- Server-Sent Events
- AbortController / obsolete requests
- workers
- object URLs
- external library instances
- retained references
- unbounded caches/collections
- useEffect cleanup
- stale closures where they create real bugs

Do not require cleanup where cleanup is not actually necessary.

## Reuse

When the changes introduce a new:

- component
- hook
- utility
- helper
- type
- constant
- selector
- store logic
- API helper/endpoint
- reusable business abstraction

search the repository for an existing solution when practical.

Pay particular attention to:

- `shared/ui`
- `shared/shadcn`
- existing `features`
- existing `widgets`
- `apis`
- `stores`
- shared utilities
- shared types

Prefer reuse when it genuinely reduces duplication and keeps the
architecture coherent.

Do NOT recommend abstraction merely to satisfy DRY.

## Architecture

Respect the architecture documented in `AGENTS.md`.

For FSD-style code, check:

- module/slice isolation
- dependency direction
- inappropriate cross-feature dependencies
- deep imports where a public boundary should be used
- misplaced responsibilities
- business logic leaking into generic shared code
- code placed in an unnecessarily high layer

Do not try to convert a deliberately modified FSD project into
canonical FSD.

## Code quality

Use SOLID, DRY, KISS and YAGNI as reasoning principles, not mechanical rules.

Flag:

- unnecessary complexity
- duplicated domain knowledge
- inappropriate coupling
- oversized responsibilities
- premature abstractions
- abstractions that make code harder to understand
- needless indirection

Do not report subjective stylistic preferences.

## JavaScript / TypeScript semantics

Explicitly inspect fallback/default-value logic.

Pay particular attention to:

`value || fallback`

versus:

`value ?? fallback`

If `0`, `false`, or `""` are valid values, `||` may be incorrect.

However, do NOT mechanically recommend `??`.

Determine the intended semantics first.

Also inspect when relevant:

- optional chaining
- null / undefined handling
- unsafe type assertions
- `any`
- narrowing
- mutation
- stale values/closures

## Security essentials

Always perform a lightweight security review of changed code.

Look for applicable issues such as:

- XSS / unsafe HTML rendering
- `dangerouslySetInnerHTML`
- unsafe user-controlled URLs
- unsafe redirects
- unsafe `postMessage`
- sensitive data exposure
- token/credential handling
- unsafe storage of sensitive information
- request construction from untrusted input
- CSRF concerns where browser-managed credentials are involved
- unsafe parsing/deserialization
- prototype/object pollution risks

Avoid theoretical security findings that do not apply to the actual code.

Use `/review-security` for a dedicated security audit.

## Noise control

Do NOT report:

- formatting issues handled by formatter/linter;
- subjective naming preferences;
- hypothetical problems without evidence;
- "best practice" violations with no practical consequence;
- tiny duplication that does not justify abstraction;
- speculative performance optimizations;
- theoretical security concerns without a plausible path.

Before reporting a finding, ask:

1. Is this actually a problem?
2. Can I point to evidence in the code?
3. Does fixing it provide meaningful value?

If not, omit it.

## Severity

Use:

- CRITICAL — exploitable security issue, data loss, severe production failure
- HIGH — likely bug/regression or serious architectural/resource issue
- MEDIUM — meaningful maintainability, correctness, performance or design risk
- LOW — worthwhile improvement with limited impact

Do not inflate severity.

## Output

Start with:

# Code Review

Scope:
- Staged files: <count>
- Unstaged files: <count>
- Untracked files reviewed: <count>

Then report only meaningful findings:

## Critical
## High
## Medium
## Low

Omit empty severity sections.

For every finding include:

- Severity
- File and line/range
- Problem
- Why it matters
- Evidence/context
- Minimal recommended fix

When suggesting reuse, identify the existing implementation.

Finally provide:

## Summary

- Critical: N
- High: N
- Medium: N
- Low: N

## Verdict

`READY` — no meaningful issues found.

or

`NEEDS FIXES` — meaningful issues should be addressed.

If no meaningful issues are found, explicitly say:

"No significant issues found."