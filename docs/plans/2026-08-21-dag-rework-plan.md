# DAG rework execution plan — linear `IR → Core → Elements → Components → Builders`

**Status:** planning only. No code, config, or generated output was changed to produce this
document. Every file:line citation below was re-derived from the current `main`-descended tree
(base `8094b504`, the post-reconciliation tip) — NOT copied from the stale
`2026-08-20-package-explosion-gauntlet-tracker.md` (which does not exist anywhere in this tree; see
Friction note at the end) and NOT from the pre-rename tracker names. All names here are the NEW
post-reconciliation names: `M3e.Element.*` (per-element surface, was `M3e.Component.*`),
`M3e.Component.*` (family/composition tier, was `M3e.Family.*`), packages
`elm-m3e-{core,elements,build,components,icons,facts}`.

**Redirect being executed (Jack, 2026-08-20):** "the tier DAG is wrong and is the priority." Target
DAG is linear, types tightening downward:

```
IR → Core → Elements → Components → Builders
```

with the sourcing rule:

- **Core + Elements** derive from the **CEM alone** (manifest → shared vocab + per-element surfaces).
- **Components + Builders** derive from the **composition config** (`_families` + slot composition),
  NOT the CEM.
- **Elements ≈ Components** in type-strength — that split is *co-location* (ergonomics), not a tier
  jump. **Builders** is the genuinely-tightest tier, sitting **below** Components.

---

## The crux, in one line

Today **Builders and Components are parallel siblings hanging off Elements**; the rework must make
**Builders chain through Components**, and must **re-source both Components and Builders from the
composition config** instead of emitting Builders per-CEM-element. This is a *generator + package-DAG*
change to an already-shipped, gate-green 6-package split — so the whole risk is doing it without a
second blast-radius incident like the namespace rename that just landed.

---

## Read before Task 0 — verified current state (the problem, precisely)

Every claim here was checked against the live tree at base `8094b504`.

### P1 — Builders consume Elements, not Components (source + artifact)

`compBuildModule` (the per-element builder emitter) hard-imports the **Elements** tier:

- `pipeline/elm-cem/codegen/Generate/Phantom/Emit/Component.elm:1691`
  ```elm
  , [ "import " ++ lib ++ ".Element." ++ comp.name ++ " as Component" ]
  ```
  and its internal references all go through `internalRef n = "Component." ++ n`
  (`Component.elm:1306-1307`) — i.e. the alias `Component` points at `<Lib>.Element.<X>`.

- Materialized artifact confirms it: `brands/m3e/generated/package/elm-m3e-build/src/M3e/Build/Accordion.elm:21`
  → `import M3e.Element.Accordion as Component`. There is **no** `import M3e.Component.*` in any Build
  module (grep of `elm-m3e-build/src/` for `import M3e.Component` returns zero).

### P2 — Components (family) also consume Elements, and do NOT consume Builders

- `brands/m3e/generated/package/elm-m3e-components/src/M3e/Component/Accordion.elm:23-24`
  → `import M3e.Element.Accordion as Accordion_` / `import M3e.Element.ExpansionPanel as Panel_`.
- Grep of `elm-m3e-components/src/` for `import M3e.Build` returns **zero** — the family tier never
  touches Builders.

So both `build` and `components` chain off `elements`; **neither chains through the other.** They are
parallel siblings.

### P3 — The parallelism is baked into the package DAG, not just the imports

`brands/m3e/generated/package/elm-m3e/packages.json` + the two family/build `elm.json`s declare:

| package               | producer                     | deps (family pkgs only)        |
|-----------------------|------------------------------|--------------------------------|
| `elm-m3e-core`        | `split.js` bucket            | (IR only)                      |
| `elm-m3e-elements`    | `split.js` bucket            | `core`                         |
| `elm-m3e-build`       | `split.js` bucket            | `core`, **`elements`**         |
| `elm-m3e-components`  | `FamilyPackage.elm` emitter  | `core`, **`elements`**         |

`elm-m3e-build` and `elm-m3e-components` both depend on `{core, elements}` and **neither depends on the
other** (verified: both `elm.json` dependency blocks are byte-identical modulo package name). Target
wants `build → components → elements → core`.

### P4 — Builders are CEM-emitted (per-element), Components are config-emitted (per-family)

- `pipeline/elm-cem/codegen/Generate/Phantom/Emit.elm:130`:
  ```elm
  ++ List.concatMap (\comp -> [ internalTypesModule brand comp, compModule brand comp, compBuildModule brand comp ]) own
  ```
  `compBuildModule` is emitted **once per CEM element** (`own`), interleaved with the element surface.
  There is exactly one `M3e.Build.<X>` per `M3e.Element.<X>` (130 = 130, verified by count).
- `Emit.elm:140`: `Generate.Phantom.Emit.FamilyPackage.files brand families` — Components are emitted
  from the `families` config (21 modules from 21 `_families` entries), a wholly separate pass.

So the **sourcing rule is already half-right**: Components already derive from the composition config
(`_families`). The rework's real work is on the **Builders** half: today Builders are CEM-per-element;
target wants Builders re-derived through the composition tier and consuming Components.

### P5 — What Components actually re-export today (constrains "Builders consume Components")

`M3e/Component/Accordion.elm:1` exposes member-prefixed re-exports of the *element surface*:
`AccordionBuilder`, `PanelBuilder` (the `Builder` **type alias**, re-aliased), the `component` ctor
(`accordion`, `panel`), attr pipes (`panelOpen`, …) and slot placers (`panelHeader`, …). It re-exports
the **type-level** `Builder` alias but NOT the builder-module **seeds** (`build`, `toElement`) — those
live only in `M3e.Build.*`. This is why "Elements ≈ Components, co-location not a tier jump" is literally
true: Components is a member-prefixed façade over Elements with no extra type-strength. **This is the
load-bearing constraint on the target** — see OQ-1: for Builders to *consume* Components, either
Components must start carrying the composed builder surface, or Builders re-derive per-family from the
same composition config Components use.

---

## Target architecture

### T1 — The intended DAG (packages)

```
elm-html-intermediate-representation (IR)
   └─▶ elm-m3e-core        (CEM: barrel, shared vocab, Forge, Kind, Attributes, Values, Action)
          └─▶ elm-m3e-elements   (CEM: per-element M3e.Element.<X> surface)
                 └─▶ elm-m3e-components   (composition config: M3e.Component.<Family> façades)
                        └─▶ elm-m3e-build (composition config: composed builders)
```

`icons` and `facts` stay off to the side (leaf tiers, unaffected).

### T2 — How Builders should be re-derived (the core design change)

Two coherent shapes; the plan below is written against **Shape A** (recommended), with Shape B recorded
as the fallback if OQ-1 resolves the other way.

**Shape A — Builders become a family-composition emitter that consumes Components.**
Move builder emission out of the per-element `List.concatMap` (`Emit.elm:130`) into a new
config-driven pass parallel to `FamilyPackage.files`, e.g.
`Generate.Phantom.Emit.BuildPackage.files brand families`. For each `_families` entry it emits one
`M3e.Build.<Family>` module whose builder seeds/pipes/slot-placers are keyed to the **family root +
members**, importing `M3e.Component.<Family>` (the façade) rather than each `M3e.Element.<X>`. The
per-element builder mechanics (`build`, `toElement`, slot placers) still come from the shared
`componentCore` data on `Comp`, but they are *assembled per family* and reference the Component façade's
re-exported types. Elements that are **not** members of any family still need a builder — those get a
**degenerate single-member family** (root = the element, no extra members) so every element retains a
`build`, exactly as today, but sourced through the composition path uniformly. This keeps the "Builders
derive from composition config" rule literally true while preserving today's per-element ergonomics for
standalone elements.

Concretely:
- **New emitter** `Generate/Phantom/Emit/BuildPackage.elm` (sibling of `FamilyPackage.elm`), consuming
  `FamiliesConfig` + `Component.compSurface` the same way `FamilyPackage` does, so it can never drift
  from the element surface (same anti-drift property the family emitter already has — see
  `FamilyPackage.elm:8-18`).
- **Delete** `compBuildModule` from the per-element `concatMap` at `Emit.elm:130`; its body migrates
  (largely verbatim) into `BuildPackage.elm`, with the one import line changed from
  `import <Lib>.Element.<X> as Component` (`Component.elm:1691`) to
  `import <Lib>.Component.<Family> as Component`.
- **`slots.json` `_families`** gains an implicit "all standalone elements are degenerate families"
  expansion (computed in the emitter from `brand.comps` minus family members — NOT authored by hand),
  so the config surface for brand authors is unchanged (see OQ-2).

**Shape B — Builders stay per-element but re-point their import to Components.**
Minimal change: keep `compBuildModule` per-element, but change `Component.elm:1691` so a builder for an
element that IS a family member imports `M3e.Component.<Family>` instead of `M3e.Element.<X>`, and
standalone elements keep importing Elements. This satisfies "Builders consume Components" for family
members only and is a much smaller diff, but it does **not** satisfy "Builders derive from composition
config" (they're still CEM-per-element) and leaves a split-brain (some builders import Components, some
import Elements). Recorded as the fallback; the plan proceeds on Shape A.

### T3 — Package/config changes required (Shape A)

- **`packages.json`** (`brands/m3e/generated/package/elm-m3e/packages.json`): `elm-m3e-build` moves from
  a `split.js` bucket to a **`FamilyPackage`-style generated package** (like `elm-m3e-components` today),
  because its modules will no longer land in the flat `src/` the splitter slices. Its `deps` block gains
  `jackhp95/elm-m3e-components` and drops nothing (it keeps `core`, `elements` transitively via
  Components). **Do not hand-edit the deps** — `family-deps.js` re-derives them from the emitted imports
  (`bin/family-deps.js:1-25`), so correcting the imports auto-corrects the declared deps, and its
  `auditPackage` gate fails loud if a package imports a namespace it doesn't declare. This is the
  rework's single most important safety net.
- **`split.js`** (`pipeline/elm-cem/bin/split.js`): remove the `M3e.Build` / `M3e.Build.*` buckets from
  the splitter's config (they no longer exist in the flat `src/`). `check-m3e-5pkg.mjs`'s assertion
  ("`elm-m3e-build` owns the `M3e.Build` buckets") must be rewritten to assert Build is now a
  family-generated package with a `components` dep, not a bucket owner.
- **`slots.json`** (`brands/m3e/inputs/cem/config/slots.json`): no new authored keys under Shape A. If
  OQ-3 resolves toward explicit builder-family opt-in, a `_builders` block mirroring `_families` shape
  would be added — recorded as OQ-3, not assumed.
- **`FamilyPackage.elm`**: unchanged in mechanism, but its README/`elm.json` dep emission is the template
  `BuildPackage.elm` copies (family package config → `elm.json` deps + README + LICENSE, `FamilyPackage.elm:663-761`).

### T4 — What "types tighten downward" buys at each tier (design intent, for reviewers)

- **Core**: brand-wide vocab; loosest (row-polymorphic capability phantoms, open `Kind`).
- **Elements**: per-element `Is`/`Attrs`/`Builder` narrow the phantom to one element's markers.
- **Components**: family façade — same strength as Elements, but *names* are member-scoped
  (co-location), and the family root's `AdmittedBy` can constrain which members compose.
- **Builders**: tightest — the pipe-builder's `accepts` phantom is pinned to the family's admitted set;
  a Builder can only accept children the composition config says are legal. This is where the composition
  config's slot rules become *type-enforced* rather than merely re-exported.

---

## Migration path — how to re-derive without a blast-radius incident

The precedent is the reconciliation plan's own sequencing: **change the generator + config first, prove
the emitted output on a green tree, then materialize**, gated by the repo's existing drift/registry
checks. Same shape here.

### M1 — Proof-of-concept on ONE family first (de-risk the emitter)

Pick a **single, representative family with real member composition** — `NavMenu`
(`_families.families.NavMenu = { root: NavMenu, members: [NavMenuItem/Item, NavMenuItemGroup/ItemGroup] }`,
verified in `slots.json`) — and stand up `BuildPackage.elm` to emit **only** that family's
`M3e.Build.NavMenu`, alongside the existing per-element builders (dual-emit). Diff the composed builder
against the concatenation of today's `M3e.Build.NavMenu*` per-element builders to prove the composition
path produces a *superset-or-equal* surface. Only once the PoC compiles and its guard passes do we flip
the whole brand. This is the "prove one leaf before the atomic remap" discipline the namespace rename
lacked at first.

### M2 — Full regen-and-diff verification (the gate wall)

The rework is a generator change, so it inherits the whole verification stack the repo already uses for
generator changes:

- **`ab-elm-cem.sh` / `check-drift.mjs`** (`tools/check-drift.mjs:1-25`): pristine-vs-workspace elm-cem,
  same config, zero-diff requirement. This is the Face-A drift proof; a builder-emitter change must
  regenerate byte-identically on re-run.
- **`family-deps.js` `auditPackage`** (`bin/family-deps.js:20-25`): fails if any emitted package imports
  a namespace its `elm.json` omits — the direct guard that Builders' new `M3e.Component.*` import forces
  a declared `elm-m3e-components` dep.
- **`check-m3e-5pkg.mjs`** (`tools/check-m3e-5pkg.mjs`): rewritten (Task 4) to assert the new
  Build-as-family-package shape; it is the discriminating verify-check for the split gate.
- **Face-A generator bundle re-baseline** (`tools/snapshots/elm-cem-generator.bundle`) + phantom
  re-bless: per memory `generator-change-d046-rebaseline`, any shared-emitter change needs a bundle
  re-baseline + all-brand regen + phantom re-bless. This is NOT in `gate-all` and must be an explicit
  task (Task 8), run **after** the emitter is final.
- **`gate:all`** (`tools/gate-all.mjs`, `package.json` script `gate:all`): the full serial wall, run at
  the start (baseline) and end (final).

### M3 — Staged rollout order (mirrors reconciliation D-R4)

1. Emitter + config change, **generated side only**, brand still compiles because dual-emit keeps the old
   Build modules until the cutover (Tasks 1–3).
2. Prove PoC on one family (Task 2), then whole-brand regen + drift (Task 3 = CRUX GATE).
3. Materialize: flip `packages.json`, `split.js`, `check-m3e-5pkg.mjs`, remove old per-element Build
   modules, wire deps (Task 4), on a **green tree**.
4. Bundle re-baseline + phantom re-bless (Task 8) last, capturing final emitter output.

---

## Blast radius (which packages/brands are affected)

Verified against the live tree:

| brand      | split state              | Build tier? | families? | affected by rework                                  |
|------------|--------------------------|-------------|-----------|-----------------------------------------------------|
| **m3e**    | 6 siblings (gate-green)  | yes (130)   | yes (21)  | **fully** — the whole rework targets m3e            |
| **shoelace** | monolith `elm-shoelace` | yes (58)  | **no**    | emitter change flows in automatically; **no family tier**, so every builder becomes a degenerate single-member family (Shape A). No `packages.json` split to touch (still monolith). |
| **svg**    | monolith `elm-typed-svg` | **no**      | no        | **exempt** — no Build tier (home-only-ish); nothing to re-derive |
| **html**   | 3 siblings (home-only)   | **no**      | no        | **exempt now**; this rework is the *precondition* that unblocks html's 5-tier future target (reconciliation §2.4 / OQ-5). html gains Builders only in a **follow-up**, not here. |

**Key blast-radius facts:**
- Only **m3e** has both a Build tier AND a family tier, so it is the only brand where the full
  Components-between-Elements-and-Builders chain is exercised now. **The PoC and the whole plan are
  scoped to m3e.**
- **shoelace** has a Build tier but no families — under Shape A its builders become degenerate
  single-member families. This is a real behavioral surface for shoelace and MUST be regen-verified
  (Task 7), but it does not require a package split (shoelace is still a monolith).
- **html/svg are exempt** for this pass. html's 5-tier ceiling is *unblocked* by this rework but not
  *delivered* by it (OQ-5 resolution: 5 is the future target, reachable only once this lands). A separate
  follow-up plan lands html Builders; this plan's Task 9 records that hand-off explicitly.
- **Consumer blast radius inside the workspace**: docs (`elm-m3e-docs`), examples, and any Face-A/B
  fixtures that import `M3e.Build.<Element>` will break if Shape A renames Build modules from per-element
  (`M3e.Build.Button`) to per-family (`M3e.Build.<Family>`). **This is the single largest hand-authored
  blast surface** and is why OQ-4 (keep per-element Build module names as thin re-exports?) matters.

---

## Open questions (for Jack — do not guess)

- **OQ-1 — Does "Builders consume Components" require Components to carry the composed builder surface, or
  do Builders re-derive per-family from the same composition config?** Today Components re-export only the
  *type-level* `Builder` alias + element surface, NOT the builder seeds (`build`/`toElement`) — verified
  at `M3e/Component/Accordion.elm:1`. Shape A (recommended) re-derives Builders from config and imports
  the Component façade for *types*, which works with today's Component surface. But if the intent is that
  Builders should import Components for *values* (the composed builder pipes), Components must grow a
  builder surface first — a bigger change. **Recommended: Shape A. Needs Jack's confirmation the type-only
  Component import satisfies "consume Components".**

- **OQ-2 — Degenerate single-member families for standalone elements: emitter-computed or config-authored?**
  Recommended emitter-computed (brand author's `slots.json` surface unchanged). Confirm Jack does not want
  an explicit `_builders` config block. If he does, that changes `slots.json`'s shape (a *new* authored
  key) and is a config-surface addition worth its own note.

- **OQ-3 — Is the `_families`/family.json config surface a breaking change for external consumers of the
  already-published mirror packages?** The standalone `jackhp95/elm-m3e-*` mirrors are read-only republish
  targets and already known-lagging (reconciliation OQ-3). If Shape A renames `M3e.Build.<Element>` →
  `M3e.Build.<Family>`, that is a **breaking API change** for anyone importing `M3e.Build.Button` from a
  published `elm-m3e-build`. **Needs Jack's call on whether the mirror republish absorbs this as a major
  version bump, or whether OQ-4's re-export shim preserves the old names.**

- **OQ-4 — Preserve per-element `M3e.Build.<Element>` module names as thin re-exports from the composed
  `M3e.Build.<Family>` modules?** This would zero out the consumer blast radius (docs/examples keep
  importing `M3e.Build.Button`) at the cost of ~130 extra generated re-export modules. Recommended **yes**
  for the migration window, deprecate later. Needs Jack's call — it trades generated-file count for
  consumer stability.

- **OQ-5 — html/svg Builders: this plan's scope or a follow-up?** Recommended **follow-up** (this plan
  exempts them; §Blast radius). Confirm Jack wants html's 5-tier delivery split into its own plan rather
  than folded in here.

---

## Gauntlet-shaped task breakdown

House style matches `docs/plans/2026-08-20-reconciliation-plan.md`: numbered Tasks, `- [ ]` Steps with
concrete acceptance/verify per step, an identity guard, a green-tree milestone, and a dependency graph.
D-R* decisions are carried at the top.

### Decisions carried into this plan

- **D-DAG1 — Shape A (config-derived Builders consuming Components) is the target.** Shape B is the
  fallback only if OQ-1 flips.
- **D-DAG2 — Scope is m3e for the rework; shoelace regen-verified as a rider; html/svg exempt (follow-up).**
- **D-DAG3 — Generated side changes first, materialize on a green tree, bundle re-baseline last** (mirrors
  reconciliation D-R4).
- **D-DAG4 — Never hand-edit inter-package deps; `family-deps.js` derives them from imports.**
- **D-DAG5 — Identity guard before every commit:** `git config user.name`/`user.email` must be
  `JackHP95`/`git@jackhpeterson.com`.
- **D-DAG6 — Blocked on OQ-1..OQ-5.** Tasks 1–2 (emitter PoC) can start under the Shape A assumption;
  **Task 4 (materialize) MUST NOT start until OQ-1, OQ-3, OQ-4 are resolved** (they determine module
  naming + the mirror-break decision).

---

### Task 0: Baseline — clean serial gate + identity guard

- [ ] **Step 0.1** From repo root, run `npm run gate:all` (`tools/gate-all.mjs`) on the base and capture
      the green baseline. Acceptance: exit 0, output saved for the final diff.
- [ ] **Step 0.2** `git status --short` empty before starting.
- [ ] **Step 0.3 — IDENTITY GUARD (D-DAG5).** `git config user.name && git config user.email` →
      `JackHP95` / `git@jackhpeterson.com`. Abort if not.
- [ ] **Step 0.4** Record the base SHA and the current tier-DAG facts (P1–P5 above) as the "before"
      snapshot the final task diffs against.

**Blocks:** everything.

---

### Task 1: Stand up `BuildPackage.elm` (dual-emit, PoC scaffolding) — *gated on OQ-1*

- [ ] **Step 1.1** Create `pipeline/elm-cem/codegen/Generate/Phantom/Emit/BuildPackage.elm` as a sibling
      of `FamilyPackage.elm`, taking `Brand -> Maybe FamiliesConfig -> Result (List String) (List Elm.File)`,
      consuming `Component.compSurface` for the anti-drift guarantee (`FamilyPackage.elm:8-18`).
- [ ] **Step 1.2** Migrate the body of `compBuildModule` (`Component.elm:1164-1813`) into
      `BuildPackage.elm`, changing the one import line `Component.elm:1691` from
      `import <Lib>.Element.<X> as Component` to `import <Lib>.Component.<Family> as Component`, and
      keying builder seeds to family root + members.
- [ ] **Step 1.3** Implement degenerate-single-member-family expansion (D-DAG2): every `brand.comps`
      element not in a `_families` member list emits as a one-member family so no element loses its
      builder. Emitter-computed, no config change (OQ-2).
- [ ] **Step 1.4 — DUAL-EMIT.** Wire `BuildPackage.files` into `Emit.elm` **alongside** the existing
      per-element `compBuildModule` (do NOT remove `Emit.elm:130`'s `compBuildModule` yet), emitting the
      new family-builders under a temporary namespace (e.g. `M3e.Build2.<Family>`) so the brand still
      compiles and both surfaces exist for diffing.

**Acceptance:** `elm-cem` compiles; a whole-brand regen produces both old `M3e.Build.<X>` and new
`M3e.Build2.<Family>` trees. **Verify:** `elm make` on the codegen; regen emits without guard errors.
**Blocks:** Task 2. **Blocked by:** OQ-1 (confirm type-only Component import satisfies "consume").

---

### Task 2: PROOF-OF-CONCEPT on one family (`NavMenu`)

- [ ] **Step 2.1** Regenerate m3e with dual-emit; extract `M3e.Build2.NavMenu`.
- [ ] **Step 2.2** Prove surface-equivalence: the composed `M3e.Build2.NavMenu` exposes a
      superset-or-equal of the union of today's `M3e.Build.{NavMenu,NavMenuItem,NavMenuItemGroup}`
      builder surfaces (seeds, slot placers, attr pipes). Record the exact exposing-list diff.
- [ ] **Step 2.3** Prove the new module imports `M3e.Component.NavMenu` and NOT any `M3e.Element.*`
      (grep the generated `M3e/Build2/NavMenu.elm` imports).
- [ ] **Step 2.4** A tiny hand-written consumer using `M3e.Build2.NavMenu` type-checks against the
      dual-emitted tree (proves the Component-façade types are sufficient for the builder).

**Acceptance:** all four steps pass; the composition path demonstrably produces a builder at least as
capable as the per-element path, sourced through Components. **Verify:** `elm make` on the consumer;
exposing-list diff recorded. **Blocks:** Task 3. **This is the "prove one leaf before the atomic remap"
gate the namespace rename lacked.**

---

### Task 3: CRUX GATE — whole-brand cutover in the generator (still dual-namespace)

- [ ] **Step 3.1** Extend the PoC to all 21 families + all degenerate families (every element covered).
- [ ] **Step 3.2** Regenerate m3e; assert every `M3e.Element.<X>` has a corresponding builder reachable
      through the composition tree (no element lost a builder).
- [ ] **Step 3.3** Run `check-drift.mjs` / `ab-elm-cem.sh` (`tools/check-drift.mjs:1-25`) — the emitter
      must regenerate byte-identically on re-run (determinism).
- [ ] **Step 3.4** Record the full before/after builder-tree diff (per-element `M3e.Build.*` vs composed
      `M3e.Build2.*`) as the materialization contract.
- [ ] **Step 3.5** Commit the emitter + dual-emit wiring (generated output NOT yet promoted to the real
      `M3e.Build` namespace). Identity guard first.

**Acceptance:** whole-brand dual-emit deterministic + surface-complete. **Verify:** drift gate green;
coverage assertion passes. **Blocks:** Task 4.

---

### Task 4: MATERIALIZE — flip namespace, packages.json, split.js, gates *(gated on OQ-1/3/4)*

Runs on the green tree only (D-DAG3).

- [ ] **Step 4.1** Cut `M3e.Build2.<Family>` → `M3e.Build.<Family>` (retire the temp namespace); remove
      `compBuildModule` from the per-element `concatMap` at `Emit.elm:130`.
- [ ] **Step 4.2 (OQ-4)** If Jack chose re-export shims: emit thin `M3e.Build.<Element>` modules
      re-exporting from `M3e.Build.<Family>` so consumers keep working. Else: accept the breaking rename
      and proceed to consumer migration (Step 4.6).
- [ ] **Step 4.3** `packages.json`: move `elm-m3e-build` from a `split.js` bucket to a family-generated
      package (template = `elm-m3e-components`). Do NOT hand-edit deps (D-DAG4).
- [ ] **Step 4.4** `split.js`: remove the `M3e.Build` / `M3e.Build.*` buckets.
- [ ] **Step 4.5** Rewrite `tools/check-m3e-5pkg.mjs` to assert Build is a family-generated package with a
      declared `elm-m3e-components` dep (not a bucket owner).
- [ ] **Step 4.6** Run `family-deps.js`; confirm `elm-m3e-build/elm.json` now declares
      `jackhp95/elm-m3e-components` (auto-derived from the new imports) and `auditPackage` is clean.
- [ ] **Step 4.7 (consumer migration)** Atomically remap workspace consumers of `M3e.Build.<Element>`
      (docs, examples, fixtures) — unless Step 4.2 shim makes this a no-op. Follow the reconciliation
      plan's atomic-remap discipline (one commit, verified compile).
- [ ] **Step 4.8** Commit. Identity guard first.

**Acceptance:** m3e compiles with `build → components → elements → core`; `check-m3e-5pkg` + `auditPackage`
green. **Verify:** `elm make` per package; dep-audit clean. **Blocks:** Task 5. **Blocked by:** OQ-1, OQ-3,
OQ-4 (D-DAG6).

---

### Task 5: Package-DAG assertion gate

- [ ] **Step 5.1** Add/extend a gate that asserts the *linear* DAG: `elm-m3e-build`'s `elm.json` deps
      include `elm-m3e-components`, and `elm-m3e-components` does NOT depend on `elm-m3e-build` (no cycle),
      and no `M3e.Build.*` module imports `M3e.Element.*` directly (all element access goes through the
      Component façade).
- [ ] **Step 5.2** Wire it into `gate-all.mjs` so the parallel-siblings shape can never silently return.

**Acceptance:** the gate fails on the OLD shape and passes on the NEW shape (prove both directions).
**Verify:** run against a stashed old artifact (red) and current (green). **Blocks:** Task 6.

---

### Task 6: `gate:all` green on the reconciled DAG (milestone)

- [ ] **Step 6.1** Full `npm run gate:all`. Acceptance: exit 0.
- [ ] **Step 6.2** Diff against the Task 0.1 baseline; every delta explained by the DAG rework (builder
      module renames + dep additions), nothing spurious.

> **MILESTONE — green tree, linear DAG.** After Task 6, m3e ships `IR → Core → Elements → Components →
> Builders`. Tasks 7–9 are the riders.

**Blocks:** Tasks 7, 8.

---

### Task 7: shoelace regen-verification (rider — D-DAG2)

- [ ] **Step 7.1** Regenerate shoelace; confirm its 58 builders emit as degenerate single-member families
      (no `_families` config) and still compile.
- [ ] **Step 7.2** Confirm shoelace stays a monolith (no `packages.json` split touched) and no
      `Sl.Build.*` imports `Sl.Element.*` directly post-rework.
- [ ] **Step 7.3** `gate:all` covering shoelace green.

**Acceptance:** shoelace regen byte-stable + compiles. **Verify:** drift gate + `elm make`. **Blocks:**
Task 8.

---

### Task 8: Face-A bundle re-baseline + phantom re-bless (LAST generator step)

Per memory `generator-change-d046-rebaseline`: shared-emitter changes need a bundle re-baseline + all-brand
regen + phantom re-bless, NOT in `gate-all`.

- [x] **Step 8.1** Re-baseline `tools/snapshots/elm-cem-generator.bundle` from the final emitter.
- [x] **Step 8.2** All-brand regen (m3e, shoelace, html, svg) — confirm html/svg unchanged (exempt).
- [x] **Step 8.3** Phantom re-bless where the builder surface moved.
- [x] **Step 8.4** Commit. Identity guard first.

**Acceptance:** bundle + phantom expectations match final emitter. **Verify:** re-run emits zero diff.
**Blocks:** Task 10.

---

### Task 9: html 5-tier follow-up hand-off (record only — OQ-5)

- [x] **Step 9.1** Write a one-paragraph hand-off note (in this plan's follow-ups section or a new stub
      plan) recording that html's 5-tier target (reconciliation §2.4 / OQ-5) is now *unblocked* by the
      landed DAG and needs its own plan (html has no families/Build today; standing up its Components +
      Builders tiers is a separate design). **Done 2026-08-21 — see § Follow-ups / FU-1 below.**

**Acceptance:** hand-off recorded. **No code.**

---

### Task 10: Final gate + verification

- [x] **Step 10.1** Full `npm run gate:all` green.
- [x] **Step 10.2** Re-assert P1–P5 are now FALSE (the parallel-siblings problem is gone): Build imports
      Components, Components between Elements and Builders, package DAG linear.
- [x] **Step 10.3** Identity guard, final commit.

**Acceptance:** DAG rework complete and gate-green; the Task 5 DAG gate + Task 0 baseline diff prove it.

---

## Dependency graph (sequencing / parallelism)

```
Task 0 ─▶ Task 1 ─▶ Task 2 (PoC) ─▶ Task 3 (CRUX) ─▶ Task 4 (materialize) ─▶ Task 5 (DAG gate)
                                                                                   │
                                                                                   ▼
                                                                              Task 6 [GREEN MILESTONE]
                                                                                   │
                                                            ┌──────────────────────┼───────────────┐
                                                            ▼                      ▼               ▼
                                                     Task 7 (shoelace)     Task 8 (bundle)   Task 9 (html hand-off, doc-only)
                                                            └──────────┬───────────┘
                                                                       ▼
                                                                 Task 10 (final gate)
```

- **Gating:** Tasks 1 & 4 are blocked on OQ-resolutions (D-DAG6). Tasks 7 and 9 can run in parallel with
  Task 8 after the milestone. Task 9 is doc-only (no worktree needed).

---

## Friction note

`docs/plans/2026-08-20-package-explosion-gauntlet-tracker.md` — cited in this task's brief as "still in
the tree" and "the ONLY place the redirect was recorded" — **does not exist** anywhere in this worktree
(base `8094b504`), in git history on any branch, or in the main workspace checkout. Nor do
`2026-08-20-package-explosion-plan.md` / `-design.md` (the reconciliation design records them as living
on ancestor branch `spec/explosion-research`, which is also absent from this worktree). The brief's
verbatim quote of Jack's redirect and its re-statement of the current-vs-target gap were sufficient, and
the brief separately instructed re-derivation from live source — which is what this plan is built on. The
missing tracker is logged as a friction; nothing in this plan depends on it.

---

## Follow-ups

### FU-1 — html 5-tier target is now UNBLOCKED, needs its own plan (Task 9 hand-off — OQ-5)

**Recorded 2026-08-21, DAG-rework Task 9 (doc-only, no code).**

With this plan landed, the linear `IR → Core → Elements → Components → Builders` DAG is materialized
and gate-enforced for **m3e**, and the composition-driven builder emitter
(`codegen/Generate/Phantom/Emit/BuildPackage.elm`) is now a general, brand-agnostic capability rather
than an m3e special case — shoelace already rides it (its 59 builders emit as degenerate single-member
families through the same emitter). **This was the precondition the reconciliation plan called out**
(reconciliation §2.4 / §11-OQ5, and its own note at lines ~216-221: html's 3-tier split
`elm-typed-html-{core,elements,facts}` is a *ceiling for that pass only*, not permanent, "because html
is a home-only brand and no Build/components tier existed to split — deferred to that rework").

**html's target is 5 tiers** (`core → elements → components → build`, + `facts` off to the side), the
same shape m3e now ships. Today html has **no Build tier and no families/composition config** at all —
verified: `brands/html/generated/package/` holds only `elm-typed-html{,-core,-elements,-facts}`, there
is no `TypedHtml.Build.*` tree, and html's CEM config carries no `_families`. So html is **not** merely
a regen away from 5 tiers; standing up its Components + Builders tiers is a genuine design task:

- **What the landed DAG gives html for free:** the emitter path exists. If html gains a `_families`
  composition config (or relies purely on the degenerate single-member-family expansion that
  `BuildPackage.elm` already computes from `brand.comps`), the same emitter that produces m3e's and
  shoelace's builders will produce `TypedHtml.Build.*` with no new generator code.
- **What still needs designing (the follow-up plan's real scope):**
  1. **Does html even want a family/composition tier?** html elements are the raw HTML element set;
     whether there are meaningful *families* (composite widgets) to author, or whether html stays
     degenerate-single-member-only (a Build tier that is a thin composed façade over Elements, like
     shoelace's), is a product decision — not settled here.
  2. **The `packages.json` split.** html would move from a 3-package split to a 4-or-5-package split
     (`+elm-typed-html-components`, `+elm-typed-html-build`), following the m3e materialization recipe
     (Task 4 here): Build + Components become `FamilyPackage`/`BuildPackage`-generated packages (not
     `split.js` buckets), with deps auto-derived by `family-deps.js` and the DAG asserted by the Task-5
     `check-package-dag.mjs` gate (which is already brand-agnostic and would cover html the moment it
     grows a Build tier).
  3. **Consumer blast radius.** Whatever html consumers (docs/examples) import today; a new Build tier
     is additive, so this is smaller than m3e's rename was — but still its own migration step.
  4. **The published mirror** (`jackhp95/elm-typed-html*`) gains new packages — a publish/versioning
     decision mirroring m3e's.

**Action:** this is deliberately **not folded into this plan** (OQ-5 resolution: 5 is the future
target, delivered separately). A dedicated plan doc — suggested `docs/plans/YYYY-MM-DD-html-5-tier-plan.md`
— should own the html Components/Builders standup, reusing this plan's Task-4 materialization recipe and
the reconciliation plan's atomic-remap discipline. **svg is separately exempt** (home-only, no Build
tier and no near-term 5-tier target — see Blast-radius table; svg is not part of this follow-up).
