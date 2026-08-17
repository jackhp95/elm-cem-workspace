# Phase 1 — L0 spike worklog (measured)

> Executes L0 of `~/Documents/code/planning/2026-08-17-phase1-html-elm-dedup-plan.md`.
> Read-only spike: measure engine A's real skip/degrade rate from a clean checkout
> and catalog concrete A-vs-B Elm divergences for shared components. Confirms §2.2
> empirically (and finds it UNDERSTATED the drift).

## Method

- Clean `pnpm install` in the phase1-dedup worktree.
- Engine A = `packages/elm-m3e/docs/scripts/examples-gen/` (`gen:examples-config` →
  `examples-to-elm.mjs` → `lib/to-elm.mjs`, compile-verified by `verify-examples.mjs`).
- Engine B = `packages/cem-figma-connect/profiles/m3-kit/emitters/elm.mjs` (reads Face C
  `elm-api-facts.json`).
- Inspected: committed `config/examples.generated.json` + `config/examples.skipped.txt`
  (A's last-committed output), the actual `packages/elm-m3e/src/**` module layout, Face C,
  and `M3e/Values.elm`.

## Finding 1 — the committed A output is STALE against the current library

Committed `config/examples.generated.json` renders, e.g.:

```elm
M3e.Button.view [ M3e.Button.variant M3e.Values.elevated ] [ Kit.text "Elevated" ]
```

None of `M3e.Button`, `Kit`, or `Native` exist in the current `packages/elm-m3e`:

- `find src -name Button.elm` → only `src/M3e/Component/Button.elm` (`module M3e.Component.Button exposing ( component ... )`) and `src/M3e/Build/Button.elm`. **There is no `M3e.Button` module** and **no `view` entry** — the strict entry is `component`.
- The current general surface is the `M3e` module exposing lowercase entries: `M3e.button`, `M3e.icon`, `M3e.card`, … **plus `M3e.text`** (`src/M3e.elm` line 3). So the current text seam is `M3e.text`, not `Kit.text`.
- `docs/kit/` (the old `Kit`/`Native` seam source dir) is **deleted** — it is neither tracked (`git ls-files docs/kit` → 0) nor present. `verify-examples.mjs`'s `SRC_DIRS` still lists `${M3E_ROOT}/docs/kit` (a stale reference).

## Finding 2 — running examples-gen fresh FATALs (harness bit-rot)

`npm --prefix docs run gen:examples-config` aborts before writing any output:

```
FATAL: top-layer verification did not build (harness/elm.json issue):
I need a valid elm.json ... the "source-directories" field lists ...
    .../packages/elm-m3e/docs/kit
I cannot find it though.
```

So A's compile-verify layer cannot build at all. The **true current compile-degrade rate
is effectively 100%**: every emitted example references `Kit.text`/`Native.*`/`M3e.Button.view`,
none of which resolve, so even with the harness dir patched every top would null.

The committed `examples.skipped.txt` (24 lines: 18 `filtered` script/link, 6 `degraded`
FabMenu×4 + NavMenu×2 with `The 2nd argument to view is not what I expect`) is a STALE
snapshot from before the `Kit` deletion / module-layout change. It is not a valid baseline.

## Finding 3 — A's generation is unwired from every gate

- `docs` `build:ci` = `gen:reference && check:nav && build:site` — **does NOT run `gen:examples-config`**.
- The only A code exercised by `gate-all` is the lib UNIT tests: elm-m3e `test:examples-gen`
  → `docs test:examples-gen` → `node --test scripts/examples-gen/lib/*.test.mjs`.
- Those unit tests (`lib/to-elm.test.mjs`) **assert the stale vocabulary** as expected output
  (`M3e.Button.view`, `Kit.text`, `Kit.link`, `Native.attribute`, `Native.node`, `M3e.Icon.view`).
  gate-all is green today *because* A's output never compiles in the gate and its unit tests
  enshrine the old bug.

## Finding 4 — divergence catalog (A vs B, shared components)

| Concern | Engine A emits (stale) | Engine B emits (current, Face C) | Notes |
|---|---|---|---|
| Button call | `M3e.Button.view [attrs] [content]` | `M3e.Button.component { content, action } [attrs] [children]` (record-double-list) | §2.2-1; A's module + entry both wrong |
| Text seam | `Kit.text "…"` | `Kit.text "…"` (userland seam, profile config) | B's `.figma.ts` is a template, never compiled; for A `Kit` is DELETED → must be `M3e.text` |
| Icon | `M3e.Icon.view [ M3e.Icon.name "add" ] []` (generic setter) | `M3e.Icon.icon M3e.Icon.add [] []` (opaque-`Name`, R-026) | §2.2-3 |
| Digit-leading enum | `M3e.Values.4SidedCookie` (invalid Elm ident → skip) | `M3e.Values.value4SidedCookie` (value-prefix fallback) | §2.2-2; `value4SidedCookie` confirmed present in `src/M3e/Values.elm` |
| Action record | (never emitted) | `action = <Mod>.none` | §2.2-4 |
| Native/plain HTML | `Native.node "tag"`, `Native.attribute "k" "v"` | `TypedHtml.<tag>` / `Native.attribute` (profile seam) | `Native` module deleted for A's compile target |

## Conclusion for the plan

- §2.2 is **confirmed and understated**: A is not merely "on an older API" — it targets
  three DELETED modules (`Kit`, `Native`, `M3e.Button`) and its compile harness is broken.
- The B track (L1→L3) is a clean, current, gate-verifiable extraction — proceed.
- **L5 is a wall as written** ("examples-gen compile+elm-review green; skip rate ≤ baseline"):
  there is no valid baseline (harness FATALs), A's generation is unwired from all gates, and
  making A compile-green is a revive-and-rewrite (new real seam module for text/native, module-
  layout migration `M3e.Button.view`→current surface, harness `docs/kit` repair, and a full
  rewrite of `to-elm.test.mjs`'s pinned expectations) — well beyond a facts migration. Surfaced
  after L4 with the coverage evidence; needs Jack's seam decision. See L4 worklog.
