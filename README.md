# OpenCode Frontend Reviewer

Reusable code-review setup for [OpenCode](https://opencode.ai/) focused on modern React + TypeScript applications.

The project provides a dedicated read-only reviewer agent, reusable review skills, and three simple commands:

```text
/review
/review-deep
/review-security
```

The goal is to make AI-assisted code review part of the normal development workflow without requiring long prompts or manually explaining review rules every time.

---

## What it checks

The reviewer focuses on meaningful engineering problems rather than formatting or subjective style preferences.

It checks:

* correctness and potential bugs;
* React lifecycle and Hooks;
* TypeScript correctness;
* async code and race conditions;
* memory and resource leaks;
* state management;
* API usage;
* architecture and module boundaries;
* reuse of existing project code;
* SOLID / DRY / KISS / YAGNI;
* unnecessary complexity and premature abstractions;
* performance regressions;
* security;
* accessibility;
* error handling;
* tests and important missing test cases.

---

# Project structure

```text
.opencode/
├── agents/
│   └── reviewer.md
│
├── commands/
│   ├── review.md
│   ├── review-deep.md
│   └── review-security.md
│
└── skills/
    ├── frontend-review/
    │   └── SKILL.md
    │
    └── frontend-security/
        └── SKILL.md

AGENTS.example.md
README.md
```

Each part has a different responsibility.

### Agent

```text
.opencode/agents/reviewer.md
```

Defines **who performs the review**.

The reviewer is intended to be a read-only agent that analyzes code but does not modify it.

---

### Commands

```text
.opencode/commands/
```

Define **what should be reviewed**.

There are intentionally only three commands:

```text
/review
/review-deep
/review-security
```

The small command set is deliberate. Specialized React, TypeScript, architecture, performance, memory-leak, and reuse checks belong to the reviewer skills rather than separate commands.

---

### Skills

```text
.opencode/skills/
```

Define **how the review should be performed**.

`frontend-review` contains the general frontend review methodology.

`frontend-security` contains the deeper security methodology.

---

### AGENTS.md

`AGENTS.md` belongs to the application being reviewed, not to this reviewer itself.

It describes project-specific context such as:

* architecture;
* framework and libraries;
* directory structure;
* state management;
* API architecture;
* build/test/lint commands;
* project conventions;
* architectural exceptions;
* important constraints.

This repository contains:

```text
AGENTS.example.md
```

only as an example.

For a real project, generating `AGENTS.md` using OpenCode `/init` is recommended.

---

# Installation

## 1. Copy `.opencode`

Copy the `.opencode` directory from this repository into the root of the project you want to review.

The result should look approximately like this:

```text
my-project/
├── .opencode/
│   ├── agents/
│   │   └── reviewer.md
│   ├── commands/
│   │   ├── review.md
│   │   ├── review-deep.md
│   │   └── review-security.md
│   └── skills/
│       ├── frontend-review/
│       │   └── SKILL.md
│       └── frontend-security/
│           └── SKILL.md
│
├── src/
├── package.json
└── ...
```

---

## 2. Configure the model

Open:

```text
.opencode/agents/reviewer.md
```

and configure the model available in your OpenCode environment.

For example:

```yaml
model: your-provider/your-model
```

Do not blindly copy a provider/model name from another developer's environment.

---

## 3. Generate project instructions

Start OpenCode from the root of the application:

```bash
cd my-project
opencode
```

Then run:

```text
/init
```

OpenCode will analyze the repository and create:

```text
AGENTS.md
```

Review the generated file manually.

Automatic repository analysis may not understand intentional architectural decisions, so document important exceptions explicitly.

For example:

```md
## Architecture

The project uses a modified Feature-Sliced Design architecture.

Important:

- Do not introduce architectural layers only to conform to canonical FSD.
- Preserve the architecture already established by the project.
- Keep modules/slices isolated.
- Respect dependency direction.
- Prefer public module APIs over deep imports.
```

`AGENTS.example.md` in this repository can be used as a reference.

---

# Commands

## `/review`

The command you will use most often.

Run it while developing:

```text
/review
```

It reviews **all current uncommitted work**.

That includes:

```text
unstaged changes
+
staged changes
+
relevant untracked files
```

Conceptually:

```text
HEAD
 │
 └── current working state
          ↑
       /review
```

It does **not** review already committed changes from the feature branch.

### Example

You have already made several commits:

```text
commit 1
commit 2
commit 3
commit 4  ← HEAD
```

Then you change:

```text
Map.tsx       unstaged
api.ts        staged
NewPanel.tsx  untracked
```

Running:

```text
/review
```

reviews those current changes.

It does not review commits 1–4 again.

---

## Recommended development workflow

Use `/review` whenever you reach a meaningful checkpoint:

```text
write code
    ↓
/review
    ↓
fix findings
    ↓
continue development
    ↓
/review
    ↓
commit
```

You can run `/review` as often as useful.

Because `/review` already includes staged changes, a separate `/review-staged` command is intentionally not provided.

If you want another review immediately before committing, simply run:

```text
/review
```

again.

---

# `/review-deep`

Use this when the feature is finished or before creating a Pull Request.

```text
/review-deep
```

Unlike `/review`, this command reviews the **entire feature branch**.

Suppose you created a feature branch from `master`:

```text
master
   │
   ●  ← branch point
    \
     ● commit 1
     ● commit 2
     ● commit 3
     ● ...
     ● commit 10 ← HEAD
```

`/review-deep` determines the appropriate base branch and merge-base and reviews the final combined change introduced by the feature.

Conceptually:

```text
base / merge-base
        │
        └──────────────── HEAD
               ↑
          /review-deep
```

If the feature contains 10 commits, the reviewer does **not** review each commit independently.

Instead it asks:

> What will this feature introduce into the base branch if it is merged now?

For example, if code was added in commit 2 and removed in commit 8, it should not appear as a finding because it is not part of the final feature diff.

---

## Repository-wide investigation

The feature diff defines the primary review scope, but `/review-deep` may inspect unchanged code elsewhere in the repository.

This is important for architecture and reuse.

For example:

```text
feature change:

features/map/ui/CustomSelect.tsx
              │
              │ repository search
              ▼
existing implementation:

shared/ui/Select/Select.tsx
```

The reviewer can then determine whether the existing implementation should be reused.

This applies to:

* components;
* hooks;
* utilities;
* types;
* constants;
* selectors;
* stores;
* API endpoints;
* shared business logic;
* existing architectural patterns;
* tests.

The reviewer should never claim that an existing solution should be reused unless it actually found that solution.

---

## When to use `/review-deep`

Typical cases:

```text
feature completed
large refactoring completed
new module introduced
state-management changes
API architecture changes
many files changed
before creating a Pull Request
```

You generally do **not** need `/review-deep` repeatedly while writing code.

Use `/review` for that.

---

# `/review-security`

Run:

```text
/review-security
```

for a dedicated security-oriented review.

Basic security checks are already included in `/review` and `/review-deep`.

`/review-security` exists for changes where security deserves a separate, deeper pass.

Typical examples:

* authentication;
* authorization;
* permissions;
* cookies;
* tokens;
* forms;
* user-controlled input;
* HTML rendering;
* `dangerouslySetInnerHTML`;
* URLs and redirects;
* `postMessage`;
* localStorage/sessionStorage;
* persisted application state;
* file upload/download;
* external content;
* security-sensitive API calls.

The security review considers applicable risks such as:

* XSS;
* DOM-based XSS;
* CSRF;
* unsafe redirects;
* unsafe URLs;
* credential/token exposure;
* sensitive data leakage;
* insecure browser storage;
* unsafe `postMessage`;
* request construction from untrusted data;
* unsafe parsing/deserialization;
* prototype/object pollution risks.

Security findings should be based on the actual application context rather than generic security checklists.

For example, the reviewer should first understand how authentication works before claiming that an API request requires CSRF protection.

---

# Review philosophy

The reviewer is intentionally designed to avoid noisy AI code reviews.

A useful review should find real engineering problems, not demonstrate how many comments an AI can generate.

Before reporting a finding, the reviewer should effectively answer:

```text
Is this actually a problem?

Can it be demonstrated from the code?

Does fixing it provide meaningful value?
```

If not, the finding should normally be omitted.

---

# Reuse before invention

One of the main goals of the reviewer is preventing unnecessary duplication.

When new reusable code appears, the reviewer should investigate whether the repository already contains an appropriate solution.

This includes new:

* components;
* hooks;
* utilities;
* helpers;
* types;
* constants;
* selectors;
* state logic;
* API helpers;
* business abstractions.

For frontend projects, particular attention should be paid to existing shared UI libraries and design-system components.

For example:

```text
new component
     │
     ▼
search repository
     │
     ├── shared UI
     ├── design system
     ├── features
     ├── widgets
     ├── hooks
     ├── utilities
     └── existing domain code
             │
             ▼
      reuse if appropriate
```

However, reuse is not an absolute rule.

The reviewer should not create an abstraction merely to eliminate a few similar lines of code.

---

# SOLID, DRY, KISS and YAGNI

These principles are used as **reasoning tools**, not mechanical rules.

The reviewer should identify meaningful problems such as:

* excessive responsibility;
* inappropriate coupling;
* duplicated domain knowledge;
* unnecessary complexity;
* unnecessary indirection;
* premature abstraction;
* abstractions that make code harder to understand.

It should not report:

> DRY violation

simply because two small pieces of code happen to look similar.

Sometimes duplication is simpler and safer than an incorrect abstraction.

---

# Architecture and FSD

The reviewer supports Feature-Sliced Design style architectures but should respect the architecture documented by the project.

It checks things such as:

* module/slice isolation;
* dependency direction;
* inappropriate cross-feature dependencies;
* public boundaries;
* deep imports;
* misplaced responsibilities;
* business logic leaking into generic shared code;
* code placed at an unnecessarily high architectural layer.

The reviewer must **not** force canonical FSD onto a deliberately modified architecture.

`AGENTS.md` is the source of truth for project-specific architectural decisions.

---

# React review

React-specific checks include:

* incorrect Hook usage;
* effect lifecycle;
* missing or incorrect cleanup;
* dependency problems;
* stale closures;
* unnecessary effects;
* derived state;
* unstable keys;
* unnecessary rerenders;
* incorrect memoization;
* state mutation;
* asynchronous updates and races.

The reviewer should distinguish real problems from theoretical ones.

---

# Memory and resource leaks

Memory/resource management receives explicit attention.

Relevant areas include:

* event listeners;
* timers;
* intervals;
* `requestAnimationFrame`;
* `IntersectionObserver`;
* `ResizeObserver`;
* `MutationObserver`;
* subscriptions;
* WebSocket connections;
* Server-Sent Events;
* unfinished/obsolete async operations;
* AbortController;
* Web Workers;
* object URLs;
* external library instances;
* retained DOM/data references;
* unbounded caches and collections;
* `useEffect` cleanup.

Cleanup should only be requested when the underlying resource actually requires it.

---

# TypeScript review

TypeScript checks include:

* incorrect types;
* unsafe assertions;
* unnecessary `any`;
* incorrect narrowing;
* null/undefined handling;
* API type mismatches;
* mutation where it causes problems;
* unnecessary duplication of existing types.

The reviewer should prefer existing project types when appropriate.

---

# State and API review

The reviewer should understand the state-management and API approach documented in `AGENTS.md`.

Depending on the project, this may include:

* Redux Toolkit;
* RTK Query;
* Zustand;
* TanStack Query;
* custom stores;
* custom API clients.

Checks should focus on correctness, duplication, lifecycle, cache behavior, state ownership, and established project patterns.

---

# Performance

Performance findings should be evidence-based.

Relevant examples include:

* expensive work during render;
* unnecessary rerenders;
* repeated heavy calculations;
* unnecessary allocations;
* large DOM rendering;
* missing virtualization where scale actually requires it;
* main-thread blocking;
* duplicated network requests;
* inefficient selectors;
* inappropriate state subscriptions.

Do not report speculative micro-optimizations.

---

# Tests

The reviewer should consider whether changed behavior requires tests.

It should focus on meaningful cases such as:

* important business logic;
* regressions;
* edge cases;
* error paths;
* complex state transitions;
* previously broken behavior.

It should not mechanically demand tests for every trivial implementation detail.

---

# Severity levels

Findings use four severity levels.

### CRITICAL

Examples:

* exploitable security vulnerability;
* data loss;
* severe production failure.

### HIGH

Examples:

* likely runtime bug;
* serious regression;
* significant resource leak;
* major architectural violation.

### MEDIUM

Examples:

* meaningful maintainability problem;
* realistic performance issue;
* architectural/design risk;
* important missing edge case.

### LOW

Useful improvement with limited impact.

Severity should not be inflated.

---

# Review output

A normal review is structured approximately as:

```text
# Code Review

Scope:
- Staged files: ...
- Unstaged files: ...
- Untracked files reviewed: ...

## High

...

## Medium

...

## Low

...

## Summary

Critical: 0
High: 1
Medium: 2
Low: 1

## Verdict

NEEDS FIXES
```

Empty severity sections may be omitted.

If no meaningful problems are found:

```text
No significant issues found.

Verdict: READY
```

---

# Recommended workflow

For normal development:

```text
                    DEVELOPMENT

                         │
                         ▼
                    write code
                         │
                         ▼
                     /review
                         │
                  fix findings
                         │
                         ▼
                 continue coding
                         │
                         ▼
                     /review
                         │
                         ▼
                      commit
                         │
                         ▼
                  more commits...
                         │
                         ▼
                feature completed
                         │
                         ▼
                  /review-deep
                         │
                         ▼
                       PR
```

For security-sensitive work:

```text
/review
   ↓
/review-security
   ↓
/review-deep
   ↓
PR
```

---

# Quick reference

### While developing

```text
/review
```

> Review what I am working on right now.

### Feature finished / before PR

```text
/review-deep
```

> Review the entire feature as it will be merged into the base branch.

### Security-sensitive changes

```text
/review-security
```

> Perform a dedicated security review.

---

# Updating

This reviewer is intentionally kept separate from application repositories so its rules can evolve independently.

When the reviewer configuration changes, update the `.opencode` directory in projects that use it.

Project-specific rules should remain in each application's `AGENTS.md`.

This separation keeps responsibilities clear:

```text
opencode-frontend-reviewer
        │
        ├── how to review
        │
        ├── review methodology
        │
        └── security methodology

application repository
        │
        └── AGENTS.md
              │
              ├── what this project is
              ├── architecture
              ├── commands
              └── project conventions
```

---

# Philosophy

The goal is not to replace human code review.

The goal is to catch obvious and non-obvious problems **before another developer has to find them**.

A good result is not:

> The AI produced 25 comments.

A good result is:

> The reviewer found the two issues that actually mattered.
