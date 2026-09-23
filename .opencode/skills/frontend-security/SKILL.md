---
name: frontend-security
description: Security-focused frontend review methodology for React/TypeScript, including XSS, CSRF context, auth/token handling, postMessage, URLs, storage, injection sinks, and browser trust boundaries.
compatibility: OpenCode project skill
metadata:
  focus: application-security
  stack: browser-react-typescript
---

# Frontend security review

Use this for dedicated security reviews and deeper analysis of security-sensitive changes.

## Evidence standard

Trace source -> transformation -> sink. Prefer confirmed data flows over keyword matching. Clearly label defense-in-depth observations separately from vulnerabilities.

Frontend-only visibility is incomplete: do not claim server-side validation, authorization, CSRF defenses, cookie flags, CSP headers, or CORS policy are missing unless repository evidence establishes that.

## XSS and DOM injection

Inspect changed or reachable uses of:
- `dangerouslySetInnerHTML`
- `innerHTML`, `outerHTML`, `insertAdjacentHTML`
- document.write
- HTML parsing/rendering libraries
- dynamic script/style/iframe creation
- URL-bearing DOM attributes
- markdown/rich-text rendering
- user-controlled SVG

Determine whether input can be attacker-controlled and whether contextual escaping/sanitization is correct. React text interpolation is normally escaped; do not report ordinary `{value}` rendering as XSS.

## URLs and navigation

Check attacker-controlled URLs passed to `href`, `src`, `window.location`, `window.open`, redirects, downloads, iframes, or router navigation. Consider allowed schemes/origins where relevant. Check external links/opened windows for appropriate isolation when applicable.

## CSRF

First identify the authentication/request model. CSRF is especially relevant when credentials such as cookies are automatically attached to state-changing requests. Check client-side request construction from attacker-controlled inputs and whether expected CSRF mechanisms are integrated when visible.

Do not demand CSRF tokens blindly for every API. Token/header-based auth that is not automatically attached by the browser has different CSRF properties.

Remember: XSS can undermine CSRF protections.

## Authentication, authorization, tokens and storage

Check for:
- secrets embedded in frontend source;
- access/refresh tokens exposed unnecessarily;
- sensitive values persisted in localStorage/sessionStorage/redux-persist without a justified design;
- auth decisions treated as security boundaries solely in UI;
- sensitive data in logs, errors, analytics, URLs, query strings, or browser history;
- unsafe token forwarding to unintended origins.

Client-side route/button guards are UX controls, not server authorization.

## postMessage / cross-window communication

Check targetOrigin is appropriately restricted; message handlers validate `event.origin` and, where useful, `event.source`; payload shape is validated; untrusted messages cannot trigger privileged actions or unsafe sinks.

## Request construction / client-side CSRF / injection

Trace URL/path/query/body values derived from location, hash, query params, storage, messages, remote data, or user input. Look for attacker influence over state-changing endpoints, arbitrary origins, methods, or sensitive parameters.

## Prototype/object hazards

Inspect unsafe merges of untrusted objects, dynamic property assignment with attacker-controlled keys, and parsing/merging patterns that may permit prototype pollution or privilege/config manipulation.

## Third-party and dynamic content

Flag newly introduced remote scripts, dynamic imports from untrusted locations, risky iframe settings, or trust of third-party content when concretely relevant. Dependency vulnerability scanning is a separate concern; do not invent CVEs from package names alone.

## CSP and browser hardening

CSP, frame restrictions and related headers are defense-in-depth. Mention them only when the reviewed change materially interacts with them or repository configuration is in scope. Do not treat absence in frontend source as proof that production headers are absent.

## Severity

CRITICAL/HIGH require a credible exploit path and meaningful impact. MEDIUM requires realistic security impact with constraints. LOW is for limited-risk hardening with a concrete rationale. Avoid fear-based severity inflation.
