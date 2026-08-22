# DAG rework — Task 1 (dual-emit scaffold) + Task 2 (NavMenu PoC) proof

Companion to `docs/plans/2026-08-21-dag-rework-plan.md`. Records the captured
evidence for Tasks 1 & 2. **Task 3 (whole-brand cutover) and Task 4
(materialize) were NOT started** — Task 4 is blocked on OQ-1/OQ-3/OQ-4, and
Task 3 waits for this PoC to be reviewed (per the dispatch scope).

Proceeded under **D-DAG1 (Shape A)** and **D-DAG6**'s explicit allowance that
"Tasks 1–2 (emitter PoC) can start under the Shape A assumption", because
Task 1.4 is **dual-emit**: the per-element `compBuildModule` / `M3e.Build.*`
output is untouched; the new composed builders are emitted under a temporary
`M3e.Build2.*` namespace. Provably reversible — un-wire one call in `Emit.elm`.

## What changed (committed)

- **NEW** `pipeline/elm-cem/codegen/Generate/Phantom/Emit/BuildPackage.elm` —
  the Shape A composed-builder emitter. Per `_families` entry it renders one
  `<lib>.Build2.<Family>` module carrying every member (root + members) builder
  surface, **member-prefixed** (same scheme as `FamilyPackage`), with every
  element-tier type + slot-placer reference resolved through
  `import <lib>.Component.<Family> as Component` (the façade). Builder mechanics
  stay `<lib>.Forge.Internal as B`. Reads `Brand.comps`/`Comp` directly (no
  rendered-text re-parse) and reuses the shared `AttrsRow`/`Shared`/`Component`
  helpers, so it can never drift from the per-element emitter's attr/slot
  decisions.
- **MODIFIED** `pipeline/elm-cem/codegen/Generate/Phantom/Emit.elm` — Step 1.4
  DUAL-EMIT wiring: `BuildPackage.files brand families` is threaded in
  ALONGSIDE the existing per-element `compBuildModule` concatMap (line 131,
  NOT removed) and the `FamilyPackage.files` result; its output is appended to
  `allFiles`. The `Emit.elm:130` per-element builder emission is unchanged.

The **generated** `M3e.Build2.*` tree and the regen-updated `elm.json`
exposed-modules are intentionally NOT committed — they are fully reproducible
from the committed emitter via `cd brands/m3e/generated/package/elm-m3e &&
npm run gen:src`, and keeping them out of the tracked package leaves the shipped
6-package split pristine (Step 3.5: "generated output NOT yet promoted").

## Task 1.4 — dual-emit acceptance

- `elm make Generate.elm` (codegen) → **Success! Compiled.**
- `npm run gen:src` → **exit 0**; emits both trees. 21 `M3e.Build2.<Family>`
  modules generated (one per `_families` entry), all `elm-format`-clean.
- **Dual-emit purity**: after regen, `git status --short
  brands/m3e/generated/package/elm-m3e/src/ | grep -v Build2/` → **0 changed
  files**. The shipped per-element `M3e.Build.*` / `M3e.Element.*` /
  `M3e.Component.*` surface is byte-identical.
- **Determinism**: two consecutive `gen:src` runs produce byte-identical
  `Build2/` trees (`diff -rq` clean).
- **`tools/ab-elm-cem.sh`**: the ONLY difference between the pristine generator
  and the workspace generator is `Only in .../out-workspace/M3e: Build2`
  (450 workspace files vs 429 pristine = +21). Every other emitted file is
  byte-identical. This is the expected "generated output not yet promoted /
  Face-A not re-baselined" state (Task 8 re-baseline is out of scope) — a
  purely additive diff, not a regression.
- `pnpm --filter elm-cem run test` → **exit 0, Failed: 0** (phantom gate ALL
  GREEN, split, facts-bundle-schema, eject, all `test:*`).
- `pnpm --filter elm-cem run check` → **exit 0** (format/gates/neutrality/skills).

## Task 2 — NavMenu proof-of-concept (all four steps PASS)

Family: `NavMenu` = root `NavMenu` + members `NavMenuItem` (label `Item`),
`NavMenuItemGroup` (label `ItemGroup`) — verified in
`brands/m3e/inputs/cem/config/slots.json`.

### 2.2 — surface equivalence (THE Shape A crux)

Union of the three per-element `M3e.Build.*` exposing lists, member-prefixed,
vs the composed `M3e.Build2.NavMenu` exposing list:

```
per-element surface counts: {'NavMenu': 13, 'NavMenuItem': 36, 'NavMenuItemGroup': 16}
union (member-prefixed) expected count: 65
composed Build2.NavMenu exposed count: 65

MISSING from composed (per-element surface NOT covered): NONE — composed is a superset-or-equal
EXTRA in composed (beyond the per-element union): NONE
```

**The composed builder is EXACTLY the member-prefixed union of the three
per-element builders — 65 = 13 + 36 + 16, zero missing, zero extra.** Shape A's
"the composed builder is a superset-or-equal of the per-element builders" holds
with no gap. The Shape A assumption in the dispatch is CONFIRMED, not falsified.

### 2.3 — imports Component, not Element

`grep '^import' src/M3e/Build2/NavMenu.elm`:

```
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Action as Ac
import M3e.Attributes as A
import M3e.Component.NavMenu as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values
```

- `import M3e.Element.*` count → **0**.
- `import M3e.Component.NavMenu as Component` → present (line 21). All
  element-tier access (types AND slot placers, e.g. `Component.ItemBadgeSlot`,
  `Component.itemBadge`) resolves through the family façade.

### 2.1 / 2.4 — the composed builder + a consumer type-check

`M3e.Build2.NavMenu` and its whole dependency tree compile. A hand-written
consumer importing ONLY `M3e.Build2.NavMenu` (no `M3e.Element.*`, no
`M3e.Build.*`) type-checks (`elm make → exit 0`). It exercises:

- the root `navMenuBuild |> navMenuWithChild (...) |> navMenuWithClass |>
  navMenuWithId |> navMenuToElement` chain (root builder + attr pipes +
  cross-member child composition), and
- a member `itemGroupBuild |> itemGroupWithClass |> itemGroupToElement` chain,

with every type (`NavMenuIs`, `ItemGroupIs`, `NavMenuBuilder`, …) sourced from
the `M3e.Component.NavMenu` façade. The composed `itemBuild` correctly carries
its required-`label`-slot record ctor seeded via the façade slot placer
(`B.init "m3e-nav-menu-item" [] [ El.toNode (Component.itemLabel required_.label) ]`),
proving the composition path preserves the per-element builder's type-level
slot constraints.

## Verdict

The composition path produces a builder **provably at least as capable as**
(here, exactly equal to) the per-element path, sourced through Components with
zero Element imports. Shape A is de-risked on a real, multi-member family. The
CRUX GATE (Task 3, whole-brand + drift) and materialize (Task 4) can proceed
once Jack resolves OQ-1/OQ-3/OQ-4 and this PoC is reviewed.
