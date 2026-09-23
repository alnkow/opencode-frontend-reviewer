---
description: Deep review of current changes with broader dependency and regression analysis
agent: reviewer
subagent: true
---

Perform a deep review of the current working-tree changes.

Load `frontend-review` and `frontend-security`.

In addition to the diff:
- Trace affected call sites, imports, public APIs, state flow, RTK Query endpoints/cache behavior, and relevant consumers.
- Search broadly for existing components/hooks/utils/types/API solutions before accepting new abstractions.
- Check architectural boundaries and module isolation under the repository's modified FSD conventions.
- Examine lifecycle/resource ownership and potential memory leaks.
- Examine security-sensitive data flows and trust boundaries.
- Assess whether tests cover changed behavior and important edge cases.
- If shell execution is available and the user approves it, use the repository's actual verification commands from AGENTS.md/package.json (for this project typically typecheck, lint and focused tests). Do not invent commands.

Do not modify files. Prefer verified, actionable findings over speculative concerns.
