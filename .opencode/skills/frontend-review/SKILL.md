---
name: frontend-review
description: React/TypeScript code-review checklist covering correctness, impact on surrounding code, semantics, component decomposition, memory leaks, Redux/RTK Query, modified FSD architecture, reuse, performance, accessibility, tests and conventions C1–C6.
compatibility: opencode
metadata:
  audience: frontend
  stack: react-typescript
---

# Frontend review checklist

Go through the sections in order for every changed file. Each section says what to report and what not to report.

## 1. Scope and evidence

Start from the diff. Read every changed file in full, not only the hunks. Follow imports and call sites when they affect the change.

Never make a repository-level claim ("this already exists", "this is unused", "nobody calls this") without searching first.

## 2. Impact on surrounding code

A change often makes nearby code redundant, inconsistent or wasteful. Reviews usually miss this, so check it explicitly.

Look at code directly connected to the change:
- the rest of the changed file;
- callers and consumers of changed functions, components, hooks, props, types, selectors and endpoints (search for usages);
- the code that the changed code calls.

Report when the change made something:
- **redundant**: a check, guard, fallback or condition that can no longer trigger; a prop, parameter, state, import, export, type, constant, CSS class or test that is no longer used; a `useMemo` / `useCallback` / `memo` that no longer has a purpose;
- **inconsistent**: one call site updated and another not; a type changed but mappers, mocks, tests or default values not; a concept renamed but nearby code still uses the old name;
- **wasteful**: the same data is now requested or computed twice; data is converted back and forth; an extra render, effect or request appeared around the change;
- **replaceable**: nearby code now duplicates the new code, or the new code duplicates a helper next to it.

Use category `impact`. Point to both the changed line and the affected line.

Do not report problems in neighboring code that existed before the change and are unrelated to it.

## 3. Correctness and edge cases

Check control flow, boundary conditions, stale data, invalid assumptions, null/undefined handling, error paths, loading/empty states, races, ordering, and behavior under repeated interaction.

### `??` versus `||`

Review every new or changed fallback that uses `||`.

Ask whether `0`, `false` or `""` is a legitimate value. If it is, and the fallback should apply only to `null`/`undefined`, recommend `??`.

Do not recommend `??` when the intent is "fallback for any falsy value". Also check new `??` expressions for the opposite mistake.

## 4. Semantics: does the code mean what it says

Report code that obviously contradicts its own intent:
- a comment that describes something different from what the code does;
- an inverted or wrong condition (`if (isEmpty) renderList()`), a wrong variable (`order.id` where `user.id` is meant), a wrong operator or comparison;
- a condition that is always true or always false, unreachable branches, dead code;
- leftovers in changed code: `console.log`, `debugger`, commented-out code, hardcoded test data, IDs or URLs;
- magic numbers or strings with domain meaning that is not obvious from context (suggest a named constant);
- a value whose meaning does not match how it is used.

Use category `semantics`. If it causes a real bug, rate it as a bug (HIGH or MEDIUM). Naming problems belong to convention C6, not to this section.

## 5. React

Check:
- Rules of Hooks.
- Effects that are unnecessary because the value can be derived during render.
- Complete and correct effect dependencies; stale closures.
- Symmetric setup/cleanup for external systems.
- Event listener add/remove identity.
- Timer, interval and animation frame cleanup.
- Observer cleanup: IntersectionObserver, ResizeObserver, MutationObserver.
- WebSocket/SSE/subscription teardown.
- Abort/cancellation of requests when stale results can affect correctness.
- State updates and races from obsolete async operations.
- Mutation of props, state or store data (`.sort()`, `.reverse()`, `.splice()`, direct assignment on state arrays/objects).
- Unstable keys and state tied to list identity.
- Accidental render loops.
- Memoization only when it solves a real cost. Do not demand `useMemo`/`useCallback` mechanically.

### Component decomposition

Report that part of a component should be extracted into its own component when at least one is true:
- a JSX block has its own state, effects or handlers that the rest of the component does not use;
- the same markup appears two or more times and differs only in data;
- `.map()` renders non-trivial markup (roughly more than 10 lines, or with its own handlers): extract the item component;
- the component renders several independent sections and its JSX is long (roughly more than 100 lines);
- conditional branches render large, unrelated pieces of UI.

Do not report extraction when:
- the block is small (roughly under 10–15 lines) and used once;
- the extracted component would only forward all props of the parent;
- the only argument is "the file is long".

The extracted component goes next to its owner (same slice/folder). It goes to `shared` only if it is actually reused and has no business logic.

**HIGH:** a component declared inside another component's body (for example `const Item = () => ...` inside `List`). It is recreated on every render, so its state resets and its DOM remounts. Move it to module level.

Category: `decomposition`.

## 6. Memory and resource leaks

Whoever creates, subscribes to or starts a resource must have a clear disposal path.

Look for retained closures, listeners, subscriptions, timers, observers, sockets, workers, media streams, object URLs, third-party library instances, caches/maps growing without bounds, and long-lived references to large data or DOM nodes.

Distinguish a real leak from a temporary allocation or harmless work after unmount. Do not demand cleanup where nothing needs cleaning up.

## 7. TypeScript

Check unsafe `any`, assertions hiding invalid states, non-null assertions, incorrect narrowing, incomplete unions, overly broad types, duplicated domain types, unsafe indexing, unchecked API response assumptions, and avoidable loss of type inference.

Prefer types already defined by the project or the API when they mean the same thing.

## 8. Redux Toolkit / RTK Query

Check:
- Server state is not copied into Redux or local state without a reason.
- Existing endpoints/hooks are reused where appropriate.
- Cache tags, invalidation and optimistic updates are coherent when changed.
- Selectors do not create unstable results and do not duplicate existing selectors.
- Reducers stay immutable in meaning (Immer mutation syntax is fine).
- Persisted state does not include transient or sensitive data.
- Request lifecycle, loading and error handling are correct.

## 9. Reuse before invention

For every new component, hook, utility, helper, type, selector, constant, API wrapper, formatter or UI pattern:

1. Identify its responsibility.
2. Search the repository by name and by synonyms.
3. Open plausible existing implementations.
4. Report duplication only if an existing solution fits the same meaning and reuse would improve consistency.

Check `src/shared/ui`, `src/shared/shadcn`, relevant `features`, `widgets`, `apis`, `stores`, shared utils/types and neighboring modules.

Do not force a generic abstraction to remove a few similar lines. Extracting a component inside the same feature (section 5) is decomposition, not premature abstraction.

## 10. Modified FSD architecture

The project uses a modified Feature-Sliced Design: `app`, `pages`, `widgets`, `features`, `shared`. Domain/API/state code lives in `apis` and `stores` instead of a standard `entities` layer. There may also be `layouts`, `assets`, `test`, `types`.

The project's AGENTS.md and established repository conventions win over textbook FSD.

Check:
- Lower layers and `shared` do not import higher-level business modules without an established exception.
- Slices do not reach into each other's internals. A feature does not depend on another feature unless the repository has an established pattern for it.
- Dependencies point in the repository's intended direction, and cross-module coupling stays minimal.
- Consumers use public entry points where the repository uses them. Flag deep imports only when they break an actual boundary.
- `shared` stays generic and does not absorb feature business rules.
- Feature logic stays in its feature; app-level composition stays in `app`.
- New files are placed by responsibility, not convenience. Code is not placed in a higher layer than it needs (for example, logic used by one feature put into `pages` or `app`).

Do not demand an `entities` layer.

## 11. SOLID / DRY / KISS / YAGNI

Use as reasoning tools, never as findings by themselves. Report only concrete consequences:
- one module has several unrelated reasons to change;
- a dependency direction makes testing or reuse materially harder;
- duplicated business rules can diverge;
- an abstraction is much more complex than the problem;
- needless indirection: wrappers or layers that add nothing;
- speculative extensibility adds surface area without a current use.

Prefer the smallest design that fits current requirements and project conventions.

## 12. Performance

Report credible regressions: expensive work during render, repeated heavy computation in hot paths, broad store subscriptions, unstable props that cause expensive child re-renders, large lists without virtualization where the scale requires it, repeated network requests, long synchronous main-thread work, accidental cache invalidation.

Do not report micro-optimizations without a plausible hot path.

## 13. Accessibility

For changed UI check semantic elements, accessible names and labels, keyboard interaction, focus management, disabled state, dialogs and popovers, form errors, and ARIA misuse. Prefer semantic HTML and the existing accessible Radix/shadcn primitives.

## 14. Tests

Ask whether changed behavior has real regression risk: business logic, edge cases, state transitions, error behavior, important interactions. Do not demand tests for trivial wiring.

Tests use Vitest + Testing Library + happy-dom. In changed test files also check convention C5 (no element lookup by visible text).

## 15. Security essentials

Lightweight pass on every review: XSS sinks, unsafe URLs/navigation and redirects, untrusted HTML, secrets/tokens in code, sensitive data in browser storage or logs, UI-only authorization, unsafe `postMessage`, injection into DOM APIs, unsafe external links, request construction from untrusted input, CSRF where the browser attaches credentials automatically (cookies), unsafe parsing/deserialization, prototype pollution through merging untrusted objects.

Report only issues with a plausible path in this code, not theoretical ones.

For a dedicated audit, use the `frontend-security` skill.

## 16. Conventions C1–C6

The conventions are in your instructions. If they are missing, read `.opencode/instructions/frontend-conventions.md`.

- Check every added or changed line against C1–C6.
- Report violations only in the `## Conventions` section, one line each: file, line, rule ID, what to change.
- If the same rule is violated several times in one file, put it on one line with all line numbers.
- C4 also covers the Tailwind important modifier: `!mt-0` and `mt-0!`.
- C5 applies to test files (`*.test.*`, `*.spec.*`).
- Do not report conventions in unchanged lines.

## 17. Quality bar

Every finding must answer:
- What exactly is wrong?
- Which code proves it?
- What realistic impact will it have?
- What is the smallest fix?

If any answer is missing, investigate further or drop the finding.
