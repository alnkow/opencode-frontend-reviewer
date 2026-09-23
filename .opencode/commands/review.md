---
description: Fast review of current unstaged/uncommitted changes
agent: reviewer
subagent: true
---

Perform a focused review of my current working-tree changes.

Scope:
1. Inspect the current diff (`git diff`) and relevant changed files.
2. Inspect surrounding code and search the repository when necessary to validate reuse, architecture, or behavior.
3. Do NOT review the entire repository without a concrete reason from the diff.
4. Do NOT modify files.

Prioritize real issues in correctness, React/TypeScript, async behavior, memory/resource cleanup, Redux/RTK Query, security essentials, FSD boundaries, reuse, performance, accessibility, tests, and maintainability.

Explicitly check whether `||` is being used where nullish fallback semantics (`??`) are intended. Preserve valid falsy values such as `0`, `false`, and `""`. Do not mechanically replace `||` when boolean/falsy semantics are intentional.

Keep the review concise. Avoid style-only and speculative findings.
