# Repo Shape v2 — target-architecture design

Date: 2026-08-19
Status: **WAVE 1 IMPLEMENTED (2026-08-19)** — the directory-reshape slice is executed and
committed on branch `exec/repo-shape-v2-wave1` per `docs/plans/2026-08-19-repo-shape-v2-wave1-plan.md`
(all 7 tasks, `node tools/gate-all.mjs` GREEN). Still-pending deferred items (spec decisions #4, #7,
#9-partial, #8-partial): the 5-package explosion, the `-elements`/`-components` naming inversion, the
3 docs codegen wins, the guide-markdown migration, and every brand beyond m3e + html. Design below was
**DESIGN DECIDED — research complete, all decisions confirmed live with Jack (2026-08-19).** This document reconciles Jack's
`brands/`+`pipeline/`+`packages/` target shape against `elm-cem-workspace`'s CURRENT state
(the `core/`+`brands/` reorg that landed on `main` earlier today, 2026-08-19), and records the
decided architecture directly in each section. The wave-1 execution plan is a **separate**
deliverable: `docs/plans/2026-08-19-repo-shape-v2-wave1-plan.md` (it executes the "this wave"
slice summarized in the Key-decisions appendix below).

The deliberation history behind each decision is preserved inline (as the narrative explaining
*why* the decided architecture is what it is) and condensed in the **Key decisions & rationale**
appendix at the end — every decision keeps its evidence (file:line citations) so a future reader
never has to reconstruct the reasoning.

Companion cross-repo audit: `~/Documents/code/planning/2026-08-19-repo-landscape-audit.md`.

Prerequisite reading this doc builds on (all verified, cited inline):
- `docs/superpowers/specs/2026-08-18-core-brands-workspace-reorg-design.md` (the reorg design)
- `docs/plans/2026-08-18-core-brands-workspace-reorg-plan.md` (exhaustive path inventory)
- `docs/plans/2026-08-18-session-handoff.md` (open work items W4/W7/W8, brand-pluggability)
- `docs/plans/2026-08-19-multi-track-fix-batch-plan.md` (3 pending-merge worktrees; gate-all perf)
- `docs/superpowers/specs/2026-08-18-gate-all-parallelization-design.md` (Track A scheduler)
- `VISION.md` (family table + two open naming questions)

---

## 0. TL;DR for Jack — the shape, now fully decided

Everything below was open research on the morning of 2026-08-19 and is now **settled** — all 8
original open questions plus a new docs-extraction decision were resolved in the live session.
The wave-1 plan executes the physical slice; the deeper package-explosion work is deliberately
deferred. The five things that most shape the result:

1. **The new shape is ~70% a rename of what landed today, not a new architecture.** Today's
   `core/`+`brands/m3e/{inputs,outputs}/` already realizes the inputs/outputs split. The decided
   v2 (a) inserts a `generated/{package,okf,style,docs}/` layer under each brand, (b) *eventually*
   promotes the module-namespace tiers inside `elm-m3e` (`M3e.Component`, `M3e.Build`) into
   standalone sibling Elm packages — **deferred, not in wave 1** — and (c) renames `core/`→`pipeline/`
   for the machinery + carves a new top-level `packages/` for the truly-foundational IR. See §1.

2. **The `-elements`/`-components` rename is a genuine semantic inversion — confirmed adopted, but
   deferred to the package-explosion project, not wave 1.** Today's tag-grouped tier is
   `M3e.Component`; today's family-grouped tier is `elm-m3e-families`. v2 calls the tag-grouped tier
   `-elements` and re-uses `-components` for the family-grouped tier, so "components" changes meaning.
   Jack confirmed the new naming; it lands *atomically with* the 5-package explosion (a later project),
   never as its own churn release. See §2.

3. **`html` is already a brand; the IR is the real substrate; `svg` is roadmap.** `elm-typed-html` is
   a config-driven brand today (not hand-written) and relocates to `brands/html/` this wave.
   `elm-html-intermediate-representation` is the Tier-0 hand-rolled substrate and moves to top-level
   `packages/` — **renamed to `elm-virtual-dom-intermediate-representation`** (confirmed in the wave-1
   planning session). `svg` is a real capability blocked on an IR namespaced-node additive — aspirational,
   not scaffolded. See §3.

4. **Turbo/Nx: do not adopt.** The mixed pnpm+Elm gate logic is genuinely bespoke and has no
   off-the-shelf turbo/nx equivalent; the Track-A custom scheduler already delivered 361.5s→~276s.
   Turbo/Nx cannot model the Elm task graph and would duplicate, not replace, the bespoke gates.
   Verdict + reasoning in §6. (This is the one section with no open question — it was a verdict from
   the start.)

5. **The three-way `tailwind` naming conflict is resolved: split into two packages.** The current
   single `tailwind-m3e-web` conflated agnostic codegen with brand-specific CSS. Decided:
   `pipeline/elm-cem-tailwind/` (agnostic codegen, consolidating `tools/lib/*tailwind*` +
   `core/tailwind-md3`) **and** `brands/m3e/generated/style/elm-m3e-tailwind/` (brand-specific,
   hand-authored `sys/*.css`). See §1 + the Key-decisions appendix.

---

## 1. Reconciliation table (Q1): current path → decided v2 path

**Method:** every current path below verified via `find`/`grep` in this worktree on 2026-08-19.
Current package identities from `tools/family.json` `packages` keys + each `package.json`/`elm.json`
`name` field (grepped directly). The "Decided v2" column is the confirmed target (live session,
2026-08-19); where the decision reversed or narrowed the originally-dictated tree, the Notes column
says so.

### 1a. The machinery ("pipeline" in v2, `core/` today)

Decided: brand-agnostic machinery lives under `pipeline/`; two truly-foundational libs move to a new
top-level `packages/`. Today all of it is under `core/`. The `core/`→`pipeline/` rename happens **this
wave** (see appendix decision #5 — it was briefly considered for batching with the deferred explosion,
but Jack decided against: it is inconsistent to show renamed generated-package names in the target tree
while leaving the machinery dir unrenamed, and the today-reorg already paid most of the path-churn cost).

| Current (today, on `main`) | Decided v2 | Change | Notes |
|---|---|---|---|
| `core/elm-cem/` | `pipeline/elm-cem/` | re-parent `core/`→`pipeline/` | Codegen engine. |
| `core/elm-cem-compose/` | `pipeline/elm-cem-compose/` | re-parent | Name unchanged. |
| `core/elm-review-cem/` | `pipeline/elm-review-cem/` | re-parent | Keeps `elm-review-cem` (adheres to elm-review naming convention). |
| `core/cem-figma-connect/` | `pipeline/elm-cem-figma-connect/` | re-parent **+ rename** | Rename `cem-figma-connect`→`elm-cem-figma-connect` **confirmed** in the wave-1 planning session (matches VISION.md's 2026-08-17 open question, "→ something more Elm-specific"). The mirror repo `jackhp95/cem-figma-connect` stays as-is (external). |
| `core/tailwind-md3/` + agnostic half of `brands/m3e/outputs/tailwind-m3e-web/` | `pipeline/elm-cem-tailwind/` | rename + consolidate | **Tailwind split — confirmed** (appendix #1). The agnostic tailwind codegen (`tools/lib/*tailwind*` + `core/tailwind-md3`) consolidates here. Its brand-specific counterpart is the `elm-m3e-tailwind` row in §1b. |
| `core/elm-html-intermediate-representation/` | `packages/elm-virtual-dom-intermediate-representation/` | re-parent to top-level `packages/` **+ rename** | The foundational layer elm-cem modules build upon — "nothing to do with elm-cem directly." Rename IR→virtual-dom-IR **confirmed** in the wave-1 planning session (the research treated it as merely cosmetic; it is now a decided rename, cascading to every dependent's `elm.json`/relative path). See §3. |
| `core/tonal-palette-oklch/` | `packages/tonal-palette-oklch/` | re-parent to top-level `packages/` | **Stays agnostic — confirmed** (appendix #3). Jack's originally-dictated tree nested this under `brands/m3e/inputs/`, but the decision keeps it at top-level `packages/`: it is generic OKLCH color science (used by `tailwind-md3`), not m3e-specific, and nesting it under `brands/m3e/` would block a future `brands/carbon/` from reaching it without an m3e dependency. |
| `core/elm-typed-html/` | `brands/html/generated/package/elm-typed-html/` | **re-classified substrate → brand output** | It is already a config-driven brand, not hand-written — see §3. Relocates this wave; stays a single monolithic generated package (the per-brand explosion is deferred). |
| `tools/` (gate-all.mjs, bump.mjs, family.json, lib/…) | *(no v2 slot — stays `tools/`)* | unchanged | **Not** one of the `pipeline/` CEM packages. `pipeline/` = the CEM packages; `tools/` = repo orchestration infra. Distinction kept explicit; see §1d. |

### 1b. The m3e brand outputs

Today: `brands/m3e/outputs/{elm-m3e, tailwind-m3e-web, m3e-api-okf}` + nested `elm-m3e/{elm-m3e-families, elm-m3e-icons}`.
Decided: relocate everything under `brands/m3e/generated/{package,style,okf,docs}/`. **The 5-package
explosion of `elm-m3e` is DEFERRED** (appendix #7): this wave `elm-m3e` stays a single package, merely
relocated one level deeper. The explosion rows below describe the *eventual* target for context.

| Current | Decided v2 | Change |
|---|---|---|
| `brands/m3e/outputs/elm-m3e/` (single pkg `jackhp95/elm-m3e`, module namespaces `M3e.Html`/`M3e.Component`/`M3e.Build`) | **this wave:** `brands/m3e/generated/package/elm-m3e/` (still one package). **Eventually (deferred):** split into `{elm-m3e-facts, elm-m3e-core, elm-m3e-elements, elm-m3e-components, elm-m3e-build}` | relocate now; explode later (see §2, §4, appendix #7) |
| `brands/m3e/outputs/elm-m3e/elm-m3e-families/` (pkg `jackhp95/elm-m3e-families`) | eventually `brands/m3e/generated/package/elm-m3e-components/` | **rename `-families`→`-components`** (the inversion, §2) — part of the deferred explosion |
| `brands/m3e/outputs/elm-m3e/elm-m3e-icons/` (pkg `jackhp95/elm-m3e-icons`) | `brands/m3e/generated/package/elm-m3e-icons/` | re-parent (rides along with `elm-m3e` this wave). **Icons tier is brand-optional** (appendix #11): `elm-<brand>-icons` is a real slot for any brand with a glyph/icon-font library (m3e: Material Symbols; a future `web-awesome`: Font Awesome). `html`/`svg` simply don't populate it. |
| *(tag-grouped `M3e.Component` namespace inside elm-m3e)* | eventually `brands/m3e/generated/package/elm-m3e-elements/` | **extract to pkg, name `-elements`** (§2) — deferred |
| *(type-grouped `M3e.Html`/html-like namespace inside elm-m3e)* | eventually `brands/m3e/generated/package/elm-m3e-core/` | extract to pkg — deferred |
| *(`M3e.Build` builder namespace inside elm-m3e)* | eventually `brands/m3e/generated/package/elm-m3e-build/` | extract to pkg (§4) — deferred |
| *(facts — currently `core/elm-cem/facts/`, family.json key `elm-cem-facts`)* | shared **contract** stays in `pipeline/elm-cem-facts/`; per-brand generated **data** in `brands/m3e/generated/package/elm-m3e-facts/` | **resolved** (appendix #2): the facts *types + generation logic* stay shared substrate; only the brand's generated facts *values* live in `elm-m3e-facts`. Same pattern for every brand. (The physical per-brand `elm-m3e-facts` package is created with the deferred explosion.) |
| `brands/m3e/outputs/tailwind-m3e-web/` | `brands/m3e/generated/style/elm-m3e-tailwind/` | re-parent + rename | **Tailwind split — confirmed** (appendix #1). This is the brand half (hand-authored `sys/*.css`); named `-tailwind` despite being partly hand-authored — accepted as-is. Its agnostic counterpart is `pipeline/elm-cem-tailwind` (§1a). |
| `brands/m3e/outputs/m3e-api-okf/` (pkg name still `m3e-okf`) | `brands/m3e/generated/okf/elm-m3e-okf/` | re-parent + rename `m3e-okf`→`elm-m3e-okf` | **Confirmed** (appendix #10), full local-name consistency (dir + `package.json` name + `family.json` key). The mirror repo `jackhp95/m3e-okf` stays external. |
| *(no docs package today — docs live inside `elm-m3e/docs/`)* | `brands/m3e/generated/docs/elm-m3e-docs/` | **extract docs site to its own slot — THIS wave** (appendix #9, §5) |

### 1c. The m3e brand inputs

**Decided: keep the 10 separate config files, relocate only** (appendix #6) — no flattening to a single
`elm-cem-config.json`, no committing the live-resolved CEM. Jack's originally-dictated tree showed a
flattened single-CEM-file + single-config layout; the decision is pure relocation, zero behavior change
(the inputs already landed in their current shape during the 2026-08-18 reorg).

| Current | Decided v2 | Change |
|---|---|---|
| `brands/m3e/inputs/cem/config/*.json` (10 files) + live-resolved `@m3e/web/dist/custom-elements.json` | `brands/m3e/inputs/cem/config/*.json` (unchanged) | **keep 10 files, no flatten, CEM stays live-resolved** (appendix #6) |
| `brands/m3e/inputs/material-okf/` | `brands/m3e/inputs/material-okf/` | unchanged |
| `core/tonal-palette-oklch/` | `packages/tonal-palette-oklch/` | **agnostic, top-level `packages/`** — NOT under `brands/m3e/inputs/` (see §1a; appendix #3) |

### 1d. Things in the decided v2 tree that had **no clean current-day equivalent** (call-outs)

- **`pipeline/elm-cem-tailwind/`** — no standalone `elm-cem-tailwind` package exists today. The agnostic
  tailwind codegen (`generate-component-utilities.mjs`, `gen-facts.mjs`) was promoted to `tools/lib/`
  during "W6" (per session-handoff §5); the generic M3 color science is `core/tailwind-md3`; the
  brand-specific bridge is `tailwind-m3e-web`. So `pipeline/elm-cem-tailwind` is a **new consolidation**
  of the agnostic `tools/lib/` tailwind code + `core/tailwind-md3` into one real package — partly done,
  not a pure move. **Confirmed as the decided shape** (appendix #1). (The single-consumer
  `component-css-utilities.mjs` moves in; the 3-consumer `gen-facts-runner.mjs` stays shared in
  `tools/lib` — see the wave-1 plan's finding U.)
- **`brands/*/generated/` layer** — no brand has a `generated/` grouping dir today; outputs sit directly
  under `outputs/`. v2 inserts `generated/{package,okf,style,docs}/` as an organizing tier. Decided.
- **`brands/html/`** — decided **near-term** (this wave): `elm-typed-html` relocates here (§3).
  **`brands/svg/`, `brands/shoelace/`, `brands/web-awesome/`, `brands/calcite/`, `brands/fluent-ui/`,
  `brands/warp/`, `brands/etc/`** — **aspirational target end-state, NOT scaffolded now** (appendix #8).
  No empty brand directories are created in this wave. See §3 (svg) and the audit doc (adoptable repos).
- **`brands/*/generated/okf/`** — decided single `generated/okf/elm-m3e-okf/` collapses only the *output*
  half of OKF; the `material-okf` input stays an input. Consistent, minor rename.

---

## 2. The `-elements`/`-components` naming swap (Q2): **confirmed inversion, deferred with the explosion**

**Decision (appendix #4): adopt the new naming — the inversion is confirmed — but land it atomically with
the (deferred) 5-package explosion, never as its own churn release.** The names are better
(elements=tag, components=families reads more naturally), but the inversion is dangerous precisely
because the old word is reused with new meaning, so it must ship with the split that first creates the
packages. Verified current names that make this an inversion:

| Tier (what it groups) | Current name | v2 name | Evidence |
|---|---|---|---|
| tag-grouped, per-component API | `M3e.Component.*` (module) / planned pkg `elm-m3e-components` | **`-elements`** | `src/M3e/Component/` dir; codegen `Generate/Phantom/Emit/Component.elm:646` emits `file [ lib, "Component", comp.name ]`; planned name in `packages.json:82` = `jackhp95/elm-m3e-components` |
| family-grouped re-exports | `M3e.Family.*` / pkg `jackhp95/elm-m3e-families` | **`-components`** | `elm-m3e-families/elm.json:3` name `jackhp95/elm-m3e-families`, module ns `M3e.Family.*` |

Under v2 the word **"components" changes meaning**: today it's the tag-grouped tier (`M3e.Component`),
in v2 it's the family-grouped tier (today's `-families`). And v2 introduces **"elements"** for what is
today called "components." This is a straight semantic swap of an already-shipped, already-published
vocabulary — the single highest grep-and-replace hazard in the whole reshape, which is exactly why it
is gated behind the package split rather than done as standalone churn.

**A *different*, already-planned split uses the OLD vocabulary — and it must be reconciled first.** There
is a `brands/m3e/outputs/elm-m3e/packages.json` that already encodes a planned explosion of the
monolithic `elm-m3e` into `elm-m3e-core`, `elm-m3e-html`, `elm-m3e-components` (tag-grouped),
`elm-m3e-builder`. Those planned names are **not yet live** (only `elm-m3e`, `elm-m3e-families`,
`elm-m3e-icons` are real packages today — verified via `find … -name elm.json`), but
`elm-m3e-families/elm.json:37-38` already lists `elm-m3e-core` + `elm-m3e-components` as *dependencies*
tracking that planned state.

**New finding from the live session (not in the original grep sweep):** the `packages.json` plan uses
**`elm-m3e-html`** for the foundational tier, *not* `elm-m3e-core` — a **second** naming mismatch beyond
the elements/components swap. So the full rename map for whenever the explosion lands is:

- `elm-m3e-html` → **`elm-m3e-core`** (foundational tier)
- `elm-m3e-components` (tag-grouped) → **`elm-m3e-elements`**
- `elm-m3e-builder` → **`elm-m3e-build`**
- plus a **net-new 6th package** `elm-m3e-components` (now meaning family-grouped), built from the
  already-built-but-inline `elm-m3e-families/` subdir — this package does **not** exist in the pre-v2
  `packages.json` plan at all.

`packages.json` itself needs a rewrite pass when the explosion is scheduled (reconciling its planned
names to the decided v2 vocabulary **before** the split ships, so the split doesn't immediately
re-invert). Not done now — the explosion is deferred (appendix #7).

### 2a. Migration blast radius (enumerated, for the deferred explosion — NOT executed this wave)

A `-families`→`-components` and `-components`(tag)→`-elements` rename touches at minimum:

- **elm.json / packages.json / slots.json `name` fields:** `elm-m3e-families/elm.json:3`;
  `packages.json:82,107`; `brands/m3e/inputs/cem/config/slots.json:36-47` (lists both
  `jackhp95/elm-m3e-families` and `jackhp95/elm-m3e-components` — the `_families` block that Track B
  confirmed is the real family source, per `2026-08-19-multi-track-fix-batch-plan.md:15`).
- **Elm module namespaces (source-wide):** `M3e.Component.*` → new tag-grouped name — **~4,977 grep
  hits** across src/docs/samples/review/codegen (the `src/M3e/Component/` dir alone is ~130 files);
  `M3e.Family.*` → `M3e.Component.*` — **591 references** outside the families source. (Most of the
  4,977 are in *generated* files that regenerate — the real edit is the codegen emitter, not the files.)
- **Codegen emitter (the actual lever):** `core/elm-cem/codegen/Generate/Phantom/Emit/Component.elm:646`
  (hardcoded `"Component"` path segment for the tag-grouped module) and `:1403` (emits
  `import <lib>.Component.<Name> as Component` into every Build module). Change the emitter → the
  ~4,977 generated hits follow. `"Build"` at `:1432` stays.
- **elm-review rule config:** `core/elm-review-cem/src/NoFamilyMemberDrift.elm:26-27` hardcodes
  `[ "M3e", "Component" ]` + `[ "M3e", "Family" ]`; `brands/m3e/outputs/elm-m3e/review/src/ReviewConfig.elm:84-85`
  passes those literal namespace lists; `Cem/Internal/Translate.elm:226-227` doc-comment cites
  `M3e.Component.AppBar`. (The *rule name* `NoFamilyMemberDrift` would arguably also want renaming for
  consistency, but that's cosmetic.)
- **Built docs-site paths:** `docs/dist/components/` and `docs/dist/family/` directory names in output.
- **External downstream consumers:** `~/Documents/code/buildoc` (`wave2-buildoc-revendor` worktree,
  2026-08-18) is mid-migration onto elm-m3e's phantom substrate — a published `-families`→`-components`
  rename is a breaking change for it and any other consumer. In Elm every published-package rename is a
  hard version-cascade break (VISION.md "Deep seams only"). This is why the decision is: do this rename
  **only** as part of the same release that first splits the packages — never as a standalone churn release.

**Execution sequencing when the explosion is scheduled:** (1) reconcile `packages.json`'s planned names to
the v2 vocabulary first, (2) drive the rename entirely from the codegen emitter + config, (3) land it
atomically with the package split, (4) write a one-page "the word 'components' now means X" migration note
pinned in the brand README and VISION.md.

---

## 3. `html`/`svg` as brands vs. shared substrate (Q3): **html is already a brand; svg is roadmap; the IR is the real substrate**

The session-handoff framed `elm-typed-html` + `elm-html-intermediate-representation` as "shared
substrate." Investigation shows that's **half right, and the half that's wrong is important.** Decided
scope (appendix #8): **`brands/html/` is near-term (this wave); `brands/svg/` is aspirational roadmap.**

**`elm-typed-html` is ALREADY a brand — same pipeline as m3e, not hand-written.**
- `core/elm-typed-html/README.md:65`: "This is a **generated** package. Every module under `src/` is
  emitted by the elm-cem phantom generator from two committed inputs (`manifest/native.cem.json` and
  `config/config.json`); there are **zero post-codegen tweaks**, and that contract is enforced by a gate."
- `core/elm-typed-html/scripts/regen.sh` runs `elm-cem --flags-from=manifest/native.cem.json
  --config-from=config/config.json --output=src` — **identical invocation shape to m3e.**
- `config/config.json` carries `"_phantom": true`, `"_brand": "TypedHtml"`, `_globals`/`_sets`/
  `_controlled`/`_variants`/`_renames`/`_aria` — structurally the same config family as m3e's.
- `core/elm-cem/family-configs/m3e.json:7-11` lists `jackhp95/elm-typed-html` as a `consumerPackage`
  in the same family constellation.
- The one HTML-specific code path in the whole generator is a `legacyHtml : Bool` config flag
  (`core/elm-cem/codegen/Generate/Phantom/Model.elm:421,1447`) that only gates emitting the
  `TypedHtml.Unsafe` (`fromHtml` escape) module — it does **not** fork the element/attribute codegen.
  So HTML is a *brand distinguished by config*, not by architecture.

→ **Decided: move `elm-typed-html` to `brands/html/{inputs/config.json, generated/package/elm-typed-html}`
this wave — a pure structural relocation matching the m3e shape, no pipeline work.** The v2 framing of
`html/` as a full brand describes what already exists. Caveat: today `elm-typed-html` is a *single*
generated package (not yet exploded into `-core`/`-elements`/`-components`/`-build`), same as elm-m3e —
so the per-brand `generated/package/{...}` explosion for html is the *same* deferred work as for m3e,
times two. This wave relocates it monolithic.

**`elm-html-intermediate-representation` is NOT a brand — it's the Tier-0 substrate, and it moves to
top-level `packages/` renamed to `elm-virtual-dom-intermediate-representation`.**
- `core/elm-html-intermediate-representation/README.md:8`: "This is the **only hand-rolled package in
  the system**. Everything delivered above it is config-generated." It provides `HtmlIr.{Element,Node,
  Attribute,Value,Kind}` + fenced `HtmlIr.Internal`; both `TypedHtml` and `M3e` import it as an ordinary
  dependency (confirmed: `M3e.Build.Button` imports `HtmlIr.Element as El`, see §4).

→ It is genuinely brand-agnostic, genuinely foundational, and genuinely "nothing to do with elm-cem
directly," so it belongs at top-level `packages/` (out of both `core/`/`pipeline/` and `brands/`).
**The rename IR→`elm-virtual-dom-intermediate-representation` is confirmed** (wave-1 planning session):
this is a decided published-package rename, not the "cosmetic" note the research first assumed — it
cascades to every dependent's `elm.json` dependency entry and every relative `source-directories` path.
The Elm module namespace (`HtmlIr.*`) is unaffected by the package rename; only paths + the package
`name` field change.

**`svg` is architecturally coherent but does NOT exist and is blocked on an IR additive.**
- Zero SVG anything today: no `elm-typed-svg` pkg/dir, no SVG CEM manifest, no SVG brand config (grep
  for `TypedSvg`/`elm-typed-svg`/svg brand → 0 hits).
- Hard blocker: `HtmlIr.Node` has **no namespaced-node constructor**; the IR README explicitly lists
  "Namespaced (SVG) nodes/attributes" under "Deliberately deferred." An SVG brand cannot be generated
  until the IR grows namespaced nodes.

→ **Decided sequencing for svg (roadmap, not this wave):** (1) additive to
`elm-virtual-dom-intermediate-representation` — namespaced nodes/attrs; (2) author an SVG CEM manifest
from the SVG spec (the same way `native.cem.json` was authored from the WHATWG HTML spec); (3) then the
SVG brand generates through the existing pipeline for free. `brands/svg/` is **aspirational**, not
scaffolded now (appendix #8).

**Net for Q3:** `brands/html/` = relocate-existing (easy, this wave); `packages/elm-virtual-dom-ir/` =
relocate-existing substrate + rename (this wave); `brands/svg/` = new capability behind an IR additive (a
mini-project, deferred). html already *is* the "second real brand" that proves brand-pluggability, quietly.

---

## 4. Does builder depend on core when it should depend on elements? (Q4): **no bug — builder already depends on elements**

**Direct answer: builder correctly imports the elements (tag-grouped) tier today, not a core tier.**
There is no standalone `-build` package yet — `M3e.Build.*` is inline in the monolithic
`jackhp95/elm-m3e` (and stays inline this wave; the split is deferred, appendix #7). Reading an actual
builder module, `brands/m3e/outputs/elm-m3e/src/M3e/Build/Button.elm:19-31`:

```elm
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import M3e.Action as Ac
import M3e.Attributes as A
import M3e.Component.Button as Component   -- ← the tag-grouped ("elements") tier
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values
```

The builder imports `M3e.Component.Button` (the tag-grouped tier that v2 renames `-elements`). The codegen
hardcodes this: `Generate/Phantom/Emit/Component.elm:1403` emits `import <lib>.Component.<Name> as Component`
into every Build module. The other `M3e.*` imports (`Action`, `Attributes`, `Events`, `Kind`, `Values`) are
**shared utility modules in the same monolithic package** — not a separate "core" package. So there is *no
cross-package dependency to a core tier* to be wrong about today.

**When the (deferred) split executes** (`packages.json:91-93,112-118`): `elm-m3e-builder` → depends on
`elm-m3e-components` (tag-grouped) + `elm-m3e-html` (shared utils); `elm-m3e-components` → depends on
`elm-m3e-html`. So the *planned* graph already has builder depending on the elements tier + a thin
html/util tier — **exactly what Jack wants.** The worry ("does builder depend on core when it should
depend on elements?") would only be a real bug if builder imported a core tier *instead of / without*
elements — and it does not.

**One thing to watch when the split is executed:** the shared `M3e.{Action,Attributes,Events,Kind,Values}`
utils currently co-located with everything must land in the tier the builder is *allowed* to depend on. In
the planned split that's `elm-m3e-html` (v2's `-core`). So post-split, builder depends on **elements +
core-utils**, which is legitimate (elements itself also depends on core-utils — core is the shared-types
floor, elements is the API surface, build wraps elements). The v2 target "builder depends fully on the
element API" holds *as long as* everything builder needs from core is also re-exported through / depended
on transitively via elements — verify no builder module reaches past elements into a core internal that
elements doesn't already surface. Today that can't be checked (one package); it becomes a checkable
elm-review rule once split (a `NoBuilderCoreBypass`-style rule, analogous to the existing
`NoFamilyMemberDrift`). **Recommend adding that rule as part of the (deferred) split**, so the invariant
Jack cares about is enforced, not just asserted.

---

## 5. Docs codegen feasibility (Q5): **partial-generate + markdown-ify prose; do NOT fully generate**

The m3e docs are an **elm-pages** SSG (`docs/elm-pages.config.mjs`; `RouteBuilder.preRender` in
`app/Route/Components/Name_.elm:64`). All prose today is Elm string literals rendered via `Doc.markdown`,
**not** `.md` files. Classified into Jack's three buckets, with evidence:

### Bucket (a) — hand-authored prose that genuinely can't be generated
The 13 pure-prose **guide chapters** under `app/Route/Guide/`: `TheLayers` (163 lines), `Seams` (314),
`Accessibility` (256), `Theming` (286), `Motion` (188), `Strictness` (168), `Glossary` (98),
`CheatSheet` (169), `FirstComponent` (144), etc. Each has `Data = {}` / `BackendTask.succeed {}` — zero
data loading (`app/Route/Guide/TheLayers.elm:50-52`); content is string literals
(`TheLayers.elm:104-105`). These are arguments/walkthroughs carrying design rationale and the OKF
boundary framing ("deep theory lives in m3e-okf; this page is Elm practice"). **Generating them from OKF
data would produce outlines, not the opinionated prose that makes them useful.** Keep hand-authored.

### Bucket (b) — already sourced from facts/OKF/generated
Substantial automation already exists:
- **Per-component API reference pages** ← `scripts/extract-reference.mjs` runs `elm make --docs` →
  `data/reference.json` → `Route.Components.Name_` (`Name_.elm:131-145`) + `Route.Guide.Reference`.
- **Per-component usage examples** ← `scripts/examples-gen/` (1,962 lines) mines `@m3e/web` docs, loads
  elm-cem "Face C" facts (`examples-gen/lib/facts.mjs`), converts HTML→typed Elm via `oracle.mjs`.
- **`app/Compose/Attrs.elm`** ← generated + committed, header `{- GENERATED by
  scripts/gen-compose-attrs.mjs — do not edit. -}` (`Compose/Attrs.elm:3`).
- **Search index** ← `scripts/search-index-gen/` crawls rendered `dist/`.
- **`data/roundtrip-report.json`** ← drives `Route.Guide.Roundtrip` + `HowWeProveIt`.
- **OKF inflow today = ZERO.** OKF (`m3e-okf`) is referenced by URL in prose only
  (`Route.Guide.Accessibility.elm:128`, `Motion.elm:9`, `Theming.elm:11-12`); no OKF data flows into the
  docs at build time. **This is the single biggest untapped "fact/OKF-informed markup" opportunity.**

### Bucket (c) — hardcoded but derivable (the real codegen opportunity)
- **`Route.Family.elm:105-128`** — the `families` list is hardcoded Elm, and the module comment
  (`:9-14`) admits it "**mirrors** [`config/slots.json`'s `_families.families`] rather than re-deriving
  it, so it can only go stale." Trivial BackendTask fix; same data already feeds `gen-family-package.js`.
- **`Route.Styles/` token tables** — `Typography.elm:78-93` (15 type-scale roles), `Shape.elm:83-95`
  (10 corner radii), `Color.elm:77-94` (accents/surfaces) are hand-typed lists derivable from the
  `--md-sys-*` token manifest (`tailwind-m3e-web`/`@m3e/web`). Drift when the scale changes.
- **`Route.GettingStarted.Installation.elm:87-120`** — version strings, package names, CLI flags
  (`jackhp95/elm-m3e`, `@m3e/web`, `elm-cem eject m3e`) hardcoded; derivable from `package.json`/`elm.json`.
- **Component `summary`/`overview`** in `reference.json` come from `@docs` comments — OKF likely has
  richer component descriptions; no bridge exists today.

### Is the `elm-cem-compose` pattern a real template for a docs generator?
**Partly — and it's the right analogy.** `core/elm-cem-compose` is brand-agnostic headless logic taking a
`Dict String Fact` from `jackhp95/elm-cem-facts`; the brand supplies the generated binding
(`Compose.Attrs`, generated per `Compose/Attrs.elm:3`). A `docs-gen` following the same shape would be:
**brand-agnostic docs skeleton** (takes a facts bundle → emits per-component reference pages, token
galleries, family page, component browser) **+ brand-supplied facts config** (`config/slots.json`,
`categories.json`, `examples.generated.json` — all already exist) **+ brand-supplied hand-authored guide
markdown.** That covers ~40% of the current docs surface.

### Decided plan for docs (appendix #9)
**This wave: extract the docs package to `brands/m3e/generated/docs/elm-m3e-docs/`** — same mechanical
class of cost as the `core/brands` reorg and the tailwind split (`git mv` + path fixes, no new
engineering). At extraction, make the `generated/`-vs-`authored/` boundary legible (the generated surface
— reference/examples/family/token pages, search index, `Compose/Attrs.elm` — vs the authored guide
chapters). See the wave-1 plan's Task 5 for how that labeling is done without changing elm-pages URL
routing (a documentation-only correspondence, since moving `app/Route/…` folders would change public URLs).

**Explicitly NOT bundled into this wave** (independently-gated follow-ups, after the physical extraction):
1. **The 3 codegen wins from bucket (c)** — `Route.Family` from `slots.json`; `Route.Styles/` token
   tables from the token manifest; `Installation` version/name strings from package metadata. All
   eliminate real drift, all high-ROI/low-risk. (The per-component reference + examples are already
   generated — leave them.)
2. **Markdown-ify the guide prose (ergonomics, not generation):** move the 13 guide chapters from Elm
   string literals to `.md` files read via `BackendTask.File.rawFile`. **The infra already exists** —
   `docs/guides/` already holds 4 markdown files (`EnumSafety.md`, `Glossary.md`, `Seams.md`,
   `TheLayers.md`). Makes prose diffable without Elm tooling and reusable by the OKF/skill sets. Half-done.
3. **Do NOT fully generate.** Guide chapters are the product's voice; the OKF cross-refs should stay
   links, not data sources. Full generation is a bad idea for the prose specifically.

A truly brand-agnostic `docs-gen` in `pipeline/` (peer of `elm-cem-compose`) emitting the generated
surface, themeable via config, is a realistic Phase-N project — but is **new build**, not a relocation.

---

## 6. Turbo/Nx evaluation (Q6): **verdict — do not adopt**

**Context that decides this:** a custom scheduler (`tools/lib/gate-scheduler.mjs`) is *already being
built this week* (Track A, `docs/superpowers/specs/2026-08-18-gate-all-parallelization-design.md`),
and the pending-merge worktree already achieved **361.5s → ~276s (~24%)** on the real gate
(`docs/plans/2026-08-19-multi-track-fix-batch-plan.md:14`). The question is not "should we parallelize"
(that's done) but "should Turbo/Nx *replace* that investment."

### What Turbo/Nx would actually buy

- **Remote/shared caching.** Real value in CI *if* tasks are hashable by input. But the workspace's
  dominant cost is `elm-m3e: test:browser` (231.9s = 64% of the run,
  `2026-08-18-gate-all-parallelization-design.md:29-30`) — a Playwright browser suite whose inputs
  "span nearly the whole repo (generated docs tree, elm-m3e src, `@m3e/web`, config JSONs)" and which
  "isn't safely scopeable by path" (ibid. §4, lines 204-210). Turbo's content-hash cache would
  almost always miss on the one task worth caching. The Track-A design already builds the *only*
  safe cache here (content-hash `build:site`, cache-and-verify, never skip) as Tier 2 — turbo can't
  do better and would need the same custom input-enumeration anyway.
- **Task-graph parallelization.** Turbo/Nx parallelize a `package.json`-script DAG. Track A's scheduler
  already does bounded-pool parallelism (§3.2) — and crucially models constraints turbo/nx **cannot
  express off the shelf**: `exclusiveWith` tags for the shared `docs/dist` tree, the port-1239
  singleton, shared mutable `ELM_HOME`, and the `.gate-out/probe.js` scratch file
  (`2026-08-18-gate-all-parallelization-design.md:43-71`). These are mutual-exclusion constraints,
  not producer→consumer edges; turbo/nx's dependency model is the wrong shape for them.
- **Task-graph visualization / affected-detection.** `nx affected` is the marquee feature, but it keys
  on a JS import graph + project.json edges. It has **zero native understanding of the Elm task graph**
  (`elm.json` `source-directories`, the `ELM_HOME` global package registry, `elm-review`/`elm-test-rs`).
  Every Elm package's real dependency edges would be invisible to Nx, so `affected` would be unsound
  for exactly the half of the monorepo that matters most.

### What it would cost

- **A second orchestration layer over genuinely bespoke gates.** `gate-all.mjs` runs drift checks
  (`check-drift.mjs`), mirror-publish gating (`publish-mirror`/`check-mirror-drift`, human-gated per
  session-handoff O-1), copy-fidelity (`copy-fidelity.mjs`), facts-bundle E2E regen (memoized across
  7+ consumers per Tier 4), `check-gates` self-verification (the "no silent skip" invariant,
  `2026-08-18-gate-all-parallelization-design.md:189-202`). None of these are `turbo run build`-shaped
  tasks. You'd end up calling the bespoke Node gates *from* turbo tasks — turbo becomes a thin wrapper
  that adds a config surface (`turbo.json`) and a caching layer that's unsafe for the big task, while
  the real logic stays in `tools/`. Net: more moving parts, no capability gained.
- **The "no silent skip" invariant fights caching.** This repo treats "a gate became silently
  skippable" as a documented bug class (`CHRONIC_SKIPS`, `check-gates`;
  `2026-08-18-gate-all-parallelization-design.md:189-196`). Turbo's whole value proposition is
  *skipping* cached tasks. Every turbo cache hit would need to be reconciled against the invariant
  that every gate visibly runs or visibly reports why not — which is precisely the cache-and-verify
  discipline Track A already encodes and turbo does not.

### Verdict

**Do not adopt Turbo or Nx.** They would *complement* nothing that isn't already better served by the
Track-A scheduler, would *conflict* with the no-silent-skip invariant, and cannot *replace* the
bespoke gates or model the Elm task graph. Continue investing in `tools/lib/gate-scheduler.mjs`.

**One caveat worth a follow-up (not a reversal):** if the workspace grows to many brands (html, svg,
shoelace, web-awesome, …) each with a full `generated/package/` set, the number of independent Elm
`check`/`test` tasks could grow large enough that a *purpose-built* affected-detection over the
`family.json` manifest becomes worthwhile — but that's an extension of the existing custom scheduler
(it already reads `family.json`), not a turbo/nx adoption. Note it in the plan as a scaling item.

---

## 7. Redundant/valuable folder audit (Q7) — summary; full detail in the companion doc

Full survey with per-repo evidence: `~/Documents/code/planning/2026-08-19-repo-landscape-audit.md`.
Headline as it bears on v2:

- **Five live standalone CEM-brand binding repos are NOT in the workspace and map cleanly to `brands/`
  slots:** `elm-shoelace`→`brands/shoelace/` (67 Elm files), `elm-web-awesome`→`brands/web-awesome/`
  (180), `elm-calcite`→`brands/calcite/` (122), `elm-fluent-ui`→`brands/fluent-ui/` (68),
  `elm-warp`→`brands/warp/` (35). All use the *same* elm-cem pipeline as m3e, all recently committed.
  These are the concrete answer to "does elm-shoelace already contain work that could seed
  `brands/shoelace/`?" — **yes.** They also mean the 2026-08-17/18 consolidation covered only the family
  *core*, not these brand repos. **Decided (appendix #8): these are target end-state, NOT adopted this
  wave** — the near-term brand build list is m3e + html only.
- **`elm-cem-template`** (187 Elm files, full CI/review scaffold, name `jackhp95/elm-your-library`) is the
  canonical **new-brand bootstrap** — relevant because adopting the 5 repos above should be
  template-driven and repeatable, and because it's what a `brands/_template/` slot instantiates.
- **`matraic-m3e`** is the upstream `@m3e/web` source library (JS/TS, zero Elm) — a *dependency* of
  `brands/m3e/inputs`, not a brand slot. Keep separate.
- **Dead weight (archive/delete):** `m3e-builder` (empty), `elm-geo-ip` (empty), `elm-material` (CSS
  scratch), `elm-events` (demo shell), `matraic-m3e-wt` (dangling worktree), `provcore-worktrees` (empty),
  `animal-spirits-eyg-spike` (orphaned spike).
- **No duplicates of workspace content** among the spot-check repos — consolidation was clean.
- **`elm-dom-decode`** — **excluded from this effort** (confirmed with Jack, 2026-08-19): not part of
  the repo-shape-v2 scope. Stays standalone; no placement decision made here.

**Bearing on the v2 shape:** the existence of 5 real brand repos strongly validates the `brands/<name>/`
generalization — and the decided sequencing reflects it: settle the spec (done) → the `-elements`/
`-components` naming (§2) and the `generated/package/{...}` explosion (§1b) are settled-but-deferred, so
future brand adoptions land into a stable layout → adopt one (`elm-shoelace`, smallest) as the
pluggability proof and shape shakedown → batch the rest. None of that adoption is in wave 1.

---

## Key decisions & rationale (2026-08-19 live session with Jack)

All 8 original open questions were resolved directly with Jack, plus 3 additional decisions/findings
surfaced during that conversation. This appendix is the condensed decision record — the full reasoning
and evidence live inline in §1–§7 (pointers below). Two further renames (IR, `cem-figma-connect`) were
confirmed in the *wave-1 planning* session and are noted here so the record is complete in one place.
The plan doc references these by number (e.g. "spec decision #5").

1. **Tailwind — split, confirmed.** `pipeline/elm-cem-tailwind/` (agnostic codegen, consolidating
   `tools/lib/*tailwind*` + `core/tailwind-md3`) + `brands/m3e/generated/style/elm-m3e-tailwind/`
   (brand-specific, hand-authored `sys/*.css`). Brand half named `-tailwind` despite partial
   hand-authoring — accepted. *Detail: §1a, §1b, §1d.*
2. **`elm-m3e-facts` — shared contract, per-brand generated data, confirmed.** `pipeline/elm-cem-facts/`
   keeps the types + generation logic; `brands/m3e/generated/package/elm-m3e-facts/` is generated *data*
   built against that contract (same pattern for every brand). *Detail: §1b facts row.*
3. **`tonal-palette-oklch` — stays agnostic, confirmed.** Moves to top-level `packages/`, NOT
   `brands/m3e/inputs/` (reversing the originally-dictated nesting) — generic color math must be reachable
   by any future brand without an m3e dependency. *Detail: §1a, §1c.*
4. **`-elements`/`-components` naming inversion — confirmed, adopt new meaning; lands atomically with the
   (deferred, #7) package split, not its own release.** New finding: `packages.json` uses `elm-m3e-html`
   for the foundational tier (not `elm-m3e-core`) — a second mismatch. Full rename map + a net-new 6th
   package `elm-m3e-components` (family-grouped). `packages.json` needs a rewrite pass when the explosion
   is scheduled. *Detail: §2.*
5. **`core/`→`pipeline/` rename — do it now, this wave, NOT batched with the deferred explosion.**
   Inconsistent to show renamed generated-package names in the target tree while leaving the machinery dir
   unrenamed; `elm-typed-html` and `elm-m3e` are both codegen outputs. Lands alongside inputs/tailwind/docs
   work as one reshape wave, ahead of and independent from the 5-package explosion. *Detail: §1a.*
6. **`brands/m3e/inputs/` — keep the 10 separate config files, relocate only, confirmed.** No collapse to a
   single `elm-cem-config.json`, no committing the live-resolved CEM. Pure relocation, zero behavior
   change. *Detail: §1c.*
7. **Standalone `-build` package / full 5-package explosion — deferred, confirmed out of scope for this
   wave.** `elm-m3e` and `elm-typed-html` both stay monolithic internally. This wave is the directory
   reshape (pipeline rename, inputs relocation, tailwind split, docs extraction, `m3e-okf` rename); the
   explosion is a separate future project, scoped from `packages.json` (once rewritten per #4) + the
   equivalent for `elm-typed-html`. *Detail: §1b, §2, §4.*
8. **Brand scope — target end-state confirmed; near-term build list is m3e + html only.** `svg`,
   `shoelace`, `web-awesome`, `calcite`, `fluent-ui`, `warp`, `etc/` are the aspirational full list, not
   scaffolded now. No empty brand directories created in this wave. *Detail: §1d, §3, §7.*
9. **`elm-m3e-docs` extraction — extract `elm-m3e/docs/` to `brands/m3e/generated/docs/elm-m3e-docs/` in
   this wave** (`git mv` + path fixes, no new engineering). Make the `generated/`-vs-`authored/`
   correspondence legible at extraction time (documentation-only, since elm-pages folder names are public
   URLs — see the plan's Task 5). **Explicitly NOT in this wave:** the 3 codegen wins from §5 bucket (c)
   and the guide-markdown migration (both later, independently-gated follow-ups). *Detail: §5.*
10. **`m3e-okf`→`elm-m3e-okf` rename — confirmed, full local consistency.** Directory + `package.json`
    name + `family.json` key all → `elm-m3e-okf`; the mirror repo `jackhp95/m3e-okf` stays external. Land
    whenever convenient within the reshape (a standalone small rename). *Detail: §1b okf row.*
11. **Icons tier — confirmed brand-optional, not m3e-exclusive.** `elm-<brand>-icons` is a real deliverable
    slot for any brand with a glyph/icon-font library (m3e: Material Symbols; a future `web-awesome`: Font
    Awesome). `html`/`svg` don't populate it. No tree change — confirms the tier isn't hardcoded to m3e.
    *Detail: §1b icons row.*

**Confirmed in the wave-1 planning session (renames not in the original §Q&A):**
- **IR rename** — `elm-html-intermediate-representation` → `elm-virtual-dom-intermediate-representation`,
  as part of the `packages/` extraction (this wave). Cascades to every dependent's `elm.json`/relative
  path. *Detail: §1a, §3.*
- **`cem-figma-connect` rename** — → `elm-cem-figma-connect`, as part of the `core/`→`pipeline/` move
  (this wave). Mirror repo `jackhp95/cem-figma-connect` stays external. *Detail: §1a.*

### Net effect: what's actually in "this wave" (the wave-1 plan executes exactly this)

`core/`→`pipeline/` rename · `cem-figma-connect`→`elm-cem-figma-connect` rename · IR extraction to
`packages/` + rename to `elm-virtual-dom-intermediate-representation` · `tonal-palette-oklch` to
`packages/` · `elm-cem-tailwind`/`elm-m3e-tailwind` split · `elm-m3e-docs` extraction (+ internal
`generated/`/`authored/` labeling) · `m3e-okf`→`elm-m3e-okf` rename · `elm-m3e` relocation (monolithic)
· html brand relocation · inputs/config relocation (already landed in the 2026-08-18 reorg, no further
change). **Explicitly deferred to a later, separate project:** the 5-package explosion
(`elm-m3e-core/elements/components/build/facts`, `packages.json` rewrite, same for `elm-typed-html`), the
`-elements`/`-components` naming inversion execution, the 3 docs codegen wins, the guide-markdown
migration, and every brand beyond m3e + html.

---

## Appendix — scope guardrails honored in this research

- **No code, no moves, no renames.** Only docs written. Verified `find`/`grep` for every structural
  claim; agent findings cross-checked against first-hand greps (family.json keys, elm.json names,
  pnpm-workspace globs, elm-m3e tier dirs).
- **Did not touch** the 3 pending-merge worktrees (`.claude/worktrees/agent-{a8e48485eed5250b1,
  adf03debc8e3b774c,ae099ba76362fbf0d}`) — their content treated as "pending, not yet on main."
- **Did not touch** any `jackhp95/<name>` GitHub mirror.
- **The execution plan is a separate deliverable** — `docs/plans/2026-08-19-repo-shape-v2-wave1-plan.md`.
