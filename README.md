# OpenCode Frontend Reviewer

Reusable OpenCode review setup for React + TypeScript projects. It provides one read-only review agent, four slash commands, and two reusable skills.

The reference setup is tuned for a project using React 18, TypeScript, Redux Toolkit/RTK Query, Tailwind, Radix/shadcn-style UI, Vitest, and a **modified Feature-Sliced Design (FSD)**. The architecture assumptions are deliberately documented and can be adapted per repository.

## What you get

```text
.opencode/
├── agents/
│   └── reviewer.md
├── commands/
│   ├── review.md
│   ├── review-staged.md
│   ├── review-deep.md
│   └── review-security.md
└── skills/
    ├── frontend-review/
    │   └── SKILL.md
    └── frontend-security/
        └── SKILL.md

AGENTS.example.md
README.md
```

### `/review`

The everyday command. Use it while developing to review the current working-tree diff. It is intentionally focused: it starts from changed code, reads surrounding code when needed, searches for existing reusable solutions, and avoids a repository-wide audit unless the diff justifies it.

```text
/review
```

It checks correctness, React/TypeScript, async/races, memory/resource cleanup, Redux/RTK Query, security essentials, modified FSD boundaries, reuse, performance, accessibility, tests, maintainability, and explicitly reviews `||` versus `??` semantics.

### `/review-staged`

Pre-commit review of exactly what is staged:

```bash
git add <files>
```

Then in OpenCode:

```text
/review-staged
```

This is useful as a final local gate before committing.

### `/review-deep`

Use for a larger feature, refactor, risky change, or before opening a PR:

```text
/review-deep
```

It traces affected consumers/imports/state/API behavior more broadly, performs deeper reuse and FSD analysis, loads the security methodology, and can use project verification commands when shell access is available and approved.

### `/review-security`

Dedicated security pass:

```text
/review-security
```

The normal `/review` already contains security essentials. This command exists because a proper security review needs broader data-flow/trust-boundary analysis than an everyday diff review.

It covers XSS/DOM injection, CSRF in the context of the actual authentication model, unsafe URL/navigation flows, token/storage handling, `postMessage`, sensitive data leakage, request construction/client-side CSRF, object/prototype hazards, dynamic/third-party content, and relevant browser hardening.

## Why agent + commands + skills?

OpenCode gives these mechanisms different jobs:

- **Agent**: defines *who performs the review*: model, role, permissions, and core behavior.
- **Command**: defines *what review to run now*: fast, staged, deep, or security.
- **Skill**: defines *how to reason about a specialist task*: the reusable review methodology.
- **AGENTS.md**: defines *what is special about the target repository*: architecture, commands, conventions, and local rules.

This keeps prompts maintainable. The agent stays small, commands stay task-oriented, and detailed methodology lives in skills that OpenCode can load when relevant.

## Installation in a project

### Option A — copy the `.opencode` directory

Clone this repository somewhere outside your application repository, then copy `.opencode` into the root of the target project:

```bash
cp -R /path/to/opencode-frontend-reviewer/.opencode /path/to/your-project/
```

The target becomes:

```text
your-project/
├── .git/
├── .opencode/
│   ├── agents/
│   ├── commands/
│   └── skills/
├── AGENTS.md
├── src/
└── package.json
```

OpenCode discovers project agents and skills under `.opencode` while walking to the project root.

### Option B — copy individual pieces

If the project already has `.opencode`, merge the folders instead of replacing them:

```bash
cp -R .opencode/agents/*   /path/to/project/.opencode/agents/
cp -R .opencode/commands/* /path/to/project/.opencode/commands/
cp -R .opencode/skills/*   /path/to/project/.opencode/skills/
```

Review existing names first to avoid overwriting project-specific files.

## Configure the model

`reviewer.md` currently contains:

```yaml
model: yadro-provider/DeepSeek-V4-Flash
```

That is intentional for the reference environment. A colleague using another provider **must change this line** to a model available in their OpenCode configuration.

The methodology itself is model-independent.

For the reference environment, Qwen can remain the general `small_model`/`subagent_model`; the reviewer explicitly requests DeepSeek so review quality does not silently depend on the global subagent default.

## Create or update `AGENTS.md`

OpenCode V2 uses `AGENTS.md` for persistent project instructions. Do not blindly copy architecture assumptions between repositories.

If the target project has no `AGENTS.md`, OpenCode can initialize one with:

```text
/init
```

Then merge in relevant rules from `AGENTS.example.md`.

At minimum document:

1. stack and package manager;
2. architecture/layer boundaries;
3. locations of shared/reusable UI and utilities;
4. generated files that must not be edited;
5. lint/typecheck/test/build commands;
6. unusual project conventions.

Commit the target project's `AGENTS.md` so all developers and OpenCode sessions receive the same repository-specific context.

## Reference project: modified FSD

The supplied skill intentionally does **not** enforce textbook FSD. The reference repository uses:

```text
src/
├── app/
├── pages/
├── widgets/
├── features/
├── shared/
├── apis/
├── stores/
├── layouts/
├── assets/
├── test/
└── types/
```

There is no `entities` layer; domain API/state responsibilities are represented by `apis` and `stores`. The reviewer is explicitly told not to "fix" the project by inventing an `entities` layer.

For another project, edit the **Modified FSD architecture** section in `frontend-review/SKILL.md` and its `AGENTS.md`.

The architectural checks focus on the useful invariants: dependency direction, isolation, public boundaries, avoiding feature business logic in shared code, correct responsibility/placement, and avoiding cross-module coupling.

## Reuse checks

One of the strongest rules in this setup is **search before claiming duplication**.

When new code introduces a component, hook, utility, type, selector, API helper, formatter, constant, or abstraction, the reviewer should:

```text
identify responsibility
        ↓
search repository
        ↓
inspect plausible existing implementations
        ↓
existing semantic match?
   ↙                 ↘
 yes                 no
 ↓                    ↓
consider reuse       review new solution
```

This prevents two common bad review behaviors:

- approving reinvention because the model only looked at the diff;
- shouting "DRY" merely because two snippets look similar.

DRY, SOLID, KISS, and YAGNI are used as diagnostic principles, not as automatic style rules.

## `??` versus `||`

The normal review explicitly checks changed fallback expressions.

Potential bug:

```ts
const zoom = config.zoom || 10;
```

If `0` is valid, this changes its meaning. Nullish fallback may be intended:

```ts
const zoom = config.zoom ?? 10;
```

But the reviewer must **not** mechanically replace every `||`. If the desired rule really is "fallback for any falsy value", `||` is correct. The same semantic check is applied in the opposite direction to `??`.

## Memory/resource leak checks

The reviewer treats lifecycle resources as owned resources and looks for missing disposal/cleanup around:

- DOM/event listeners;
- `setTimeout` / `setInterval`;
- `requestAnimationFrame`;
- `IntersectionObserver`, `ResizeObserver`, `MutationObserver`;
- WebSocket/SSE/subscriptions;
- stale/obsolete async operations;
- object URLs;
- workers;
- media/external-library instances;
- caches/maps or retained references that can grow indefinitely.

It also checks React effect setup/cleanup symmetry and stale closure/dependency problems.

## Security design

Security is deliberately split into two levels.

### Everyday security

`/review` includes a lightweight security pass so obvious vulnerabilities are not postponed: XSS sinks, untrusted HTML/URLs, secrets/tokens, dangerous storage, unsafe `postMessage`, sensitive logging, browser injection sinks, and suspicious request construction.

### Dedicated audit

`/review-security` loads the full `frontend-security` skill and follows data from source to sink. It avoids simplistic rules such as "all localStorage is a vulnerability" or "every API needs a CSRF token".

CSRF review first determines how authentication works. CSRF is especially relevant when the browser automatically attaches credentials (commonly cookies). Frontend code alone may not reveal server-side CSRF validation, cookie flags, CSP, CORS, or authorization, so the reviewer is forbidden from claiming those controls are absent without evidence.

Similarly, React's normal text rendering is escaped; the reviewer concentrates on actual dangerous sinks and unsafe rendering patterns rather than flagging ordinary JSX interpolation.

## Shell permissions

The reference OpenCode environment uses `bash: ask`. This setup does not weaken that policy.

The reviewer is read-only with respect to file editing. Shell execution remains governed by the user's/project's OpenCode configuration. Deep review may propose/use verification commands only when permitted and approved.

If your organization has stricter requirements, restrict the reviewer further in its agent permissions. Do not loosen corporate policy merely to make review more convenient.

## Recommended workflow

During development:

```text
code → /review → fix → /review
```

Before commit:

```text
git add ... → /review-staged → commit
```

Before a PR or after a substantial refactor:

```text
/review-deep
```

For security-sensitive work (auth, HTML rendering, messaging, URL/request construction, permissions, storage):

```text
/review-security
```

## Interpreting findings

Findings use:

- **CRITICAL** — credible severe exploit/data-loss/system-impact path.
- **HIGH** — serious correctness/security/regression issue with realistic impact.
- **MEDIUM** — meaningful defect or maintainability/architecture issue worth fixing before merge in normal circumstances.
- **LOW** — limited-risk improvement with concrete value.

The agent ends with `READY` or `NEEDS FIXES`. By default, LOW-only findings should not block.

A good finding must state the problem, evidence, realistic impact, and minimal fix. The prompt explicitly discourages speculative issues, style-only noise, severity inflation, and unnecessary rewrites.

## Adapting this repository for another team

Do these first:

1. Change the model in `.opencode/agents/reviewer.md`.
2. Update FSD/architecture assumptions in `frontend-review/SKILL.md`.
3. Create/update the target project's `AGENTS.md`.
4. Update reusable-code locations (`shared/ui`, design system, hooks, utils, etc.).
5. Record the target project's actual verification commands.
6. Add framework-specific checks only when the project really uses those technologies.

Avoid turning the skill into a giant company handbook. Put stable review methodology in skills and repository-specific facts in `AGENTS.md`.

## Design references

This setup follows current OpenCode concepts: project agents live in `.opencode/agents`, project skills in `.opencode/skills`, commands are reusable slash-command prompt templates, and `AGENTS.md` carries persistent repository instructions.

The React lifecycle checks follow React's documented effect model: an effect that connects to an external system can return cleanup, cleanup runs before a changed effect is re-established and on unmount, and Strict Mode's development setup/cleanup cycle is intended to expose incorrect cleanup assumptions.

Security methodology is based on OWASP's contextual XSS guidance and CSRF guidance, including the important distinction that CSRF defenses depend on the authentication/request model and that XSS can undermine CSRF mitigations.

Feature-Sliced Design concepts are adapted to the actual repository rather than enforced mechanically.

## License / internal use

Add the license appropriate for your organization before publishing this repository. If the repository contains internal architectural details, model/provider names, or company-specific endpoints, remove or generalize them before sharing outside the organization.
