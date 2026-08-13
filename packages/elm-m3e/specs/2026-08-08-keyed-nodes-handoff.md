# Handoff — keyed nodes / lazy support across HtmlIr, elm-typed-html, M3e, elm-cem

> Written on `Avetta-YKN6HHWJHR` on 2026-08-08. Intended for the **Jacks-MBP-2**
> machine, which this machine's Paseo daemon (local-only, `127.0.0.1:6767`)
> cannot reach — hence a file rather than a spawned agent.
>
> Paste the section below "## Task" into a fresh agent as its initial prompt.

## Task

Add keyed-node and lazy-node support to the Elm HTML representation stack, and
make `elm-cem` emit components that can use them. Concretely: `Html.Keyed` and
`Html.Lazy` equivalents must exist in the intermediate representation, survive
through `elm-typed-html`'s phantom-typed layer, and be reachable from generated
`M3e.*` components.

This is an API/architecture change, not a bug patch. Do NOT hand-edit emitted
files to make a gate pass — change the config or the emitter and regenerate.

## Context

`elm-m3e` renders `@m3e/web` Material 3 custom elements from Elm. A real,
reproduced, user-visible defect motivates this work, and keyed nodes are the
chosen fix.

### The defect

Several `m3e-*` custom elements **reflect a default value onto themselves as an
attribute when they upgrade**. Elm never authored those attributes, so Elm's
virtual DOM has no record of them.

That is harmless until Elm **patches** an existing element across a route
change. Measured on the built docs site:

| navigation | `sameNode` | `size` attribute | app bar height |
| --- | --- | --- | --- |
| hard load `/examples/list-detail` | — | `"small"` (element-written) | 64px |
| `/examples/settings` → `/examples/list-detail` (soft) | **true** | **`null`** | **24px** |
| `/examples/mail` → `/examples/travel` (soft) | false | `"small"` | 64px |

`settings` authors `size="medium"`; `list-detail` authors `M3e.appBar []` with
no size at all. Elm reuses the node, diffs `"medium"` → absent, and removes the
attribute **it believes it owns**. The element is already upgraded, so nothing
re-applies its default. The bar collapses to 24px and STAYS collapsed for every
subsequent patched route. A hard reload always looks correct, which is what
makes it read as intermittent.

The `mail → travel` row is the same author-then-omit shape in the source but
Elm happens to REPLACE rather than patch there, so it silently passes.

### Blast radius

13 element types self-write attributes Elm never authored:

```
M3E-APP-BAR       role                    M3E-LIST          role, variant
M3E-CARD          orientation             M3E-LIST-ITEM     role
M3E-DIVIDER       role                    M3E-NAV-BAR       mode, role
M3E-FAB           role, size, tabindex    M3E-NAV-ITEM      aria-current, orientation, role, tabindex
M3E-ICON          aria-hidden, filled,    M3E-NAV-RAIL      mode, role
                  role, variant           M3E-SLIDER-THUMB  value
M3E-ICON-BUTTON   role, shape, size, tabindex, width
M3E-LINEAR-PROGRESS-INDICATOR  aria-valuemax/min/now, buffer-value, mode, role, value, variant
```

The bug bites wherever an attribute is **both** Elm-authored on one route and
element-defaulted on another: `size` (app-bar, fab, icon-button), `variant`
(icon, list), `mode` (nav-bar/rail), `orientation` (card, nav-item),
`shape`/`width` (icon-button), `value` (progress, slider-thumb).

### Why keyed nodes

Keying the route roots forces Elm to REPLACE rather than PATCH across route
changes, so every soft nav behaves like a hard load: a fresh element upgrades
and re-reflects its own defaults. This was chosen over the two alternatives:

- *Emit defaults from the generator* (make Elm author every attribute the
  element reflects, so its diff is authoritative) — rejected for this pass.
- *Per-call-site explicit `size`* — rejected as a symptom fix that re-breaks on
  the next bare `M3e.appBar []` or any of the other 12 element types.

## Relevant files

- `elm-html-intermediate-representation` — the IR. Needs keyed/lazy node
  constructors. This is the foundation; nothing above it can expose what the IR
  cannot represent.
- `elm-typed-html` — the phantom-typed layer over the IR. Keyed/lazy must
  preserve the child-admission types, not escape them.
- `elm-cem` — the generator. Must emit components able to participate in keyed
  and lazy trees.
- `elm-m3e/src/M3e*` — generated output; regenerate, never hand-edit.
- `elm-m3e/docs/tests-browser/soft-nav-attribute-ownership.spec.ts` — a failing
  regression test already written against this bug (see below). Carry it over
  or re-create it; it is the acceptance signal.

## Current state

- Root cause is **confirmed**, not hypothesised — evidence table above.
- A failing Playwright regression spec exists in the `elm-m3e` worktree
  `dashboard-nav-flex-col` at
  `docs/tests-browser/soft-nav-attribute-ownership.spec.ts`. It currently fails
  with `Expected: "small" / Received: null`. It is **deliberately uncommitted**
  there, because committing it would turn `npm run gate` red.
- No fix of any kind has been attempted. There is no partial work to unwind.

## What was tried

- **Probing the app bar element alone** (shadow root, `:defined`, upgrade
  state, console errors) — showed no difference at all between hard and soft
  nav. Misleading; the difference is the attribute, not the upgrade.
- **A single-hop repro** (`list-detail` → `supporting-pane`) — passes, because
  neither route authors `size`. The bug needs the author-then-omit pair.
  Use `settings` → `list-detail`.

## Decisions

- Keyed nodes are the fix — the user's explicit call, over emitting defaults
  from the generator.
- The change must land across IR → typed-html → M3e → elm-cem together; a
  partial layer is not shippable, since each layer can only expose what the one
  below represents.
- Generated code is the norm and the goldens are the specification.
- If a change to the emitter is claimed to be a no-op for other brands, prove it
  by A/B generation (pristine generator vs modified, same config, diff the
  trees) — NOT by regenerate-and-diff, because several brand repos carry
  pre-existing staleness that masks the real answer.

## Acceptance criteria

- [ ] `Html.Keyed`-equivalent and `Html.Lazy`-equivalent nodes exist in the IR.
- [ ] Both survive `elm-typed-html`'s phantom typing without weakening
      child-admission guarantees.
- [ ] `elm-cem` emits components usable inside keyed/lazy trees; goldens updated
      by regeneration.
- [ ] The soft-nav regression spec passes: `/examples/settings` →
      `/examples/list-detail` keeps `size="small"` and 64px height.
- [ ] Full `npm run gate` green in `elm-m3e`.
- [ ] No emitted file hand-edited.

## Constraints

- These repos commit directly to `main`; recent history has no feature branches.
  **Ask before branching** rather than assuming.
- `elm-cem` needs `elm` on PATH or it fails with an opaque "Compilation failed"
  AND empties the output `M3e/` directory. Prefix PATH with
  `elm-cem/node_modules/.bin`.
- Sibling repos resolve via `../../<name>`; symlinks are expected to exist.
