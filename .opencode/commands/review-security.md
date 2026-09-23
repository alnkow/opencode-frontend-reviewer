---
description: Deep security review of all current uncommitted changes
agent: reviewer
subagent: true
---

Perform a security-focused review of ALL current uncommitted changes.

This is a dedicated security audit of the developer's current work.

## Scope

Review:

1. unstaged changes;
2. staged changes;
3. relevant untracked files.

Do NOT review previous committed changes unless they must be inspected
to understand the security implications of the current changes.

Conceptually use:

- `git diff`
- `git diff --cached`
- `git status --short`

For relevant untracked source files, inspect their contents.

The changed code defines the PRIMARY scope.

You MAY inspect unchanged repository code when necessary to understand:

- authentication;
- authorization;
- permissions;
- API clients;
- token handling;
- cookie behavior;
- persisted state;
- routing;
- existing sanitization/validation;
- security utilities;
- trust boundaries.

Apply the `frontend-security` skill.

## Security review areas

Check applicable risks including:

### XSS / DOM injection

Look for:

- `dangerouslySetInnerHTML`;
- direct DOM HTML injection;
- untrusted HTML;
- insufficient sanitization;
- user-controlled values reaching dangerous sinks;
- unsafe third-party content.

Do not report normal React interpolation as XSS unless there is an
actual unsafe path.

### URLs and redirects

Check user-controlled or externally supplied:

- URLs;
- redirects;
- `window.location`;
- `window.open`;
- link targets;
- iframe sources;
- resource URLs.

Consider dangerous protocols and open redirects where applicable.

### Authentication and tokens

Inspect:

- token handling;
- credential exposure;
- browser storage;
- persisted Redux state;
- logs;
- URLs/query parameters;
- accidental exposure to third-party code.

Do not assume that localStorage is automatically a vulnerability.
Explain the actual threat when reporting it.

### CSRF

Check CSRF only when applicable to the project's authentication model.

Pay particular attention when credentials are automatically attached
by the browser, such as cookie-based authentication.

Do not report CSRF mechanically for every API request.

### Authorization

Look for:

- UI-only permission checks being treated as security boundaries;
- accidental exposure of privileged functionality;
- missing authorization assumptions;
- insecure client-side trust decisions.

Remember that real authorization must ultimately be enforced by the
server.

### postMessage

When `postMessage` is used, inspect:

- targetOrigin;
- origin validation;
- message validation;
- trust assumptions;
- sensitive data transfer.

### Sensitive data

Look for accidental exposure through:

- console logging;
- error messages;
- URLs;
- persisted state;
- local/session storage;
- analytics;
- third-party integrations.

### API/request construction

Check:

- user-controlled request parameters;
- unsafe URL construction;
- path/query manipulation;
- insecure headers;
- accidental credential leakage;
- incorrect assumptions about trusted API responses.

### Parsing and object handling

When applicable, inspect:

- unsafe parsing;
- unsafe deserialization;
- prototype/object pollution risks;
- unsafe object merging;
- dynamic property assignment.

### File handling

When uploads/downloads exist, inspect:

- file type assumptions;
- filename handling;
- object URLs;
- external URLs;
- client-side validation assumptions.

Do not treat client-side validation as a security boundary.

## Repository investigation

Security analysis must consider data flow, not only individual lines.

When necessary, trace:

source
→ transformation
→ storage
→ API
→ rendering/sink

Inspect related unchanged code if required to determine whether the
flow is actually exploitable.

Do not report a vulnerability based only on a suspicious-looking line
without understanding its context.

## Avoid false positives

Before reporting a security finding, determine:

1. What is the untrusted input?
2. Can an attacker influence it?
3. Where does the value flow?
4. What is the dangerous sink or security boundary?
5. What protection already exists?
6. Is exploitation realistically possible?

If these cannot be established, either omit the finding or clearly
mark it as something requiring verification rather than a confirmed
vulnerability.

## Severity

Use:

- CRITICAL — directly exploitable issue with severe impact
- HIGH — realistic vulnerability with significant impact
- MEDIUM — meaningful security weakness requiring specific conditions
- LOW — defense-in-depth improvement or limited-impact weakness

Do not inflate severity.

## Output

Start with:

# Security Review

Scope:
- Staged files: <count>
- Unstaged files: <count>
- Untracked files reviewed: <count>

Then:

## Critical
## High
## Medium
## Low

Omit empty sections.

For each finding include:

- Severity
- File and line/range
- Vulnerability/problem
- Attack scenario
- Evidence/data flow
- Impact
- Minimal recommended fix

Clearly distinguish:

- confirmed vulnerability;
- security weakness;
- requires verification.

Finally:

## Summary

- Critical: N
- High: N
- Medium: N
- Low: N

## Verdict

`READY`

or

`NEEDS FIXES`

If no meaningful security issues are found, explicitly say:

"No significant security issues found."