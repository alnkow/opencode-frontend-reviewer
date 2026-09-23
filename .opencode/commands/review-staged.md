---
description: Review exactly what is staged for the next commit
agent: reviewer
subagent: true
---

Review the staged changes (`git diff --cached`) as a pre-commit gate.

Load and follow the `frontend-review` skill. Inspect repository context when needed. Do not modify files.

Pay special attention to regressions, missing cleanup, unsafe async behavior, FSD boundary violations, unnecessary duplication instead of reuse, security issues, incorrect `||` vs `??`, and missing tests for behavior changes.

Return findings ordered by severity and finish with READY or NEEDS FIXES.
