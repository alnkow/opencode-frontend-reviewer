---
description: Security-focused review of all current uncommitted changes
agent: reviewer
subtask: false
---

Perform a security-only review of ALL current uncommitted changes: staged, unstaged and untracked files.

Security checklist (attached): @.opencode/skills/frontend-security/SKILL.md

This is a security review. Do not report conventions C1–C6, naming, decomposition or general code quality. Mention a non-security bug only if it is CRITICAL.

## Git context

!`sh "$(git rev-parse --show-toplevel)/.opencode/scripts/review-context.sh" local`

## How to get the code

1. Run `git diff HEAD` once (staged + unstaged). If the output is truncated, run `git diff HEAD -- <file>` per file.
2. Read every untracked file from the list above in full. Ignore lockfiles, generated files and the `.opencode` folder.
3. The changed code is the primary scope. Read unchanged code when you need it to understand the security impact: authentication, authorization, API clients, token and cookie handling, persisted state, routing, existing sanitization and validation, security utilities, trust boundaries.

## Trace data flow, do not match keywords

Follow: source → transformation → storage → API → rendering/sink.

Before reporting a vulnerability, answer:
1. What is the untrusted input?
2. Can an attacker influence it?
3. Where does the value flow?
4. What is the dangerous sink or security boundary?
5. What protection already exists?
6. Is exploitation realistically possible?

If you cannot answer these, drop the finding or mark it "requires verification". Do not report ordinary React `{value}` rendering as XSS. Do not treat localStorage as a vulnerability without an actual threat. Do not demand CSRF protection without first identifying the authentication model.

## Additional focus from the user (may be empty)

$ARGUMENTS

## Output format

```
# Security Review

Scope:
- Staged files: <number from git context>
- Unstaged files: <number from git context>
- Untracked files: <number from git context>

## Critical
## High
## Medium
## Low

## Summary
- Critical: N
- High: N
- Medium: N
- Low: N

## Verdict
READY | NEEDS FIXES
```

Each finding uses the standard finding format with category `security`, plus two extra fields:
- Status: confirmed vulnerability | security weakness | requires verification
- Attack scenario: how an attacker would exploit it

Omit empty sections. Verdict is `NEEDS FIXES` if there is at least one CRITICAL, HIGH or MEDIUM finding. If nothing is found, write "No significant security issues found." and the verdict `READY`.
