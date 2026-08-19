# Brand Facts — a single canonical, comprehensive facts interface

**Status:** Design (approved to draft; awaiting spec review before planning)
**Date:** 2026-08-19
**Owner:** elm-cem (the fold engine) + every facts consumer
**Supersedes framing of:** `Face A / Face B / Face C` (the "faces" vocabulary)
**Related:** `core/elm-review-cem/docs/decisions.md` ADR-15; `core/cem-figma-connect/plans/2026-08-19-example-tree-slot-validation.md`; `core/elm-cem/specs/2026-08-19-facts-bundle-slot-admission-data.md` (halted predecessor)

---

## 1. Problem

Everything downstream of elm-cem needs *facts* about the component library — what
components exist, what attributes and enum values they take, what their slots
accept, which CSS custom properties they expose, and how to reference the
generated Elm API. Today those facts are scattered across **lossy, hand-projected
artifacts**, and consumers that need a fact not in their artifact **reach around
the pipeline into raw inputs** or **hand-duplicate the fact in prose**.

Concrete evidence (grounded, this repo):

- The slot composition-admission contract (`admits: {kinds, multi, required}`)
  lives in `brands/m3e/inputs/cem/config/slots.json` and is needed by **at least
  three** consumers, available to **none** of them via a bundle:
  - `core/cem-figma-connect/src/emit/example-content.mjs` — example-tree
    validation is **blocked** on it (`.../plans/2026-08-19-example-tree-slot-validation.md`).
  - `brands/m3e/outputs/elm-m3e/docs/scripts/examples-gen/lib/oracle.mjs:32-36,274-408`
    — reads raw CEM **and** `config/slots.json` **directly**, an
    "acknowledged deliberate exception" (`oracle.mjs:5-21`).
  - `brands/m3e/outputs/m3e-api-okf/scripts/extract.mjs:228-232` — reads a
    **hand-authored** `host-contract-overlay.json` that re-encodes the same
    `admits` contract in prose, which then flows into the OKF docs **and** the
    generated Claude `m3e` skill (`build-skill.mjs:155-158`).
- `m3e-api-okf` also reaches into a raw TS checkout (`.cache/m3e`) for each
  element's `:host` `display` value because "elm-cem never reads element CSS…
  has no Face B field to read" (`extract.mjs:30,127-129`).

Root cause: **the artifacts are lossy hand-projections of a rich model that has
no comprehensive serialization.** `elm-cem` folds many heterogeneous inputs into
a resolved in-memory model, then emits two narrow JSON views (`cem-facts.json`
built in JS, `elm-api-facts.json` emitted from Elm) plus the Elm library itself.
Each view carries a different ~5% slice; neither is the whole truth. Every new
consumer need = "the fact isn't in the slice" = add another projection or reach
around.

## 2. Reframe: three roles, not "faces"

The `Face A / B / C` vocabulary jammed three *different kinds of thing* under one
word. They are actually three roles in one pipeline:

```
INPUTS (many, heterogeneous, optional except the structural spine)
  web components  →  analyzer  →  CEM ............... structural spine (+ _config._phantom)
  .d.ts types     →  scanner   →  type resolutions .. (enum unions vs String)
  material spec   →  by hand    →  composition/admits  (what slots accept)
  css / figma / examples / categories / icons ...     (optional enrichment)
        │
        ▼   elm-cem = the FOLD  (reconcile · resolve · canonicalize)
   ┌───────────────────────────────────────────────┐
   │              BRAND FACTS                        │  one canonical, comprehensive
   │  = "CEM++" : a superset of the CEM with every   │  model. THE interface every
   │    provided input folded in, + provenance       │  downstream reads.
   └───────────────────────────────────────────────┘
        │
        ▼   generate per TARGET
   the Elm library (the deliverable — was "Face A")
   per-facet Elm bindings (module/setter/token names — was "Face C")
```

1. **Inputs** — heterogeneous, brand-supplied, mostly optional. (CEM, types,
   composition, css, figma, docs…) Each is a script/hand output.
2. **Brand Facts** — the single canonical fold. The authoritative interface.
3. **Targets** — generated *from* Facts: the Elm library, and per-facet
   **bindings** so external tools can reference the emitted API.

### 2.1 We are completing a migration the codebase already started

"Facts" is not a new invention:

- A dedicated package `elm-cem-facts` already defines `Cem.Facts.Fact` / `Facet`.
- A **generated** `M3e.Review.Facts` Elm module already emits `facts : List Fact`
  (with `slotKinds`, `enums`, `requiredSlots`, `facets`).
- Face C already carries a **`facets`** table (`top/Standard`, `build/Build`,
  `record/Record`, `html/Html`) — construction-form projections. These form keys
  are **vestigial**; this design keys bindings by destination *package* (§3.4) and
  retires them.
- **ADR-15** is *"the decision to move the library's composition guarantees off
  the M3e phantom types and onto facts-driven review rules"*
  (`core/elm-review-cem/docs/decisions.md:92-109`). Facts-as-authoritative-
  composition-source is the **stated architectural trajectory**.

This design consolidates these emerging pieces into one comprehensive JSON form
they currently lack. Lower risk than a greenfield subsystem.

## 3. Grounded current state (what the fold really does today)

Established by four parallel investigations; every claim carries a `path:line`.

### 3.1 The two existing bundles are lossy on *different* axes

- **Face B** (`core/elm-cem/bin/facts-bundle.js`, `buildFaceB`) — a raw-CEM
  **structural** superset + `.d.ts`-resolved enum aliases + tag reconciliation.
  Retains what codegen drops: `cssProperties` (with `syntax`), `cssParts`,
  `cssStates`, raw `properties`/members, `superclass`, `deprecated`
  (`facts-bundle.js:360-401`). Slot list comes from the **CEM declaration**
  (`decl.slots`); a slot with no config entry is emitted with `admits: null`.
- **Face C** (`core/elm-cem/codegen/Generate/Phantom/Emit/FactsBundle.elm`,
  `encodeFaceC`) — a projection of the **generated Elm API**: module/setter/token
  identifiers, `facets`, `surfaces`, `slotKinds`, `requiredSlots`, `multiSlots`.
  No CEM-attribute-shaped fields at all.
- The resolved Elm model (`Generate/Phantom/Model.elm` `Comp`/`Brand`) is rich on
  the **resolved** axis (`attrs`, `enums`, `slots : List ResolvedSlot`, `events`,
  `blockedAttrs`, `requiredAttrs`, `ctor`/`resolvedCtor`) but **drops**
  `cssProperties`/`cssParts`/`cssStates`, `superclass`, `deprecated`, raw
  non-attribute members, `dependencies`. Neither B nor the Elm model is a full
  superset.

### 3.2 Slot admission is already duplicated, and the two faces disagree on defaults

- Face B: per-slot `admits: {kinds, multi, required}` (config-sourced), `null`
  when unconfigured.
- Face C: `slotKinds: {slot: [kinds]}` + separate `requiredSlots` / `multiSlots`
  — same config, reshaped for Elm.
- **Codegen** builds `Comp.slots` *only* from config `admits` keys
  (`Model.elm:1993-1996`) and **never consults the CEM's declared slots**. A
  component with no config entry → `Comp.slots = []` (the slot is silently absent
  from the generated API). Only an explicit `kinds: ["any"]` yields open
  (`Permissive`, `Model.elm:1691-1693`).
- So the JSON side (Face B) treats absent-admits as "CEM slot present,
  unspecified"; codegen treats absent-admits as "no slot at all." **A forgotten
  `slots.json` entry silently drops a real slot from the generated library.**

### 3.3 Dead inputs and a stale schema

- `native-mdn.json` (`_native`) and the bundled `native-attrs.json`
  (`_nativeAttrTable`) are injected by the CLI but **never consumed** by the
  phantom pipeline (zero references; a stale `Config.elm:31` comment claims
  otherwise). Only 3 of 9 files in `config/` even reach elm-cem
  (`tools/lib/regen.mjs:25-29`).
- There **is** a versioned schema `docs/facts-bundle/schema.json` (draft-07,
  `schemaVersion: const 1`) guarded by `core/elm-cem/bin/validate-facts-bundle.js`
  in `tools/check-drift.mjs:checkProducer()`. The committed `cem-facts.json` has
  **zero** `admits` (predates the field); adding `admits` fails the schema until
  the schema is updated (`faceBSlot` is `additionalProperties:false`).
- Drift = **regenerate-to-temp + byte-compare**, data-driven by `tools/family.json`
  `bundleCopy` blocks (`tools/lib/check-drift-core.mjs:checkConsumerBundleDrift`).

### 3.4 The generated API splits into a family of published packages — the axis bindings key on

`elm-cem split` partitions the generated `elm-m3e` source into a **facet-family of
published packages** (`brands/m3e/outputs/elm-m3e/packages.json`,
`core/elm-cem/bin/split.js`). This — not a single package — is what a consumer
depends on and imports, so it is the axis Brand Facts keys its `targets.elm`
bindings by.

**In-flight rework (target taxonomy — key bindings by the *right* column):** the
package family is mid-rename. Brand Facts targets the destination names, treating
the partition itself (which tags/modules land in which package, the families
folding) as a **coordination dependency it consumes, not defines** — the
families-generation infra owns that.

| Destination package | Was | Holds (per rework) |
|---|---|---|
| `elm-m3e-html` | `elm-m3e` | the elm/html-like loose API — **incl. the `M3e` barrel** (moves here), `M3e.Html`, shared vocab, `Unsafe`, Forge engine |
| `elm-m3e-elements` | `elm-m3e-components` | one typed module **per tag** (every element) |
| `elm-m3e-components` | `elm-m3e-families` | **composed families** — child-only tags folded under their parent tag's module |
| `elm-m3e-builder` | `elm-m3e-builder` | builder pattern over `components` |
| `elm-m3e-icons` | (retained) | `M3e.Icon` |
| `elm-m3e-facts` | (retained) | `M3e.Review.Facts` — the `List Fact` module elm-review-cem reads |

Enforcement contract, per destination package: `html` — none (loose/escape;
elm-review backstops raw children); `elements`/`components` — compiler (closed
rows + slot-setters); `builder` — compiler (`Available`/`Used` capability rows).
(Exact per-package contract to be confirmed with the rework.)

Two terms of caution: (1) the child-only-tag folding in `components` is the
**slot-acceptance graph** Facts already stores — Facts *exposes* that data for the
families infra to consume, but does **not** own the partition. (2) "facet" is
overloaded in the codebase — `split.js` calls the **packages** facets;
`FactsBundle.elm:73-76` calls the **construction forms** (`top`/Standard,
`build`/Build, `record`/Record, `html`/Html) facets. Those form keys are
**vestigial**; Brand Facts subsumes Face C and drops/renames them rather than
carrying them forward (see §7).

One `admits` fact, projected three ways: a phantom **row type**
(`Internal/Types/ListItem.elm` `LeadingSlot`), **elm-review data**
(`M3e.Review.Facts.facts[i].slotKinds`), and **Face C JSON**. Face C flattens all
facets into one id table, erasing *which contract a consumer is under* — the
concrete deficiency this design fixes.

## 4. Design

### 4.1 One comprehensive file, canonical core + namespaced target bindings

Emit **one** `brand-facts.json`. Its per-component body is the language-neutral
canonical truth; Elm-specific identifiers live under a namespaced `targets.<lang>`
key so non-Elm consumers (figma, okf, tailwind, the skill) read the core and
ignore `targets`, while the cem-figma-connect emitter reads both — one file load,
no cross-file join.

```jsonc
// brand-facts.json
{
  "schemaVersion": 2,
  "provenance": { /* which inputs fed this build — see 4.5 */ },
  "lib": "M3e",
  "components": {
    "m3e-list-item": {
      // ── canonical, language-neutral ──
      "declarationName": "M3eListItemElement",
      "attributes": { /* name → {kind, type, enum?, default?, deprecated?} */ },
      "cssProperties": { /* name → {syntax?, default?} */ },
      "events": { /* … */ },
      "slots": {
        "leading":  { "admits": ["avatar", "icon", "text"] },
        "trailing": { "admits": ["avatar", "icon", "switch"], "multi": true },
        "overline": {}                    // admits ABSENT → open (any kind)
      },
      // ── target bindings (Elm-aware consumers) ──
      "targets": {
        "elm": {
          // keyed by destination PACKAGE (§3.4). Module/ctor identifiers are READ
          // from the generated packages, not authored here — illustrative below.
          "html":       { "module": "M3e.Html", "fn": "listItem", "barrel": "listItem" },
          "elements":   { "module": "M3e.Element.ListItem", "ctor": "listItem",
                          "slotSetters": { "leading": "leading", "trailing": "trailing" } },
          "components": { "family": "List", "placer": "listItem" },   // folded under parent (families infra)
          "builder":    { "module": "M3e.Build.ListItem", "seed": "build", "finalizer": "toElement" }
        }
      }
    }
  }
}
```

A future non-Elm target adds `targets.ts` in the same file; the canonical core
never changes shape.

### 4.2 The encoding convention: mirror the truth via presence / absence

**Present = authored; absent = default.** This is the *whole shape's* rule, not
just slots:

- `admits` **absent** → slot accepts **any** kind (open); `[]` → **sealed**
  (accepts nothing); `[…]` → exactly those kinds.
- `multi` absent → `false`; `required` absent → `false`.
- `targets.figma` absent → no figma facts; `cssProperties` empty → none; etc.

Consumers must treat **absent ≠ empty** (`admits === undefined` vs
`admits.length === 0`) — the shape makes the distinction; code must honor it.

### 4.3 Slot composition: store *acceptance*, derive *placement*

There are two dual relations (both already modelled in the generated types):

- **Acceptance** (container ↔ its slots — "what fills `fizz-buzz`'s `example`?"):
  the kind rows `LeadingSlot`/`TrailingSlot`/`Content`. This is what `admits`
  provides. **We store this**, container-keyed: `components[C].slots[S].admits`.
- **Placement** (child ↔ the slot it claims — `<foo-bar slot="example">`): the
  slot-setter functions + `admittedBy`/`ChildAdmittedBy` rows. **Derived** by
  inverting acceptance — `foo-bar` may bear `slot="example"` in `fizz-buzz` iff
  `foo-bar`'s kind ∈ `fizz-buzz.example.admits` (absent ⇒ any). There is no
  free-standing "`example` is a valid slot" fact; `slot=` is meaningful only
  relative to a container's declared slots.

Three defaults, each its own knob:

| Dimension | Default when unspecified | Source |
|---|---|---|
| **slot inventory** — which named slots container `C` has | **CLOSED** — exactly the CEM's `decl.slots` | CEM |
| **kind constraint** — what `C.S` accepts (`admits`) | **absent → open, `[]` → sealed, `[…]` → listed** | config, optional |
| **placement** — may a child bear `slot="S"` in `C` | **derived** (invert acceptance); open only as the shadow of an absent kind-constraint, scoped to `C` | derived |

Reference derivation (placement + validation):

```js
function validPlacement(childKind, containerTag, slot, facts) {
  const comp = facts.components[containerTag];
  if (!comp || !(slot in comp.slots)) return false;   // inventory CLOSED
  const admits = comp.slots[slot].admits;
  return admits === undefined || admits.includes(childKind); // absent→open, []→sealed, [..]→listed
}
```

### 4.4 Facets are first-class, and carry their contract

Two levels, distinct:

- **Per-component bindings** live under `components[tag].targets.elm.<package>`
  — the module/ctor/setter identifiers for *that* component in *that* package
  (§4.1).
- **Package-level facts** live **once**, at a top-level `targets.elm.packages`
  (sibling to `components`, not repeated per component) — each package's name,
  sibling deps, and enforcement contract (`compiler` / `elm-review` / `none`), so
  a consumer knows which package to import and whether *it* or the compiler owns
  validity. This is the fact Face C erased.

```jsonc
{
  "components": { "m3e-list-item": { "targets": { "elm": { "components": { /* bindings */ } } } } },
  "targets": {
    "elm": {
      // destination package family (§3.4); deps/contract illustrative, confirmed with the rework
      "packages": {
        "html":       { "package": "jackhp95/elm-m3e-html", "deps": [],
                        "contract": { "composition": "none" } },
        "elements":   { "package": "jackhp95/elm-m3e-elements", "deps": ["html"],
                        "contract": { "slotSetterChild": "compiler", "rawContentChild": "elm-review" } },
        "components": { "package": "jackhp95/elm-m3e-components", "deps": ["elements", "html"],
                        "contract": { "composition": "compiler" } },
        "builder":    { "package": "jackhp95/elm-m3e-builder", "deps": ["components", "html"],
                        "contract": { "composition": "compiler" } },
        "icons":      { "package": "jackhp95/elm-m3e-icons" },
        "facts":      { "package": "jackhp95/elm-m3e-facts" }
      }
    }
  }
}
```

### 4.5 Provenance is a separate block, not per-field

A single top-level `provenance` records which inputs fed the build (package +
version + sha of the CEM, the dts dir, each `--config-from` file + hash, generator
version/commit). Individual facts stay clean; meta lives apart. (Subsumes the two
ad-hoc per-face provenance stamps that exist today.)

### 4.6 Producer: enrich the Elm model to a true superset, emit once

Per approved decision, the resolved model becomes the single authoritative
superset rather than joining two producers at encode time:

- `Comp` retains the raw structural facts it currently drops — carry the source
  declaration (e.g. `source : Cem.Declaration`) so `cssProperties`/`cssParts`/
  `cssStates`/`superclass`/`deprecated`/raw-members survive into the model.
- The comprehensive encoder serializes the enriched `Brand`/`Comp` in one Elm
  pass. The JS-side Face B producer (`facts-bundle.js`) folds in; its unique
  value-adds (`.d.ts` alias resolution, tag reconciliation) become inputs to /
  steps of the fold, not a parallel bundle.
- Slot admission gets **one** representation (§4.3); `slotKinds` / `requiredSlots`
  / `multiSlots` become derived views, not stored duplicates.

## 5. Decisions (locked)

1. **One comprehensive `brand-facts.json`**, canonical core + `targets.<lang>`
   bindings. Not two/three bundles. (Consumers may still slice via jq/ts.)
2. **Enrich the Elm model to a true superset**; emit the comprehensive JSON from
   one Elm pass. (Not a JS join.)
3. **Encoding = presence/absence.** absent = default, present = authored;
   `admits` absent→open / `[]`→sealed / `[…]`→listed; applies shape-wide.
4. **Store acceptance, derive placement.** One container-keyed slots table.
5. **Slot inventory is CEM-closed; kind-constraint is open-when-absent.**
6. **Provenance is a separate block**, not per-field.
7. **Facets carry their enforcement contract** as first-class data.
8. **Facts is language-neutral**; Elm identifiers are namespaced under
   `targets.elm`, never smeared into canonical fields.

## 6. Open questions (resolve during planning)

- **Codegen alignment is separable from the JSON.** The JSON already sources slot
  inventory from the CEM (Face B does); adopting "absent → open" in the JSON is
  cheap and unblocks non-Elm consumers **without** touching codegen. Making the
  **generated Elm library** also honor "absent → open" (emit an open slot-setter
  for every CEM-declared-but-unconfigured slot) is a **separate, larger** change
  (`resolveSlot`/`Comp.slots`), regenerates `elm-m3e` with a big reviewable diff,
  and makes unconfigured slots less compile-strict. **Defer as its own phase;**
  decide then whether to do it, and audit whether any component today
  intentionally suppresses a slot by omission.
- **Kind vocabulary in `admits`.** Store raw CEM/config kind tokens
  (`"shared:icon"`, `"avatar"`) as-is (mirror the truth), and let the Elm binding
  layer carry the field-name mapping (`sharedIcon`). Confirm during planning.
- **Naming to lock:** the file (`brand-facts.json`), the top key (`components`),
  `targets`, `contracts`. **Package keys are the destination package family**
  (§3.4): `html` / `elements` / `components` / `builder` / `icons` / `facts` —
  what a consumer imports. The barrel binds under `html`. **Not** the vestigial
  construction forms (`top`/`build`/`record`/`html` in `FactsBundle.elm`) and not
  the earlier invented `strict`/`loose`/`general`/`escape` — both dropped.
- **`schemaVersion` bump** to `2` and whether the hand-rolled validator
  (`validate-facts-bundle.js`) is extended or replaced.

## 7. Phase decomposition

Each phase becomes its own plan (`superpowers:writing-plans`) with its own review.

1. **Canonical schema + validator (design → schema.json).** Define the one shape
   (canonical core + `targets` keyed by destination package + `contracts` +
   `provenance`), pick the single slot representation, **retire the vestigial
   `top/build/record/html` construction-form vocabulary** as Face C is subsumed,
   bump `schemaVersion`, rewrite/extend `docs/facts-bundle/schema.json` +
   `validate-facts-bundle.js`. *No behavior change yet.*
2. **Enrich the model + unified producer.** `Comp` retains `source :
   Cem.Declaration`; comprehensive Elm encoder; fold Face B's JS value-adds in;
   emit one `brand-facts.json`. Ship it **alongside** the existing bundles.
3. **Slot-default flip + dead-input cleanup** *(separable; see §6).* Flip codegen
   absent→open + consult CEM-declared slots; drop `_native`/`_nativeAttrTable`.
4. **Migrate consumers.** Point cem-figma-connect / okf / `oracle.mjs` / tailwind
   at `brand-facts.json`; delete `host-contract-overlay.json` and oracle's raw
   reach-arounds; **unblock the example-tree validator** (the original goal — now
   just a slice of this phase).
5. **Retire Face B/C.** Consolidate schema/validator/`family.json`/drift-gate;
   remove `cem-facts.json` + `elm-api-facts.json`.

The original `admits`-for-Task-1 goal is a slice of phases 2+4; it stops being a
special case.

## 8. Blast radius / migration cost

Touched: `core/elm-cem/bin/facts-bundle.js` + `core/elm-cem/codegen/**` (producer),
`docs/facts-bundle/schema.json` + `validate-facts-bundle.js` (schema),
`tools/family.json` `bundleCopy` + `tools/lib/check-drift-core.mjs` +
`tools/check-drift.mjs` (drift gates), and every consumer reader
(`cem-figma-connect`, `m3e-api-okf`, `tailwind-m3e-web`, `examples-gen`). Staging
phases 2 (additive) before 5 (removal) keeps each step reviewable and the drift
gate green between phases.

**Coordination dependency (not owned here):** the elm-m3e package rework
(`elm-m3e`→`-html` incl. barrel; `-components`→`-elements`; `-families`→
`-components`; per §3.4) is concurrent. Brand Facts keys `targets.elm` by the
**destination** package names and **consumes** the partition (contents, families
folding) rather than defining it — the families-generation infra owns that. Facts
exposes the slot-acceptance graph that infra reads; it does not drive the split.
Phase 4 (consumer migration) sequences after the rework's package names settle.

Consistent with the workspace stance: prefer the correct shape over a small blast
radius; blast radius is a cost, not a blocker.
