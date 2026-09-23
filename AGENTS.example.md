# Project instructions for OpenCode

Adapt this file to the target repository and save it as `AGENTS.md` in that repository root.

## Stack
- React 18 + TypeScript
- Redux Toolkit + RTK Query
- Tailwind CSS
- Radix/shadcn-style primitives
- Vitest + Testing Library

## Architecture
This repository uses a modified Feature-Sliced Design.

Primary layers/directories:
- `src/app`
- `src/pages`
- `src/widgets`
- `src/features`
- `src/shared`

Project-specific domain/API/state directories:
- `src/apis`
- `src/stores`

Additional directories may include `layouts`, `assets`, `test`, and `types`.

There is intentionally no standard FSD `entities` layer. Do not introduce one merely to match canonical FSD.

## Reuse
Before creating a new UI component, hook, utility, type, selector, API helper, constant, or abstraction, search for an existing semantically appropriate solution.

Pay particular attention to:
- `src/shared/ui`
- `src/shared/shadcn`
- existing feature/widget code
- `src/apis`
- `src/stores`
- shared utilities/types

## Verification commands
Use the actual package manager for the repository. Typical npm scripts in the reference project are:
- `npm run tsc:check`
- `npm run oxlint`
- `npm run oxfmt:check`
- `npm test`
- `npm run test:coverage`
- `npm run build`

Prefer focused verification during development; do not run expensive full-suite commands without reason.
