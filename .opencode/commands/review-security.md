---
description: Security-focused frontend review of current changes
agent: reviewer
subagent: true
---

Perform a security-focused review of the current changes.

Load `frontend-security` and `frontend-review`.

Trace attacker-controlled or externally controlled data through relevant code. Inspect surrounding repository code when necessary. Do not modify files.

Prioritize exploitable or realistically risky issues. Clearly distinguish confirmed vulnerabilities from defense-in-depth recommendations. Do not claim backend protections are absent merely because they are not visible in the frontend repository.
