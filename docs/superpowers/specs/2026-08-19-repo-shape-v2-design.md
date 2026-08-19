# Repo Shape v2 — target-architecture design

Date: 2026-08-19
Status: **DRAFT — research + design only.** No code, no moves, no renames. This
document reconciles Jack's newly-dictated `brands/`+`pipeline/`+`packages/` target
shape against `elm-cem-workspace`'s CURRENT state (the `core/`+`brands/` reorg that
landed on `main` earlier today, 2026-08-19). The execution plan is a **separate,
later** deliverable — deliberately out of scope here per Jack's framing ("figure out
exactly what we want to do, and THEN develop a plan").

Companion cross-repo audit: `~/Documents/code/planning/2026-08-19-repo-landscape-audit.md`.

Prerequisite reading this doc builds on (all verified, cited inline):
- `docs/superpowers/specs/2026-08-18-core-brands-workspace-reorg-design.md` (the reorg design)
- `docs/plans/2026-08-18-core-brands-workspace-reorg-plan.md` (exhaustive path inventory)
- `docs/plans/2026-08-18-session-handoff.md` (open work items W4/W7/W8, brand-pluggability)
- `docs/plans/2026-08-19-multi-track-fix-batch-plan.md` (3 pending-merge worktrees; gate-all perf)
- `docs/superpowers/specs/2026-08-18-gate-all-parallelization-design.md` (Track A scheduler)
- `VISION.md` (family table + two open naming questions)

---

## 0. TL;DR for Jack — the five things that matter most

1. **The new shape is ~70% a rename of what landed today, not a new architecture.** Today's
   `core/`+`brands/m3e/{inputs,outputs}/` already realizes the inputs/outputs split. Jack's v2
   mostly (a) inserts a `generated/{package,okf,style,docs}/` layer under each brand, (b) promotes
   the module-namespace tiers inside `elm-m3e` (`M3e.Component`, `M3e.Build`) into **standalone
   sibling Elm packages**, and (c) renames `core/`→`pipeline/` for the machinery + carves a new
   top-level `packages/` for the truly-foundational IR. See §1.

2. **The `-elements`/`-components` rename is a genuine semantic inversion and the single
   highest-confusion-risk item.** Today's tag-grouped tier is `M3e.Component`; today's
   family-grouped tier is the `elm-m3e-families` package. Jack's v2 calls the tag-grouped tier
   `-elements` and re-uses the word `-components` for the family-grouped tier. So "components"
   changes meaning. This needs an explicit, mechanical migration note; see §2.

3. **`html`/`svg` as full brands is aspirational, not a rename of today's reality.** `elm-typed-html`
   and `elm-html-intermediate-representation` are brand-agnostic *shared substrate* today, not
   CEM-driven brand outputs. Reframing them as brands with their own `inputs/{cem,config}` +
   `generated/` set is a real architectural fork requiring new codegen paths that don't exist yet.
   Recommendation in §3. (This overlaps the still-unproven "second real brand end-to-end" work item.)

4. **Turbo/Nx: don't adopt.** This is a mixed pnpm+Elm monorepo whose gate logic (drift checks,
   mirror-publish gating, facts-bundle regen memoization, `ELM_HOME`/port/`docs/dist` exclusion) is
   genuinely bespoke and has no off-the-shelf turbo/nx equivalent. The Track-A custom scheduler
   already delivered 361.5s→~276s. Turbo/Nx would add an orchestration layer that can't model the
   Elm task graph and would duplicate, not replace, the bespoke gates. Verdict + reasoning in §6.

5. **The three-way `tailwind` naming conflict is unresolved and needs Jack's call.** Current package
   is `tailwind-m3e-web`; VISION.md's 2026-08-17 open question suggests `elm-cem-tailwind`; today's
   v2 message names it `elm-m3e-tailwind` (under `brands/m3e/generated/style/`) AND separately names
   a `pipeline/elm-cem-tailwind/`. These are arguably two *different* things (brand output vs.
   agnostic machinery) that the current single package still conflates. See Open Questions §8.

---

## 1. Reconciliation table (Q1): current path → Jack's v2 proposed path

**Method:** every current path below verified via `find`/`grep` in this worktree
(`/Users/jack/.paseo/worktrees/3ov4grvm/spec-repo-shape-v2-research`) on 2026-08-19.
Current package identities from `tools/family.json` `packages` keys + each `package.json`/`elm.json`
`name` field (grepped directly).

### 1a. The machinery ("pipeline" in v2, `core/` today)

Jack's v2 puts brand-agnostic machinery under `pipeline/` and one foundational lib under `packages/`.
Today all of it is under `core/`.

| Current (today, on `main`) | v2 proposed | Change | Notes |
|---|---|---|---|
| `core/elm-cem/` | `pipeline/elm-cem/` | re-parent `core/`→`pipeline/` | Codegen engine. v2 name matches. |
| `core/elm-cem-compose/` | `pipeline/elm-cem-compose/` | re-parent | v2 name matches exactly. |
| `core/elm-review-cem/` | `pipeline/elm-review-cem/` | re-parent | v2 keeps `elm-review-cem` (adheres to elm-review naming convention — v2 message says so explicitly). |
| `core/cem-figma-connect/` | `pipeline/elm-cem-figma-connect/` | re-parent **+ rename** | v2 renames `cem-figma-connect`→`elm-cem-figma-connect`. Matches VISION.md's 2026-08-17 open question ("→ something more Elm-specific"). |
| `core/tailwind-md3/` + part of `brands/m3e/outputs/tailwind-m3e-web/` | `pipeline/elm-cem-tailwind/` (agnostic half) **and** `brands/m3e/generated/style/elm-m3e-tailwind/` (brand half) | split identity across two homes | **Three-way naming conflict — see §8.** The agnostic codegen already lives in `tools/lib/` + `core/tailwind-md3`; the brand-specific `sys/*.css` in `tailwind-m3e-web`. |
| `core/elm-html-intermediate-representation/` | `packages/elm-virtual-dom-intermediate-representation/` | re-parent to top-level `packages/` **+ rename** | v2 explicitly frames this as "the foundational layer elm-cem modules build upon… nothing to do with elm-cem directly." Rename IR→virtual-dom-IR. See §3. |
| `core/elm-typed-html/` | `brands/html/generated/package/elm-typed-html-core/` (+ siblings) | **re-classified from substrate to brand output** | Major reinterpretation — see §3. |
| `core/tonal-palette-oklch/` | `brands/m3e/inputs/tonal-palette-oklch/` | **re-classified core→brand-input** | v2 explicitly lists `tonal-palette-oklch` under `brands/m3e/inputs/`. Today it's in `core/` (used by `tailwind-md3`). See §8 open Q — is it m3e-specific or generic M3 color science? |
| `tools/` (gate-all.mjs, bump.mjs, family.json, lib/…) | *(no v2 slot — stays `tools/`)* | unchanged | **Not** one of v2's 5 named `pipeline/` packages. v2's `pipeline/` = the 5 CEM packages; `tools/` = repo orchestration infra. Keep this distinction explicit; see §1d. |

### 1b. The m3e brand outputs

Today: `brands/m3e/outputs/{elm-m3e, tailwind-m3e-web, m3e-api-okf}` + nested `elm-m3e/{elm-m3e-families, elm-m3e-icons}`.
v2 explodes `elm-m3e` into a `generated/package/` set of standalone packages.

| Current | v2 proposed | Change |
|---|---|---|
| `brands/m3e/outputs/elm-m3e/` (single pkg `jackhp95/elm-m3e`, module namespaces `M3e.Html`/`M3e.Component`/`M3e.Build`) | split into `brands/m3e/generated/package/{elm-m3e-facts, elm-m3e-core, elm-m3e-elements, elm-m3e-components, elm-m3e-build}` | **explode 1 pkg → 5 pkgs** (see §2, §4) |
| `brands/m3e/outputs/elm-m3e/elm-m3e-families/` (pkg `jackhp95/elm-m3e-families`) | `brands/m3e/generated/package/elm-m3e-components/` | **rename `-families`→`-components`** (the inversion, §2) |
| `brands/m3e/outputs/elm-m3e/elm-m3e-icons/` (pkg `jackhp95/elm-m3e-icons`) | `brands/m3e/generated/package/elm-m3e-icons/` | re-parent only |
| *(the tag-grouped `M3e.Component` namespace inside elm-m3e)* | `brands/m3e/generated/package/elm-m3e-elements/` | **extract to pkg, name `-elements`** (§2) |
| *(the type-grouped `M3e.Html`/elm/html-like namespace inside elm-m3e)* | `brands/m3e/generated/package/elm-m3e-core/` | extract to pkg |
| *(the `M3e.Build` builder namespace inside elm-m3e)* | `brands/m3e/generated/package/elm-m3e-build/` | extract to pkg (§4) |
| *(facts — currently `core/elm-cem/facts/`, family.json key `elm-cem-facts`)* | `brands/m3e/generated/package/elm-m3e-facts/` **?** | **ambiguous** — see §8. v2 names a *per-brand* `elm-m3e-facts`, but today facts is one shared `elm-cem-facts` substrate package. Per-brand facts pkg vs. shared facts pkg is an open design fork. |
| `brands/m3e/outputs/tailwind-m3e-web/` | `brands/m3e/generated/style/elm-m3e-tailwind/` | re-parent + rename (§8) |
| `brands/m3e/outputs/m3e-api-okf/` (pkg name still `m3e-okf`) | `brands/m3e/generated/okf/elm-m3e-okf/` | re-parent + rename `m3e-api-okf`→`elm-m3e-okf` |
| *(no docs package today — docs live inside `elm-m3e/docs/`)* | `brands/m3e/generated/docs/elm-m3e-docs/` | **extract docs site to its own slot** (§5) |

### 1c. The m3e brand inputs

| Current | v2 proposed | Change |
|---|---|---|
| `brands/m3e/inputs/cem/config/*.json` (10 files) + live-resolved `@m3e/web/dist/custom-elements.json` | `brands/m3e/inputs/{custom-elements-manifest.json, elm-cem-config.json}` | flatten `cem/config/*` → two named files (v2 shows a *single* CEM file + single config; today it's 10 config JSONs) — see §8 |
| `brands/m3e/inputs/material-okf/` | `brands/m3e/inputs/material-okf/` | unchanged (v2 keeps `material-okf` under inputs) |
| `core/tonal-palette-oklch/` | `brands/m3e/inputs/tonal-palette-oklch/` | re-classify (see §1a) |
| *(no `material-okf`→`material-okf` distinction issue)* | v2 also lists `material-okf/` under `m3e/inputs/` | matches |

### 1d. Things in Jack's v2 tree that have **no clean current-day equivalent** (call-outs)

- **`pipeline/elm-cem-tailwind/`** — there is no standalone `elm-cem-tailwind` package today. The
  agnostic tailwind codegen (`generate-component-utilities.mjs`, `gen-facts.mjs`) was promoted to
  `tools/lib/` during "W6" (per session-handoff §5); the generic M3 color science is `core/tailwind-md3`;
  the brand-specific bridge is `tailwind-m3e-web`. So "a `pipeline/elm-cem-tailwind` package" would be
  a **new consolidation** of `tools/lib/` tailwind code into a real package — partly done, not a pure move.
- **`brands/*/generated/` layer** — no brand has a `generated/` grouping dir today; outputs sit
  directly under `outputs/`. v2 inserts `generated/{package,okf,style,docs}/` as an organizing tier.
- **`brands/html/`, `brands/svg/`, `brands/shoelace/`, `brands/web-awesome/`, `brands/etc/`** — none
  exist. Only `brands/m3e/` exists today. See §3 (html/svg) and the audit doc (shoelace/web-awesome seeds).
- **`brands/*/generated/okf/`** — v2 puts an `okf/` peer of `package/`; today OKF is split across
  `inputs/material-okf` (knowledge) + `outputs/m3e-api-okf` (API facts). v2's single `generated/okf/elm-m3e-okf/`
  collapses only the *output* half; the `material-okf` input stays an input. Consistent, minor rename.

---

## 2. The `-elements`/`-components` naming swap (Q2): **confirmed inversion, highest confusion risk**

**Confirmed reading — the inversion is real.** Verified current names:

| Tier (what it groups) | Current name | v2 name | Evidence |
|---|---|---|---|
| tag-grouped, per-component API | `M3e.Component.*` (module) / planned pkg `elm-m3e-components` | **`-elements`** | `src/M3e/Component/` dir; codegen `Generate/Phantom/Emit/Component.elm:646` emits `file [ lib, "Component", comp.name ]`; planned name in `packages.json:82` = `jackhp95/elm-m3e-components` |
| family-grouped re-exports | `M3e.Family.*` / pkg `jackhp95/elm-m3e-families` | **`-components`** | `elm-m3e-families/elm.json:3` name `jackhp95/elm-m3e-families`, module ns `M3e.Family.*` |

So under v2, the word **"components" changes meaning**: today it's the tag-grouped tier (`M3e.Component`),
in v2 it's the family-grouped tier (today's `-families`). And v2 introduces **"elements"** for what is
today called "components." This is a straight semantic swap of an already-shipped, already-published
vocabulary — the single highest grep-and-replace hazard in the whole reshape.

**Compounding subtlety — a *different*, already-planned split uses the OLD vocabulary.** There is a
`brands/m3e/outputs/elm-m3e/packages.json` that already encodes a planned explosion of the monolithic
`elm-m3e` into `elm-m3e-core`, `elm-m3e-html`, `elm-m3e-components` (tag-grouped), `elm-m3e-builder`.
Those planned names are **not yet live** (only `elm-m3e`, `elm-m3e-families`, `elm-m3e-icons` are real
packages today — verified via `find … -name elm.json`), but `elm-m3e-families/elm.json:37-38` already
lists `elm-m3e-core` + `elm-m3e-components` as *dependencies* tracking that planned state. **If the v2
rename lands, this pre-existing plan must be reconciled to it first** — otherwise the split ships with
`-components` meaning tag-grouped and the rename immediately re-inverts it. Flag loudly: these two
in-flight designs (the `packages.json` split and Jack's v2 naming) currently disagree on what
"components" means.

### 2a. Migration blast radius (enumerated, NOT executed)

A `-families`→`-components` and `-components`(tag)→`-elements` rename touches at minimum:

- **elm.json / packages.json / slots.json `name` fields:** `elm-m3e-families/elm.json:3`;
  `packages.json:82,107`; `brands/m3e/inputs/cem/config/slots.json:36-47` (lists both
  `jackhp95/elm-m3e-families` and `jackhp95/elm-m3e-components` — the `_families` block that Track B
  confirmed is the real family source, per `2026-08-19-multi-track-fix-batch-plan.md:15`).
- **Elm module namespaces (source-wide):** `M3e.Component.*` → new tag-grouped name — **~4,977 grep
  hits** across src/docs/samples/review/codegen (the `src/M3e/Component/` dir alone is ~130 files);
  `M3e.Family.*` → `M3e.Component.*` — **591 references** outside the families source. (Most of the
  4,977 are in *generated* files that regenerate — the real edit is the codegen emitter, not the
  files.)
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
  hard version-cascade break (VISION.md "Deep seams only"). **Recommendation: do this rename, if at all,
  as part of the same release that first splits the packages — never as a standalone churn release.**

**Recommendation:** the `-elements`/`-components` names are *better* (elements=tag, components=families
reads more naturally), but the inversion is dangerous precisely because the old word is reused with new
meaning. If adopted: (1) reconcile `packages.json`'s planned names to v2 first, (2) drive it entirely
from the codegen emitter + config, (3) land it atomically with the package split, (4) write a one-page
"the word 'components' now means X" migration note pinned in the brand README and VISION.md.

---

## 3. `html`/`svg` as brands vs. shared substrate (Q3): **html is already a brand; svg is aspirational; the IR is the real substrate**

The session-handoff framed `elm-typed-html` + `elm-html-intermediate-representation` as "shared
substrate." Investigation shows that's **half right, and the half that's wrong is important:**

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

→ **Moving `elm-typed-html` to `brands/html/{inputs/cem/{manifest,config}, generated/package/...}` is a
pure structural relocation matching the m3e shape — no pipeline work.** Jack's v2 framing of `html/` as a
full brand describes what already exists. The one caveat: today `elm-typed-html` is a *single* generated
package (not yet exploded into `-core`/`-elements`/`-components`/`-build`), same as elm-m3e — so v2's
per-brand `generated/package/{...}` set for html is the *same* explosion work as for m3e, times two.

**`elm-html-intermediate-representation` is NOT a brand — it's the Tier-0 substrate.**
- `core/elm-html-intermediate-representation/README.md:8`: "This is the **only hand-rolled package in
  the system**. Everything delivered above it is config-generated." It provides `HtmlIr.{Element,Node,
  Attribute,Value,Kind}` + fenced `HtmlIr.Internal`; both `TypedHtml` and `M3e` import it as an ordinary
  dependency (confirmed: `M3e.Build.Button` imports `HtmlIr.Element as El`, see §4).

→ This maps **exactly** to Jack's proposed top-level `packages/elm-virtual-dom-intermediate-representation/`
— it is genuinely brand-agnostic, genuinely foundational, and genuinely "nothing to do with elm-cem
directly." Recommend adopting v2's placement (top-level `packages/`, out of both `core/`/`pipeline/` and
`brands/`). The rename IR→virtual-dom-IR is fine but cosmetic.

**`svg` is architecturally coherent but does NOT exist and is blocked on an IR additive.**
- Zero SVG anything today: no `elm-typed-svg` pkg/dir, no SVG CEM manifest, no SVG brand config (grep
  for `TypedSvg`/`elm-typed-svg`/svg brand → 0 hits).
- Hard blocker: `HtmlIr.Node` has **no namespaced-node constructor**; the IR README explicitly lists
  "Namespaced (SVG) nodes/attributes" under "Deliberately deferred." An SVG brand cannot be generated
  until the IR grows namespaced nodes.

→ **Recommendation & sequencing for svg:** (1) additive to `elm-virtual-dom-ir` — namespaced nodes/attrs;
(2) author an SVG CEM manifest from the SVG spec (the same way `native.cem.json` was authored from the
WHATWG HTML spec); (3) then the SVG brand generates through the existing pipeline for free. Treat
`brands/svg/` in the v2 tree as **aspirational/roadmap**, not a near-term relocation. Do not scaffold its
`generated/package/` set until (1) and (2) land.

**Net for Q3:** v2's instinct is sound — html genuinely is a brand and belongs in `brands/`. But the doc
should distinguish: `brands/html/` = relocate-existing (easy), `packages/elm-virtual-dom-ir/` =
relocate-existing substrate (easy), `brands/svg/` = new capability behind an IR additive (a mini-project,
not a move). This also directly informs the open "prove brand-pluggability with a second real brand" item
— html already *is* that second brand, quietly.

---

## 4. Does builder depend on core when it should depend on elements? (Q4): **no bug — builder already depends on elements**

**Direct answer: builder correctly imports the elements (tag-grouped) tier today, not a core tier.**
There is no standalone `-build` package yet — `M3e.Build.*` is inline in the monolithic
`jackhp95/elm-m3e`. Reading an actual builder module, `brands/m3e/outputs/elm-m3e/src/M3e/Build/Button.elm:19-31`:

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

**When the planned split executes** (`packages.json:91-93,112-118`): `elm-m3e-builder` → depends on
`elm-m3e-components` (tag-grouped) + `elm-m3e-html` (shared utils); `elm-m3e-components` → depends on
`elm-m3e-html`. So the *planned* graph already has builder depending on the elements tier + a thin
html/util tier — **exactly what Jack wants.** Jack's worry ("does builder depend on core when it should
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
`NoFamilyMemberDrift`). **Recommend adding that rule as part of the split**, so the invariant Jack cares
about is enforced, not just asserted.

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
  docs at build time. **This is the single biggest untapped "fact/OKF-informed markup" opportunity Jack
  asked about.**

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

### Recommendation (opinionated, not "it's possible")
1. **Generate (high ROI, low risk):** `Route.Family` from `slots.json`; `Route.Styles/` token tables from
   the token manifest; `Installation` version/name strings from package metadata. All eliminate real drift.
   The per-component reference + examples are already generated — leave them.
2. **Markdown-ify the guide prose (ergonomics, not generation):** the 13 guide chapters should move from
   Elm string literals to `.md` files read via `BackendTask.File.rawFile`. **The infra already exists** —
   `docs/guides/` already holds 4 markdown files (`EnumSafety.md`, `Glossary.md`, `Seams.md`,
   `TheLayers.md`). This makes prose diffable without Elm tooling and reusable by the OKF/skill sets —
   directly answering Jack's "can hardcoded pieces become accessible markdown?" **Yes, and it's half-done.**
3. **Do NOT fully generate.** Guide chapters are the product's voice; the OKF cross-refs should stay links,
   not data sources. Full generation is a bad idea for the prose specifically.
4. **v2 shape implication:** `brands/m3e/generated/docs/elm-m3e-docs/` is coherent for the *generated*
   surface (reference/examples/family/token pages) + the compose editor. But the hand-authored guide
   markdown is **not "generated"** — it's brand-authored input. Suggest the docs package internally split
   `generated/` (from facts) vs `authored/` (markdown guides) so the `generated/docs/` label stays honest.
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
(it already reads `family.json`), not a turbo/nx adoption. Note it in the v2 plan as a scaling item.

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
  *core*, not these brand repos.
- **`elm-cem-template`** (187 Elm files, full CI/review scaffold, name `jackhp95/elm-your-library`) is the
  canonical **new-brand bootstrap** — relevant because adopting the 5 repos above should be
  template-driven and repeatable, and because it's what a `brands/_template/` slot instantiates.
- **`matraic-m3e`** is the upstream `@m3e/web` source library (JS/TS, zero Elm) — a *dependency* of
  `brands/m3e/inputs`, not a brand slot. Keep separate.
- **Dead weight (archive/delete):** `m3e-builder` (empty), `elm-geo-ip` (empty), `elm-material` (CSS
  scratch), `elm-events` (demo shell), `matraic-m3e-wt` (dangling worktree), `provcore-worktrees` (empty),
  `animal-spirits-eyg-spike` (orphaned spike).
- **No duplicates of workspace content** among the spot-check repos — consolidation was clean.
- **`elm-dom-decode`** — useful standalone Elm util with no current workspace home; needs Jack's call
  (adopt into `core`/`pipeline`/top-level `packages`, or leave standalone).

**Bearing on the v2 shape:** the existence of 5 real brand repos strongly validates the `brands/<name>/`
generalization — but it also means the `-elements`/`-components` naming (§2) and the
`generated/package/{...}` explosion (§1b) should be **settled before** migrating them in, or you migrate
5 repos into a layout that then changes under them. Recommend: settle spec → adopt one (`elm-shoelace`,
smallest) as the pluggability proof and shape shakedown → batch the rest.

---

## 8. Open questions for Jack (genuine ambiguity — NOT silently resolved)

1. **Three-way `tailwind` naming conflict (highest-priority decision).** Three names are in play for
   what may be *two different things*:
   - current package `tailwind-m3e-web` (brand-specific `@m3e/web` sys-token bridge),
   - VISION.md's 2026-08-17 suggestion `elm-cem-tailwind` (the agnostic codegen),
   - today's v2 message names **both** `brands/m3e/generated/style/elm-m3e-tailwind/` (brand output)
     **and** `pipeline/elm-cem-tailwind/` (agnostic machinery).
   The current single `tailwind-m3e-web` package still conflates the agnostic codegen (already promoted to
   `tools/lib/` in W6 + `core/tailwind-md3`) with the hand-authored M3-specific `sys/*.css`. **Question:
   is the v2 intent to formally split into `pipeline/elm-cem-tailwind` (agnostic, consolidating
   `tools/lib/` tailwind code) + `brands/m3e/generated/style/elm-m3e-tailwind` (brand `sys/*.css`)? And is
   the brand half named `-tailwind` even though it's partly hand-authored, not generated?** I did not pick
   one.

2. **`elm-m3e-facts`: per-brand or shared substrate?** v2 lists a per-brand `elm-m3e-facts` under
   `brands/m3e/generated/package/`. Today facts is a *single shared* `elm-cem-facts` package
   (`core/elm-cem/facts/`, family.json key `elm-cem-facts`) imported by every brand and by
   `elm-cem-compose`. Is v2 asking for the facts *types* to stay shared (in `packages/` or `pipeline/`)
   with only the *brand's generated facts values* (`M3e.Review.Facts`) living in `elm-m3e-facts`? Or a
   genuine per-brand facts *package*? These are very different (the former is a rename of the generated
   module's home; the latter forks the shared substrate). Recommend: shared facts *contract*, per-brand
   generated facts *data* — but confirm.

3. **`tonal-palette-oklch`: core/pipeline substrate or m3e brand input?** Today it's `core/tonal-palette-oklch`
   (generic OKLCH color science, used by `tailwind-md3`). v2 lists it under `brands/m3e/inputs/`. It is
   **not** m3e-specific (it's generic color math) — putting it under `brands/m3e/inputs/` would make a
   future `brands/carbon/` unable to reach it without depending on m3e. **Recommend keeping it agnostic
   (top-level `packages/` or `pipeline/`), not under `brands/m3e/`** — but v2's tree explicitly nests it,
   so flagging rather than overriding.

4. **`-elements`/`-components` inversion — confirm you want the word "components" to change meaning**
   (§2). It reads better, but reuses a shipped, published word with new semantics and breaks external
   consumers (`buildoc`). Confirm, and confirm it lands atomically with the package split, not as its own
   churn release. Also: reconcile the pre-existing `packages.json` planned split (which uses the *old*
   `-components`=tag-grouped meaning) to the new naming first.

5. **`core/` vs `pipeline/` rename.** v2 renames the machinery dir `core/`→`pipeline/` and moves the IR
   out to top-level `packages/`. The `core/`+`brands/` reorg landed *today* (2026-08-19) with a full
   path-inventory. Renaming `core/`→`pipeline/` immediately re-breaks all those same paths again
   (`tools/family.json` srcDirs, `gate-all.mjs`, `bump.mjs`, ~20 tool files enumerated in
   `2026-08-18-core-brands-workspace-reorg-plan.md`). **Worth it, or keep `core/`?** The names are close
   in intent ("brand-agnostic machinery"). If renaming, batch it with the brand-output explosion so the
   path churn happens once, not twice. (This is the "path breakages as forcing function" Jack mentioned —
   real, but the today-reorg already paid much of that cost; a second immediate rename is mostly re-tax,
   not new discovery.)

6. **`brands/m3e/inputs/` flattening.** v2 shows a single `custom-elements-manifest.json` +
   `elm-cem-config.json` per brand. Today m3e has `inputs/cem/config/*.json` (10 files:
   `categories.json`, `examples.*.json`, `slots.json`, `icons*.json`, `native-mdn.json`, etc.) and the CEM
   is resolved *live* from the installed `@m3e/web` npm package (not a committed file — per
   `2026-08-18-core-brands-workspace-reorg-plan.md` §4). Does v2 want these 10 configs collapsed into one
   `elm-cem-config.json`, and the live-resolved CEM committed as a file? Both are behavior changes, not
   moves.

7. **Standalone `-build` package split — scope.** No `-build` package exists today (`M3e.Build.*` is inline
   in `elm-m3e`). v2's `generated/package/elm-m3e-build/` requires the full 5-package explosion of the
   monolith. The `packages.json` planned split is the starting point but is (a) not executed and (b) named
   with the old vocabulary. Confirm the explosion is in-scope for the v2 reshape (it's a large, separate
   effort from the directory reshape itself).

8. **Which brands are near-term vs. roadmap?** `svg` is blocked on an IR additive (§3). `shoelace`/
   `web-awesome`/`calcite`/`fluent-ui`/`warp` exist as adoptable repos (§7). `etc/` is open-ended. Confirm
   the v2 tree's brand list is "target end-state" (aspirational) vs. "build these now" — this determines
   whether the plan scaffolds empty brand dirs or only the ones with real content.

---

## Appendix — scope guardrails honored in this research

- **No code, no moves, no renames.** Only these two docs written. Verified `find`/`grep` for every
  structural claim; agent findings cross-checked against first-hand greps (family.json keys, elm.json
  names, pnpm-workspace globs, elm-m3e tier dirs).
- **Did not touch** the 3 pending-merge worktrees (`.claude/worktrees/agent-{a8e48485eed5250b1,
  adf03debc8e3b774c,ae099ba76362fbf0d}`) — their content treated as "pending, not yet on main."
- **Did not touch** any `jackhp95/<name>` GitHub mirror.
- **The execution plan is deliberately absent** — per Jack's framing, planning is the next, separate step.
