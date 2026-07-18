---
name: general-coding-standards
description: Language-agnostic principles for readable, maintainable code, organized as core concepts — Modularity, Encapsulation, Boundaries, Simplicity, Dependencies, and Observability. Use whenever writing, reviewing, or refactoring code in any language, alongside the language-specific standards.
---

# General Coding Standards

Language-agnostic principles for code that stays readable and maintainable as it grows. Apply these in any language, together with the relevant language-specific reference.

The test underlying all of them: **a person should be able to read a file top to bottom and understand it without holding the rest of the system in their head.** When two principles pull in different directions, favor the one that makes the code more obvious to the next reader.

## Modularity

Applies whenever you decide where code goes: what belongs in this function, this file, this module, and which way the imports run.

### Single responsibility, at every level

Each function, class, and module should have one clear purpose that its name predicts. If you can't name it without an "and," it's doing too much.

### Keep units small

- **Functions:** under 30 lines, or low cyclomatic complexity. Past that, extract well-named helpers.
- **Files:** under 300 lines. Past that, separable concerns have piled up — break them out rather than adding internal signposting.

Size is a proxy for focus: a unit that outgrows these is doing more than one thing.

### One home per concept

Define each type or constant *with the code that owns it*, at the lowest layer that needs it; everything above imports it from there. A catch-all `types`/`utils`/`constants` file is a junk drawer — unrelated things coupled by proximity, with no signal about where a concept actually lives. A shared file is justified only when something is genuinely cross-cutting and has no single owner.

### Layering

Lower-level code never imports from higher-level code; producers sit below consumers. This keeps the layering legible and prevents import cycles. A pipeline, workflow, or request handler should read top to bottom as the sequence of steps it performs, calling well-named helpers — not interleave orchestration with low-level detail.

## Encapsulation

Control where state and side effects live: hide them behind a small interface, or avoid them entirely.

### Functions vs. classes

Reach for a class sooner than instinct suggests. The common failure mode is not over-using classes — it's writing a pile of free functions that all take the same handle and thread state between them: a class that was never declared. If you're about to write a third function whose first parameter is `client`, stop and make it a class.

**Reach for a class when any of these appear:**

- **The same handle keeps showing up as a parameter.** A client, connection, session, or config passed into every function in the file is state pretending to be a parameter. Give it a home.

```
// Before: the client is passed to everything; callers must hold and forward it.
createClient()
requestA(client, ...)
requestB(client, ...)

// After: the object owns the resource; callers just call methods.
class Service {
  private client
  constructor() { this.client = createClient() }
  requestA(...) { ... }
}
```

- **State accumulates across calls.** A running total, a cache, a counter, an id chaining one call to the next. If callers must carry a value out of one function and back into the next, that value is instance state.

- **Callers must sequence calls in a fixed order.** `create → use → finalize` is a lifecycle, and lifecycles belong to objects. The class enforces an order that free functions could only document.

- **Variants share a skeleton and differ in a few details.** A base class holding the common flow, with subclasses supplying the differences, beats the same `switch` repeated across functions — and beats a "definition object" of settings plus callbacks, which is a class hierarchy in disguise.

```
// Before: a record of settings + function fields, dispatched through generic helpers.
const kinds = {
  ask:    { effort: 'medium', instructions: () => [...], mutates: false },
  create: { effort: 'medium', instructions: () => [...], mutates: true },
}
function run(kind, input) { /* generic flow, branching on kinds[kind] */ }

// After: the shared flow lives once in the base; each variant declares only what differs.
abstract class Handler {
  abstract effort
  abstract instructions
  abstract run(input)
  protected sharedFlow(input) { ... }   // written once
}
class Ask extends Handler { ... }
class Create extends Handler { ... }
```

**Smells that mean "this should have been a class":**

- Every function in a module takes the same first argument (`client`, `ctx`, `config`).
- A function's return value exists only to be handed straight into the next function.
- The same three or four parameters thread through a chain of helpers.
- Several functions `switch` on the same `kind`/`type` field.
- Free functions mutate a module-level variable to remember something between calls.

**Functions are still the right choice when:**

- The logic is a pure transformation — inputs → outputs, nothing retained.
- It's a single operation with no setup and no lifecycle.
- The data it would hold is **owned and edited elsewhere**; a class caching a stale copy is worse than taking it as a parameter.
- The consumer favors immutable data (e.g. React state) — a mutable object fights the framework's model.
- You only want to group related code — that's a module's job. A class that's just a namespace for stateless functions is ceremony.

### Keep a pure core; push side effects to the edges

Make the central logic a function of its inputs that returns its outputs. Do I/O — saving, network, effectful logging — at the outermost layer, or hand it back to the caller.

```
// Before: the core reaches out and persists, coupling logic to storage.
function run(input, storage) {
  const result = compute(input)
  storage.save(result)          // hidden side effect
  return result
}

// After: pure; the caller decides what to persist.
function run(input) { return compute(input) }   // caller: save(run(input))
```

Pure cores are trivially testable (data in, data out), reusable across callers, and free of hidden coupling. Two corollaries:

- **Avoid mutable global state.** Pass data through parameters and return values. Module-level *constants* are fine; mutable globals that carry state between calls make behavior depend on invisible history and defeat testing.
- **Design for testability.** Inject collaborators (pass them in, defaulting to the real one) rather than hard-wiring them, and avoid hardcoded values a test can't vary.

## Boundaries

Everything crossing the edge between your system and the outside — external data, another system's types — is untrusted until you make it trustworthy.

### Validate at the boundary; return domain types

Untrusted or externally-shaped data (an API response, a parsed file, user input) should be validated **once**, at the edge where it enters, and everything inside should work with clean domain types.

- Put the schema/validation at the single point of entry; don't re-validate downstream.
- Return a small, purpose-built result — not the vendor's raw object. If callers reach into `response.steps[3].content` or re-parse what you returned, your boundary is leaking.
- Keep the validator private to the module that owns the boundary, so downstream code is *unable* to receive unvalidated data — enforced by the type it gets back.

### Derive types from the source of truth

If a library or schema already defines a shape, reference it — don't retype it. A hand-copied mirror is a second source of truth that silently drifts on the next version bump.

- Reference an external type by name, or by indexing into it (`ReturnType`, indexed access, generated types), rather than redeclaring its fields.
- Before writing a "types" mirror of an API, check whether it already exports what you need.
- Exception: if deriving the type takes an unreadable chain of transformations, a small local type may be clearer — but comment *why* it exists.

## Readability & Simplicity

Applies to every line: choose the form a reader parses on sight, and cut what doesn't carry meaning.

### Favor the obvious over the clever

Before writing a clever form, look for the plain one the platform already supports (a named export, a simpler API) — the convoluted way usually only looked necessary because you hadn't found the simple one. This matters most in type-level code, generics, and metaprogramming, where a construction that takes minutes to decode is a liability even when correct.

- Reach for the form a competent reader parses on sight; prefer a named intermediate over a deeply nested one-liner.
- If the clever form is genuinely required, isolate it behind a name and comment the reason — so no one "simplifies" it back into a bug.

### Don't repeat yourself

Two functions that differ only slightly are one function; two loops building the same total are one accumulator. Collapse them — but don't force unrelated code together just because it looks alike. DRY is about a single source of truth for one idea, not about deduplicating text.

### Cut ceremony

Every token a reader parses should carry meaning. Remove the ones that don't:

- **Section-divider comment banners.** If a file needs internal signposting, it's doing too much — split it.
- **Wrapper types for every parameter bag.** A single-use `interface FooRequest` next to `foo(req: FooRequest)` is often clearer inlined as the parameter's shape.
- **Reflexive immutability/visibility modifiers** applied by habit. Use them where they express a real constraint, not everywhere.

Removing noise isn't the same as being terse: keep meaningful names and necessary type annotations. Cut what doesn't inform, not what does.

### Prefer data over code for static configuration

If a value is a fixed list of options, instructions, or declarations, express it as **data** (a constant array/map), not as a function that returns it. Data is easier to scan, diff, and reuse. Reserve functions for values that genuinely depend on inputs.

### Comments explain *why*, not *what*

The code already says what it does. A comment earns its place by capturing what the code *can't*: a non-obvious constraint, the reason for an unusual choice, a boundary rule.

```
// Bad — restates the code:
// increment the counter
counter += 1

// Good — a fact the code can't show:
// The API omits `steps` on streamed responses, so require it here.
type Response = Base & { steps: Step[] }
```

Mark deferred work with a trackable tag — a ticket id or a date — so it doesn't rot silently: `TODO(PROJ-123): …` or `TODO(2026-02-15): …`.

**The one exception:** All files must have a docstring at the top explaining the purpose of the file and all functions, methods, public variables, and public APIs must have doctrings explaining their purpose. This is *critical* for readability!

## Dependencies

Every dependency is a liability you don't control — for security, maintenance, and build weight. Add them deliberately.

- **Prefer what you already have:** the standard library first, a well-maintained open-source package second. Treat a proprietary or closed-source dependency as a decision to raise with the owner before adding it.
- **Don't add a dependency for something trivial** you could write in ~10-20 lines.
- **Pin exact versions** for reproducible builds, and note *why* a non-obvious one is there.
- **Vet before adopting:** recent maintenance, active issue resolution, a security track record, and a small transitive-dependency footprint.

## Observability

Logging is for the reader debugging later, not a transcript of everything.

- Log at meaningful transitions, on a single consistent line — not a large payload dump before and after every call.
- Gate verbose diagnostics behind a debug flag so normal runs stay quiet.
- One well-placed structured log beats ten redundant ones.

## Checklist

Before considering a change complete, confirm each statement holds:

**Modularity**

- [ ] Every function, class, and module can be named without an "and."
- [ ] Every function is under 30 lines, or low cyclomatic complexity.
- [ ] Every file is under 300 lines.
- [ ] Every type and constant is defined in the module that owns it — no catch-all `types`/`utils`/`constants` file.
- [ ] Imports run one direction only (higher-level to lower-level), with no cycles.

**Encapsulation**

- [ ] No two functions share the same leading handle (`client`, `ctx`, `config`) or thread state between them; where they would, there is a class.
- [ ] Every class holds state or a resource, or supplies polymorphism — none is just a namespace for stateless functions.
- [ ] The core logic performs no I/O; saving, network, and effectful logging happen at the outermost layer.
- [ ] No mutable global state — module-level values are constants only.

**Boundaries**

- [ ] External or untrusted data is validated exactly once, at its entry point, with no downstream re-validation.
- [ ] Boundary functions return domain types, not the vendor's raw object.
- [ ] Every externally-defined shape is referenced from its source rather than re-declared locally.

**Readability & Simplicity**

- [ ] No two functions, blocks, or accumulators differ only by a value or a name.
- [ ] Every non-obvious construction carries a comment saying why it is needed.
- [ ] Every comment states why, not what the code already says.
- [ ] All files have a docstring at the top stating its purpose.
- [ ] All functions, methods, public variables, and public APIs have a docstring.
- [ ] No section-divider comment banners.
- [ ] No single-use types wrapping a function's parameters.

**Dependencies**

- [ ] Every new dependency does something the standard library plus 20 lines cannot.
- [ ] Every new dependency is pinned to an exact version.

**Observability**

- [ ] Every log is a single structured line at a meaningful transition, not a payload dump.
- [ ] Verbose diagnostics are gated behind a debug flag.
