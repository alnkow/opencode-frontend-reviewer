# Frontend code conventions

These rules apply to every agent:
- when you write or change code, follow them;
- when you review code, report every violation in added or changed lines.

Apply them only to code you write or change. Do not rewrite untouched code just to follow them.

## C1. Function that only returns → arrow function with implicit return

If a function body contains only a `return` statement, write it as an arrow function that returns the value directly.

```tsx
// bad
function UserName({ user }: UserNameProps) {
  return <span>{user.name}</span>;
}

const getFullName = (user: User) => {
  return `${user.firstName} ${user.lastName}`;
};

// good
const UserName = ({ user }: UserNameProps) => <span>{user.name}</span>;

const UserCard = ({ user }: UserCardProps) => (
  <div>
    <UserName user={user} />
  </div>
);

const getFullName = (user: User) => `${user.firstName} ${user.lastName}`;

const toOption = (user: User) => ({ value: user.id, label: user.name });
```

Exceptions: TypeScript overloads, functions that must be hoisted (used before their declaration), generators.

## C2. Import the `JSX` type from React

Do not use the global `JSX` namespace. Import the type explicitly. The global namespace is deprecated and removed in `@types/react` 19.

```tsx
// bad
const renderIcon = (): JSX.Element => <Icon />;

// good
import type { JSX } from 'react';

const renderIcon = (): JSX.Element => <Icon />;
```

`React.JSX.Element` is also fine when the file already imports the `React` namespace.

## C3. No inline styles

Do not use the `style` prop for values known in advance. Use Tailwind classes (combine them with the project's `cn()` helper when classes are conditional).

```tsx
// bad
<div style={{ marginTop: 8, display: 'flex' }} />

// good
<div className="mt-2 flex" />
```

The only exception: values computed at runtime that cannot be expressed with classes. Examples are measured sizes and positions, drag offsets, styles returned by virtualization libraries, and CSS custom properties that carry a runtime value.

## C4. No `!important`

Do not use `!important` in CSS/SCSS. Do not use the Tailwind important modifier either: `!mt-0` (Tailwind v3) or `mt-0!` (Tailwind v4).

Fix the cause instead: merge classes with `cn()` / tailwind-merge so the later class wins, use component variants, `data-*` / `aria-*` state selectors, or a more specific selector.

The only exception is overriding inline styles of a third-party library that cannot be configured. Such a line must have a comment explaining why.

## C5. Tests: do not find elements by visible text

Find elements by role, label, or test id:
- `getByRole('button', { name: ... })`, `getByRole('dialog')`;
- `getByLabelText(...)` for form fields;
- `getByTestId(...)` with a `data-testid` attribute when the element has no suitable role or label.

Do not use `getByText` / `queryByText` / `findByText` (and the `AllBy` variants) to find an element. Do not use `container.querySelector`. To check displayed text, find the element by role or test id and assert with `toHaveTextContent`.

```tsx
// bad
await user.click(screen.getByText('Save'));
expect(screen.getByText('Loading...')).toBeInTheDocument();

// good
await user.click(screen.getByRole('button', { name: 'Save' }));
expect(screen.getByTestId('orders-loader')).toBeInTheDocument();
expect(screen.getByRole('alert')).toHaveTextContent('Failed to load orders');
```

## C6. Names describe what the value is and what the function does

Collections:
- An array has a plural name or a `List` suffix: `users`, `userList`. A singular name for an array is a violation.
- A `Map`, `Set` or object used as a lookup has a `Map` / `Set` / `ById` suffix: `userMap`, `selectedIdSet`, `usersById`.

Booleans start with `is` / `has` / `can` / `should`: `isOpen`, `hasError`, `canEdit`. Props that mirror HTML or library APIs keep the original name: `open`, `disabled`, `checked`.

Functions start with a verb that matches what they do:
- `get*` / `fetch*` / `load*` return data (computed, from the store or from the API);
- `set*` / `update*` / `add*` / `remove*` / `toggle*` change state or data;
- `is*` / `has*` / `can*` return a boolean;
- `handle*` are event handlers declared in a component; `on*` are handler props;
- `use*` is only for hooks;
- `render*` return JSX.

No meaningless names for values used beyond a few lines or exported: `data`, `item`, `obj`, `arr`, `res`, `tmp`, `temp`, `val`, `flag`, `list1`, `newData`. Short callback parameters such as `users.map((user) => ...)` are fine.

A name must not contradict the behavior. These are violations:
- `getUser` that also writes something;
- `isValid` that returns a string;
- `userList` that holds a single object;
- `useFormatDate` that calls no hooks.

Constants follow the casing used in neighboring files.
