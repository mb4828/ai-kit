---
name: react-coding-standards
description: Enforce React + TypeScript coding standards including strict type safety, precise domain types that match the real data contract, hook extraction for shared logic, pure render/effect discipline, and lint-clean output. Use whenever writing, reviewing, or refactoring React/TypeScript frontend code to ensure production-ready quality and maintainability.
---

# React + TypeScript Coding Standards

Apply these standards to all React and TypeScript code you write or review, on top of the language-agnostic `general-coding-standards.md`. The goal is type-safe, lint-clean, maintainable components with no runtime surprises.

## Tooling and Gates

**Type checking:** `tsc --noEmit` must pass with zero errors. It is part of the build (`tsc --noEmit && vite build`).

**Linting:** ESLint with `typescript-eslint` and `eslint-plugin-react-hooks` (flat config in `eslint.config.js`) must pass with zero problems.

```bash
yarn lint          # eslint src
yarn tsc --noEmit  # type check
```

Fix all lint and type errors before considering code complete. Do not disable rules to silence a real problem — a `react-hooks/set-state-in-effect` or "refs during render" error is telling you the code is wrong, not that the rule is wrong.

## Strict TypeScript Configuration

`tsconfig.json` must enable the full strictness set. These are not optional — each one catches a class of real bug:

```jsonc
{
  "strict": true,
  "noUnusedLocals": true,          // dead imports/vars (e.g. an unused MUI import)
  "noUnusedParameters": true,
  "noUncheckedIndexedAccess": true, // arr[i] is T | undefined — forces a guard
  "noFallthroughCasesInSwitch": true,
  "forceConsistentCasingInFileNames": true,
  "moduleResolution": "Bundler"    // correct for Vite; not legacy "Node"
}
```

`noUncheckedIndexedAccess` is the highest-signal one: it makes `frames[tick]` return `Frame | undefined`, forcing an explicit guard that turns a silent `undefined` crash into a clear thrown error.

## Types Must Match the Real Data Contract

When types describe data from another system (a backend JSON schema, an API response), they must match what that system **actually emits** — not what you assume, and not a hand-waved superset.

**Never widen a union with `| string`** — it collapses the whole union to `string`, destroying narrowing and autocomplete everywhere the type is used:

```typescript
// BAD - the union is now just `string`; no narrowing, no autocomplete
export type ElevatorPhase = "idle" | "moving" | "stopping" | string;

// GOOD - a real closed union that narrows
export type ElevatorPhase = "idle" | "moving" | "stopping" | "loading" | "unloading";
```

**Match primitive types exactly.** If the backend emits `"version": 1` (a number), type it `number`, not `string`. Drift here is a silent bug: nothing fails loudly, the value just never behaves as expected.

**Validate at the boundary.** Parse untrusted input through a type guard that checks the required shape, and throw a clear error when it fails, rather than trusting a cast:

```typescript
function isSimulationFile(value: unknown): value is OutputFile {
  if (!value || typeof value !== "object") return false;
  const candidate = value as Partial<OutputFile>;
  return (
    typeof candidate.floors === "number" &&
    Array.isArray(candidate.elevators) &&
    Array.isArray(candidate.frames)
  );
}
```

## Extract Shared Logic into Custom Hooks

Duplicated stateful logic across components is a defect waiting to diverge. When two components carry the same refs, state variables, and effect, extract a single custom hook.

**BAD** — the identical enter/exit animation state machine (same refs, five state vars, same timeout) copy-pasted into two components.

**GOOD** — one `useEnterExitTransition(items)` hook returning `{ displayIds, displayMap, enteringIds, exitingIds }`, consumed by both. Name hooks `useX`, put them in `src/hooks/`, and give them a docstring explaining the invariant they maintain.

## Render and Effect Discipline

React's rules of hooks are enforced for a reason. Violations are real bugs under StrictMode and concurrent rendering.

**Keep state updaters pure.** Never call another `setState` from inside a `setState` updater — the updater must be a pure function of previous state. Do side-effecting state changes in the event/interval callback body instead:

```typescript
// BAD - setPlaybackRate called inside the setTick updater
setTick((value) => {
  const next = Math.min(lastTick, value + 1);
  if (next >= lastTick) setPlaybackRate(null); // impure updater
  return next;
});

// GOOD - both updates in the interval callback; each updater stays pure
const next = Math.min(lastTick, tickRef.current + 1);
tickRef.current = next;
setTick(next);
if (next >= lastTick) setPlaybackRate(null);
```

**Do not read a ref's `.current` during render.** Refs are for effects and event handlers. Reading one during render (e.g. `useState(myRef.current)`) can desync the UI. Compute the initial value directly instead.

**Avoid `setState` synchronously in an effect body** when it triggers cascading renders. Prefer deriving the value during render, or moving the update into the event source (interval, handler).

## Precompute Expensive Derived Data Once

Do not recompute an O(n) reduction on every render or every tick. Compute it once when the data is loaded and index into the result.

```typescript
// BAD - getStats() rescans every frame from 0 on every playback tick: O(tick × n)
const peakQueue = sim.frames.slice(0, tick + 1).reduce(/* ... */, 0);

// GOOD - built once in parseSimulation(); O(1) lookup thereafter
const peakQueue = sim.peakQueueByTick[tick] ?? 0;
```

## Prefer Maps over Object-with-Index Casts

For id-keyed lookups, use a `Map` with a precise value type rather than `Object.fromEntries(...) as Record<number, T>`. The cast lies about safety (index access can be `undefined`); the `Map` is honest and `.get()` returns `T | undefined`.

## Precise Props and Shared Types

- Type component props with domain types, not `string`. `direction: Direction`, not `direction: string`.
- Import a shared type instead of re-declaring its shape. If `PlaybackRate` exists, `import` it — don't rewrite `1 | 2 | null` in a props interface.
- Do not leave `any` (implicit or explicit) in component or hook signatures.

## Handle and Surface Errors in the UI

User-facing failures must be both handled and visible.

- Attach `onerror` alongside `onload` for `FileReader`, `fetch`, etc. A silent failure looks like the app did nothing.
- Render error state where the user will see it regardless of app mode. An error `Alert` that only renders in the empty-state branch is invisible once content is loaded — hoist it above the conditional so a later failure still shows.

## Standards Checklist

Before submitting React/TypeScript code, verify:

- [ ] `tsc --noEmit` passes with zero errors
- [ ] `eslint src` passes with zero problems (no rule disabled to hide a real bug)
- [ ] Types match the real data contract; no `| string`-widened unions; no lying casts
- [ ] Untrusted input validated at the boundary with a type guard + clear error
- [ ] Duplicated stateful logic extracted into a named custom hook in `src/hooks/`
- [ ] State updaters are pure; no `setState` inside another updater
- [ ] No ref `.current` read during render
- [ ] Expensive derived data precomputed once, not per-render/per-tick
- [ ] Id-keyed lookups use `Map`, not `Record` casts
- [ ] Props typed with domain types; shared types imported, not re-declared
- [ ] Error paths handled (`onerror`) and surfaced visibly in the UI
