---
name: frontend-review
description: Rigorous React/TypeScript code-review methodology covering correctness, reuse, modified FSD architecture, memory leaks, Redux/RTK Query, performance, accessibility, tests, and maintainability.
compatibility: OpenCode project skill
metadata:
  audience: frontend
  stack: react-typescript
---

# Frontend review methodology

## 1. Establish scope and evidence

Start from the requested diff. Read changed files and enough surrounding code to understand behavior. Follow imports/call sites only when they materially affect the change.

Never report a repository-level claim without searching for evidence first.

## 2. Correctness and edge cases

Check control flow, boundary conditions, stale data, invalid assumptions, null/undefined handling, error paths, loading/empty states, races, ordering, and behavior under repeated interaction.

### `??` versus `||` — explicit review rule

Review every newly introduced or materially changed fallback expression using `||`.

Ask whether `0`, `false`, or `""` is a legitimate value. If yes and fallback should occur only for `null`/`undefined`, prefer `??`.

Do not recommend `??` when the intended semantics are "fallback for any falsy value". Also inspect changed `??` expressions for the inverse semantic mistake.

## 3. React

Check:
- Rules of Hooks.
- Effects that are unnecessary because the value can be derived during render.
- Complete and correct effect dependencies; stale closures.
- Symmetric setup/cleanup for external systems.
- Event listener add/remove identity.
- Timers/intervals/animation frames cleanup.
- Observer cleanup: IntersectionObserver, ResizeObserver, MutationObserver.
- WebSocket/SSE/subscription teardown.
- Abort/cancellation for requests when stale work can affect correctness.
- Object URL revocation when created repeatedly or for bounded lifetime.
- Worker/third-party instance disposal.
- State updates/races from obsolete async operations.
- Unstable keys and state tied to list identity.
- Accidental render loops and unnecessary effects.
- Memoization only when it solves a demonstrated/credible cost; do not demand useMemo/useCallback mechanically.

## 4. Memory and resource leaks

Treat resource ownership explicitly: whoever creates/subscribes/starts a resource should normally have a clear disposal path.

Look for retained closures, listeners, subscriptions, timers, observers, sockets, workers, media streams, object URLs, external library instances, caches/maps growing without bounds, and long-lived references to large data/DOM nodes.

Distinguish a true leak from merely temporary allocation or harmless work after unmount.

## 5. TypeScript

Check unsafe `any`, assertions hiding invalid states, non-null assertions, incorrect narrowing, incomplete unions, overly broad types, duplicated domain types, unsafe indexing, API response assumptions, and avoidable loss of type inference.

Prefer types already defined by the project/API when semantically identical.

## 6. Redux Toolkit / RTK Query

Check:
- Server state is not unnecessarily duplicated into Redux/local state.
- Existing endpoints/hooks are reused where appropriate.
- Cache tags/invalidation and optimistic updates are coherent when changed.
- Selectors do not create avoidable unstable results or duplicate existing selectors.
- Reducers remain immutable in semantics (Immer mutation syntax is valid).
- Persisted state does not accidentally include inappropriate transient/sensitive data.
- Request lifecycle/error/loading handling is correct.

## 7. Reuse before invention

For every meaningful new component, hook, utility, helper, type, selector, constant, API wrapper, formatter, modal/control pattern, or abstraction:

1. Identify its responsibility.
2. Search relevant repository locations and names/synonyms.
3. Inspect plausible existing implementations.
4. Report duplication only if an existing solution is semantically appropriate and reuse would improve consistency/maintenance.

For the reference project, explicitly inspect `src/shared/ui`, `src/shared/shadcn`, relevant `features`, `widgets`, `apis`, `stores`, shared utils/types, and neighboring modules.

Do not force a generic abstraction merely to eliminate a few similar lines. Avoid premature abstraction.

## 8. Modified FSD architecture

The target project uses a modified Feature-Sliced Design: `app`, `pages`, `widgets`, `features`, `shared`; domain/API/state responsibilities may live in `apis` and `stores` rather than a standard `entities` layer. Additional project folders can include `layouts`, `assets`, `test`, and `types`.

Respect project-specific AGENTS.md and established repository conventions over textbook FSD.

Check:
- Lower-level/shared modules do not import higher-level business modules without an established exception.
- Slices/modules remain isolated rather than reaching into each other's internals.
- Consumers use established public entry points when the repository uses them; flag deep imports only when they violate an actual module boundary/convention.
- `shared` remains broadly reusable and does not absorb feature-specific business rules.
- Feature-specific logic stays close to the owning feature.
- App-level composition/configuration stays in app-level code.
- Cross-module coupling is minimized and dependencies point in the repository's intended direction.
- New files are placed according to responsibility, not convenience.

Do not "correct" this project into canonical FSD by demanding an `entities` layer that the repository intentionally does not use.

## 9. SOLID / DRY / KISS / YAGNI

Use these as diagnostic principles, never as automatic findings.

Report only concrete consequences such as:
- one module has multiple unrelated reasons to change;
- a dependency direction makes testing/reuse materially harder;
- duplicated business rules can diverge;
- an abstraction is substantially more complex than the problem;
- speculative extensibility increases surface area without a current use case.

Prefer the smallest design that fits current requirements and project conventions.

## 10. Performance

Check credible regressions: expensive work during render, avoidable repeated computation in hot paths, unnecessary broad subscriptions, unstable props causing expensive child rerenders, unbounded lists without appropriate strategy, repeated network work, large synchronous loops/main-thread work, resource churn, and accidental cache invalidation.

Do not report micro-optimizations without evidence or a plausible hot path.

## 11. Accessibility

For changed UI, check semantic elements, labels/names, keyboard interaction, focus management, disabled state, dialogs/popovers, form errors, and ARIA misuse. Prefer semantic HTML and existing accessible Radix/shadcn primitives.

## 12. Testing

Ask whether changed behavior has meaningful regression risk. Look for tests of business logic, edge cases, state transitions, error behavior, and important interactions. Do not demand tests for trivial wiring or implementation details.

For the reference project, tests use Vitest + Testing Library/happy-dom.

## 13. Security essentials

During every normal review perform a lightweight security pass: XSS sinks, unsafe URLs/navigation, untrusted HTML, secrets/tokens, dangerous browser storage, authorization assumptions in UI, unsafe postMessage usage, sensitive logging, injection into browser/DOM APIs, unsafe external links, and suspicious request construction.

For a dedicated audit, load `frontend-security`.

## 14. Finding quality bar

A finding must answer:
- What exactly is wrong?
- What code/evidence proves it?
- What realistic impact can occur?
- What is the smallest appropriate fix?

If one of these cannot be answered, investigate further or omit the finding.
