# html 5-tier follow-up plan — Components + Build for `elm-typed-html`

**Status:** planning only. No code, config, or generated output was changed to produce this document.
Every file:line citation below was re-derived from the current worktree tip (branch
`worktree-agent-a77bf66aa597d3e23`, descended from `main` post `34c4786f`) by directly reading the
cited files — not copied from the hand-off summary that commissioned this doc. Several of that
hand-off's claims did not survive verification; see "What the FU-1 hand-off got wrong" below.

**Commissioned by:** `docs/plans/2026-08-21-dag-rework-plan.md`'s Task 9 follow-up note (**FU-1**,
lines ~542–585), itself downstream of the reconciliation plan's OQ-5 ("html stays 3 tiers this pass, 5
is the confirmed future target"). **Style/structure mirrors:** `docs/plans/2026-08-20-reconciliation-plan.md`
and `docs/plans/2026-08-21-dag-rework-plan.md`.

**Expected model tier (informational):** this planning pass → opus at high (per Jack's tick-down
policy, run one tick down from the suggested fable/xhigh design tier). Execution, if approved → opus at
medium, sonnet workers for mechanical regeneration/verification steps, matching the DAG-rework plan's
own tiering.

---

## The crux, in one line

FU-1 claimed the DAG rework's `BuildPackage.elm` emitter is now "a general, brand-agnostic capability"
that would, "with no new generator code," produce `TypedHtml.Build.*` the moment html gains a
`_families` config. **This is false as verified against the live emitter.** `BuildPackage.elm` and its
sibling `FamilyPackage.elm` both gate their entire output on `homeOf comp == Nothing` — the exact same
"own vs. home" split `Emit.elm` uses to route components to two **structurally disjoint** rendering
pipelines. html's entire 112-element population is 100% home (every element in
`brands/html/inputs/config.json` carries a `"home"` field), so today's emitter produces **zero** output
for html no matter what composition config you hand it. Standing up html's Components/Build tiers is
therefore a **generator design task**, not a config-only follow-up — closer in shape to the DAG rework
itself than to a mechanical materialization pass. This plan's recommendation (below) is also narrower
than a literal m3e clone: html's native element constructors already deliver most of what m3e's
Components/Build split was invented to add, so this plan recommends a **smaller, semantically honest**
target rather than forcing tier-count parity for its own sake.

---

## Read before Task 0 — verified current state (the problem, precisely)

### 1. What FU-1 got right

- `pipeline/elm-cem/codegen/Generate/Phantom/Emit/BuildPackage.elm` (1352 lines) is real,
  shipped, brand-agnostic **machinery** — no m3e/shoelace hardcoding in its naming or member-struct
  algorithm (lines 82–99, `Member`/`typeRef`/`valueRef`/`expType`/`expValue`). Shoelace does ride it
  (its builders emit as degenerate single-member families — confirmed, see §6 below for an update on
  shoelace's current package shape).
- html's 3-tier ceiling (`elm-typed-html-{facts,core,elements}`) genuinely was, at explosion-Task-4
  time, "because html is a home-only brand and no Build/components tier existed to split" — this
  framing is accurate and is independently corroborated in-repo (see next section).

### 2. What FU-1 got wrong / had to be corrected (the real blocker)

**`Emit.elm` routes components to two disjoint rendering pipelines, keyed on `homeOf`:**

```
pipeline/elm-cem/codegen/Generate/Phantom/Emit.elm:140-141
    ++ List.concatMap (\comp -> [ internalTypesModule brand comp, compModule brand comp ]) own
    ++ List.map (homeModule brand) homeGroups
```

- `own` comps (`homeOf comp == Nothing`) → `Component.elm`'s `compModule`/`componentCore`: a
  **slot + attrs-row Builder pipeline** (`B.init |> B.withAttribute |> B.withChild |> B.toElement`,
  named-slot placers) built for Lit custom elements that stamp `slot="x"` attributes on children.
- `homeGroups` (`homeOf comp /= Nothing`) → `Home.elm`'s `homeModule`: a **kind-row phantom
  composition-validity** constructor, `List (Attr Attrs msg) -> List (Element childAccepts admittedBy
  msg) -> Element producesRow admittedByRow msg` — no slots, no Builder type, ordered children checked
  structurally via row-polymorphic type parameters. Verified against real generated output, e.g.
  `brands/html/generated/package/elm-typed-html-elements/src/TypedHtml/Element/A.elm:105-110` and
  `.../TypedHtml/Element/Grouping.elm:69-74` — every function is `elementName attrs children =
  Ir.fromNode (Ir.node "tag" attrs ...)`, never a `Builder`.

`homeOf` itself: `pipeline/elm-cem/codegen/Generate/Phantom/Emit/Shared.elm:205-217` — `Just h` when the
component declares a `home`, or is `transparent`/has `roles` and falls back to its own name; `Nothing`
only for genuine "own module" custom elements.

**Both the Components-tier and Build-tier emitters hard-gate on this same `homeOf` split — not just as
an implementation default, but as an unconditional kill-switch:**

- `BuildPackage.elm:1293-1296` (`files`): `hasBuilders = not (List.isEmpty (brand.comps |> List.filter
  (\c -> homeOf c == Nothing)))` — **if every comp in the brand has `homeOf /= Nothing`, `files` returns
  `Ok []` regardless of any `_families` config.** html satisfies exactly that condition.
- `BuildPackage.elm:762-826` (`resolveAllFamilies`/degenerate expansion) and `:1116` (barrel rendering)
  independently re-apply `homeOf c == Nothing` to decide which comps ever reach the Builder-pipeline
  renderer at all.
- `FamilyPackage.elm:793-826` (`degenerateElements`, the split-brand Components-tier façade generator)
  applies the **identical** `homeOf c == Nothing` filter for its own degenerate-façade expansion.
- `FamilyPackage.elm:641-669` (`resolveMember`) calls `Component.compSurface brand comp`
  (`Generate/Phantom/Emit/Component.elm:21-65`, `ComponentSurface`/`ComponentCore`) — the SAME
  `componentCore` that renders `own`-comp slot/Builder decls. It has no code path for a `homeOf /=
  Nothing` comp's fields (`Attrs`-as-kind-row, `ChildAdmittedBy`, `AdmittedBy`, `Is`) at all; it would
  either crash or silently produce garbage if pointed at a home comp — it is not merely gated, it is
  **the wrong data shape**.

This is independently corroborated by a note already in the tree that FU-1's optimistic framing
apparently didn't cross-check: `brands/html/generated/package/elm-typed-html/packages.json:5`
(`$scopeNote`) states plainly: *"html is a home-only brand (Emit.elm: own=[], all 16 TypedHtml.Element.*
are HOME modules ... No Build/components tier is derivable — real ceiling is 3 tiers."* Two documents in
this repo directly contradict each other (FU-1's "no new generator code" vs. this scopeNote's "no
Build/components tier is derivable"); I verified the code and the scopeNote is correct, FU-1 is not.
**Logged as a friction** (see Friction note).

### 3. html's actual element population (also miscounted in the commissioning brief)

The commissioning brief said "html only has 16 home elements." Verified count against
`brands/html/inputs/config.json` (112 top-level component entries, all with a `"home"` field, zero
without):

| home group   | count | members (exact, machine-verified against `brands/html/inputs/config.json`) |
|--------------|------:|---------|
| Text         | 32    | Abbr, B, Bdi, Bdo, Br, Cite, Code, Data, Del, Dfn, Em, I, Ins, Kbd, Mark, Meter, Progress, Q, Rp, Rt, Ruby, S, Samp, Small, Span, Strong, Sub, Sup, Time, U, Var, Wbr |
| Sectioning   | 17    | Address, Article, Aside, Body, Footer, H1, H2, H3, H4, H5, H6, Header, Hgroup, Main, Nav, Search, Section |
| Grouping     | 15    | Blockquote, Dd, Dialog, Div, Dl, Dt, Figcaption, Figure, Hr, Li, Menu, Ol, P, Pre, Ul |
| Table        | 10    | Caption, Col, Colgroup, Table, Tbody, Td, Tfoot, Th, Thead, Tr |
| Embedded     | 6     | Area, Canvas, Embed, Iframe, Map, Object |
| Media        | 6     | Audio, Picture, Source, Track, Video, PictureSource |
| Metadata     | 6     | Base, Head, Link, Meta, Style, Title |
| Form         | 5     | Fieldset, Form, Label, Legend, Output |
| Select       | 4     | Datalist, Optgroup, Option, Select |
| Scripting    | 4     | Noscript, Script, Slot, Template |
| Details      | 2     | Details, Summary |
| A, Button, Img, Input, Textarea | 1 each | single-member homes |

Total: 32+17+15+10+6+6+6+5+4+4+2+5 = 112, matching the top-level component-entry count. 16 distinct
home names total — this is what the brief's "16" actually refers to: 16 **home groups**, i.e. the 16
files under `brands/html/generated/package/elm-typed-html-elements/src/TypedHtml/Element/`, not 16
elements.

**Key structural fact:** html's 16 "home" groups are **content-model taxonomies** (which elements share
an HTML content category, e.g. "phrasing content" → Text), not **composite widgets**. Unlike m3e's
families (Accordion+AccordionItem, NavMenu+NavMenuItem+NavMenuItemGroup — a root widget with
structurally-related parts), most home-group members have **no relationship to each other** beyond
sharing a spec category (e.g. `Text` co-locates `Abbr`, `Kbd`, `Time`, `Wbr` — nothing connects them).
Genuine parent/child composite structures **do** exist in HTML, but they cut across the home taxonomy:

| candidate family | root    | members                                              | home(s) they actually live in |
|------------------|---------|-------------------------------------------------------|--------------------------------|
| Table            | Table   | Caption, Colgroup, Col, Thead, Tbody, Tfoot, Tr, Td, Th | Table (all 10, clean 1:1) |
| Select           | Select  | Optgroup, Option, Datalist                            | Select (all 4, clean 1:1) |
| Details          | Details | Summary                                               | Details (both, clean 1:1) |
| Dl               | Dl      | Dt, Dd                                                | Grouping (subset — Grouping also has 12 unrelated singles) |
| Picture          | Picture | Source, **Img**                                       | Media (Picture, Source) + Img's own single-member home — **cross-home** |
| List (rejected)  | —       | Ol, Ul, Menu, Li                                      | Grouping — **rejected**, see OQ-H3 |

The last two rows are genuinely awkward fits for the `_families` schema's root+members model (a
component belongs to at most one family): `Source` is a child of **both** `<picture>` and
`<video>`/`<audio>` in the spec, and `Li` is a child of **three** independent parents (`ol`, `ul`,
`menu`). This is flagged as an open question (OQ-H2/OQ-H3), not silently resolved — see below.

### 4. Why the Builder-pipeline's value proposition doesn't transfer to native HTML

`BuildPackage.elm`'s header (lines 1-34) is explicit about what the Build tier is FOR: hiding Lit custom
elements' **named-slot mechanics** (`slot="x"` attribute stamping) behind a typed pipeline
(`B.withChild`, per-slot placer functions like `itemBadge`) so slot placement type-checks. That is a
real capability gap for m3e/shoelace's custom elements, which have finite, named slots.

Native HTML elements have **no slot mechanic at all** — children are one ordered list, and their
validity is checked by the row-polymorphic `childAccepts`/`admittedBy` type parameters already present
on every `Element` constructor (confirmed in the generated code cited in §2). A `Builder` pipeline needs
its accumulator type to **erase** to one monomorphic `Builder msg` as you pipe through it — but erasing
html's `childAccepts`/`admittedBy` row polymorphism is precisely what would **destroy** the compile-time
content-model checking that is html's entire reason for existing as a phantom-typed library. Concretely:
`div : List (Attr DivAttrs msg) -> List (Element childAccepts (DivChildAdmittedBy childAdm) msg) ->
Element (DivIs s) admittedBy msg` (`Grouping.elm:276-281`) is **already** the ergonomic, single-call
"build" API — it is the same shape `elm/html` uses, and there is no missing capability for a Builder
pipeline to add. This is the load-bearing reason this plan recommends **not** building a new
Builder-pipeline emitter for html (Option A below), rather than recommending it as future work that
"just hasn't been done yet."

### 5. Package-split precedent has moved since the DAG-rework plan was written

The DAG-rework plan's blast-radius table (lines 246-263) recorded shoelace as staying a **monolith**
with an added Build tier ("no packages.json split to touch"). That is now stale: `tools/family.json:153-179`
shows shoelace has **five** committed split siblings today — `elm-shoelace-{core,elements,components,
build,facts}` — with the registry-cap note explaining why (`tools/family.json:158`, `$comment_elm_shoelace_split_siblings`):
*"The monolith's docs.json blew the 700 KB registry cap (947,500 B / 135.4%) once the DAG rework added
the 58-module degenerate `Sl.Component.*` facade tier; the split resolves it structurally."* The 700 KB
(768,000 B) hard cap is a real, enforced Elm package-registry limit
(`tools/measure-docs-size.mjs:41`, `pipeline/elm-cem/bin/eject.js:5`, `pipeline/elm-cem/bin/validate.js:9-13`).

**This matters for html directly:** html has 112 elements — nearly double shoelace's ~59 builders that
blew the cap. If html's Components tier were forced into the existing monolith-shaped `elm-typed-html`
package (or even into `elm-typed-html-elements`) rather than split from day one, it would very plausibly
blow the same 700 KB cap once every home's degenerate façade is added. **This is independent, concrete
evidence for splitting html's Components tier into its own package from the start**, on top of the
architectural reasoning in §4 below.

---

## Target architecture (recommendation)

**Recommendation: Option A — semantically-scoped Components tier, package-split from day one, no new
Build/Builder-pipeline tier.**

- **Components tier:** a new sibling package `elm-typed-html-components` (module namespace
  `TypedHtml.Component.*`, matching m3e's post-Task-7 naming convention), containing **only the
  genuine structural composite families** — `Table`, `Select`, `Details`, `Dl`, and (pending OQ-H2)
  `Picture`. This is 4-5 families covering ~15-17 of html's 112 elements. The remaining ~95-97 elements
  are **not** promoted to degenerate single-member "families" — unlike m3e/shoelace, there is no
  existing per-element Builder surface to preserve 1:1 for them (see §4: they never had one), so
  the "every element keeps its builder" motivation for shoelace's blanket degenerate-expansion
  (`BuildPackage.elm:762-768`) does not apply. They stay exactly where they are today, in
  `elm-typed-html-elements`.
- **Build tier: not built.** Recorded as a **closed, evaluated non-goal** (with rationale — §4), not a
  silent deferral. If Jack disagrees after reading this plan, Option A′ (below) is the literal-parity
  fallback and is scoped as an explicit alternate path, not hand-waved.
- **5-tier language:** given the above, "5 tiers" for html should be read as "facts, core, elements,
  components, **(build intentionally absent)**" rather than a literal 5-package materialization — this
  plan proposes html top out at **4 real packages** unless Jack overrides via OQ-H1.
- **New generator primitive required:** neither `FamilyPackage.elm` nor `BuildPackage.elm` can render a
  home comp's surface (§2). This plan's Task 1 is a **new** `homeSurface`-style extraction (a sibling to
  `Component.compSurface`, reading `Home.elm`'s per-member `Attrs`/`Is`/`ChildAdmittedBy`/`AdmittedBy`
  aliases and constructor instead of Component.elm's slot/Builder decls) plus a **new** flat
  family-façade renderer that re-exports a family's members' home-derived surface under
  member-prefixed names — analogous to `FamilyPackage.elm`'s `generateFamilyModule`, but sourced from
  the home rendering path, not the own-comp one. This is genuinely new generator code, on the order of
  a few hundred lines, not a config flip.

### Option A′ — literal parity fallback (rejected as default, kept as an explicit alternative)

If Jack wants tier-count parity with m3e regardless of the §4 argument: promote **all 16 home groups**
to `_families` entries (degenerate multi-member "families" with no real root, just co-located re-export
— this is close to what home modules already are), and add a **thin `Build` tier** that is a pure
re-export/rename layer over Components (no new Builder-pipeline mechanics, no `B.init`/`withChild`) —
i.e. `TypedHtml.Build.<Home>` modules that just alias `TypedHtml.Component.<Home>`'s surface. This adds
tier-count parity and an extra import path, at the cost of a tier that adds zero real capability (per
§4) and a materialization/consumer-migration cost with no corresponding user benefit. **Not
recommended**, but scoped fully enough to execute if Jack picks it (see Task 9's disposition record,
which forces an explicit go/no-go rather than letting this decay into an implicit default).

### Option B — full Builder-pipeline for kind-row types (rejected)

Retrofit `BuildPackage.elm`'s Builder-pipeline mechanics to preserve html's row-polymorphic
`childAccepts`/`admittedBy` types through a `B.init |> B.withChild |> B.toElement` chain. This is
**real generator R&D**, larger in scope than the DAG rework this plan follows up on, for a capability
(§4) that native HTML does not need. **Rejected** — recorded here so it isn't silently reinvented later
without this reasoning being re-litigated.

### Option C — do nothing (rejected)

Leave html at 3 tiers indefinitely. Rejected because it contradicts Jack's recorded direction (OQ-5:
"5 is the confirmed future target") and because §5's registry-cap risk means html's Components-tier
question will resurface regardless — better to resolve it deliberately now than reactively later.

---

## Migration path / blast radius

| area | current state | change | risk |
|------|----------------|--------|------|
| `pipeline/elm-cem/codegen/Generate/Phantom/Emit/Home.elm` | renders `homeModule` (kind-row, no surface-extraction helper) | add `homeSurface`-style extraction (new function, additive) | low — additive, no existing renders touched |
| `pipeline/elm-cem/codegen/Generate/Phantom/Emit/FamilyPackage.elm` | `compSurface`-only façade generation | new code path for home-sourced members (or a new sibling module, `HomeFamilyPackage.elm`) | medium — touches a shared, already-complex module; prefer a new sibling file per this repo's "smaller focused files" convention |
| `brands/html/inputs/config.json` | no `_families` key | add `_families` block (lib=`TypedHtml`, namespace=`Component`, 4-5 families) | low — pure config addition, no existing keys touched |
| `brands/html/generated/package/elm-typed-html/packages.json` | 3 packages (facts/core/elements) | add `elm-typed-html-components` package + bucket | medium — new sibling, existing 3 buckets untouched |
| `tools/family.json` | `elm-typed-html{,-core,-elements,-facts}` entries only | add `elm-typed-html-components` entry (mirroring m3e's `elm-m3e-components` shape, `family.json:96-106`) + `authorizedAbsentPrefixes`/`authorizedExtra` bookkeeping during the transition (mirroring `family.json:54-55`'s mirror-lag pattern) | low — additive registry entries |
| `tools/check-package-dag.mjs` | hardcoded `brands` array covers only `m3e`, `shoelace` (`check-package-dag.mjs:40-59`) — **not actually brand-agnostic today**, contra FU-1's framing | add an `html` entry once html has a Components tier to assert | low-medium — the gate script itself needs a manual edit; not automatic |
| consumers (docs, examples, any hand-authored code importing `TypedHtml.Element.{Table,Select,Details,Dl,Picture}` types) | import element-tier types directly | new `TypedHtml.Component.*` import path becomes available; **existing `TypedHtml.Element.*` imports keep working unchanged** (this is additive, not a rename — unlike m3e's Task 7 Component→Element rename, html needs no rename since it never had a colliding `Component` namespace) | very low — purely additive surface |
| `docs.json` registry size | `elm-typed-html-elements`'s docs.json today (not yet measured in this pass — Task 0 must measure it) | components package's own new docs.json | unknown until measured — **Task 0 must run `elm-cem validate` on the current html packages** to get a real baseline before any generator work, given §5's cap risk |

**No rename, no removed surface — this whole plan is additive.** That is the single biggest
risk-reducer relative to the DAG rework's own m3e Task 7 (Component→Element rename), which was that
plan's largest blast-radius item. html has nothing analogous to rename.

---

## Open questions (for Jack — real forks, not blanket TBDs)

- **OQ-H1 — Which option ships: A (recommended, no Build tier), A′ (literal parity, thin Build), or B
  (full Builder-pipeline R&D)?** This plan's task breakdown below executes Option A. If Jack picks A′ or
  B, Task 1 and Task 4 need re-scoping (A′ is a smaller re-scope; B is effectively a new plan). Default
  if no response within this gauntlet loop: **proceed with Option A** per the autonomy policy (best
  judgment, don't stall) — but Task 9 forces an explicit recorded disposition before any package
  materialization ships, so this is cheap to override later.
- **OQ-H2 — `Source` is a child of both `<picture>` and `<video>`/`<audio>`; `_families` can only claim
  it once.** Recommendation: claim it under `Picture` (the more common, more clearly "composite"
  relationship) and leave `Audio`/`Video`/`Track` as plain elements-tier members with no family. If Jack
  disagrees, swap the claim or drop `Picture` from the family list entirely (falls back to 3 families:
  Table/Select/Details/Dl).
  Note that html's overall CEM component naming has a legacy artifact worth flagging here too: the
  config's `home: "Media"` group includes an entry literally named `PictureSource` alongside `Source`
  (`brands/html/inputs/config.json` — verified via the Python enumeration in §3) — confirm whether that
  is a duplicate/legacy alias before wiring the `Picture` family's members list, so the family doesn't
  end up referencing a dead or aliased component name.
- **OQ-H3 — `Ol`/`Ul`/`Menu`/`Li`: `Li` has three parents, `_families`' root+members schema assumes one.**
  Recommendation: do **not** force a "List" family — leave all four as plain elements-tier members, same
  as today. This is the one candidate composite this plan actively recommends **against** promoting,
  with the reasoning stated in §3's table. Flagged for Jack to veto if there's a use case this plan
  isn't seeing (e.g. some docs/example code that would benefit from a `TypedHtml.Component.List` façade
  despite the multi-parent mismatch).
- **OQ-H4 — Namespace: `TypedHtml.Component.*` (matches m3e's current, post-rename convention) vs. some
  html-specific name (e.g. `TypedHtml.Widget.*`) to avoid any future collision if html ever grows real
  "own" custom-element-like components (it doesn't today, and isn't expected to — html is closed by
  definition).** Recommendation: `TypedHtml.Component.*` for cross-brand consistency; low stakes either
  way given html can't plausibly grow "own" comps.

---

## Gauntlet-shaped task breakdown

### Task 0: Baseline — measure current registry size + identity guard

- [ ] **Step 0.1** Identity guard: confirm `git config user.name` == `JackHP95` and `git config
      user.email` == `git@jackhpeterson.com` (locally or via global fallback) before any commit.
- [ ] **Step 0.2** Run `node pipeline/elm-cem/bin/elm-cem.js validate --src=<html elements src>
      --packages=brands/html/generated/package/elm-typed-html/packages.json` (or the equivalent
      `elm-cem validate` invocation the repo's `package.json` scripts use for html today — confirm the
      exact script name via `brands/html/*/package.json` before running) and record the current
      `elm-typed-html-elements` docs.json byte size against the 768,000 B hard cap
      (`tools/measure-docs-size.mjs:41`).
- [ ] **Step 0.3** Save the baseline output for the final diff (mirrors DAG-rework Task 0's pattern,
      `docs/plans/2026-08-21-dag-rework-plan.md:331-341`).

**Acceptance:** baseline docs.json size recorded; identity guard passes. **Verify:** exit 0 on the
validate command; recorded byte count is below the hard cap today (expected, since html has no
Components tier yet to bloat it). **Blocks:** everything.

---

### Task 1: `homeSurface` — the new generator primitive Components-tier rendering needs

- [ ] **Step 1.1** In `pipeline/elm-cem/codegen/Generate/Phantom/Emit/Home.elm`, add a `homeSurface`
      function analogous to `Component.elm`'s `compSurface`/`ComponentSurface`
      (`Component.elm:21-65`): given a `Brand` and one home-group `Comp`, return its re-exportable
      surface — the member's `Attrs`/`Is`/`ChildAdmittedBy`/`AdmittedBy`/`Roles` type-alias names (with
      element-prefix, matching what `Home.elm`'s existing `memberAttrsRow`/`homeModule` already render)
      plus its constructor's value name and annotation text.
- [ ] **Step 1.2** Unit-test `homeSurface` against a small fixture (e.g. `Table`'s 10 members) —
      assert the returned surface's exposing list matches what `homeModule` already emits for that
      home today (byte-for-byte name parity is the correctness bar, since this must never drift from
      the Elements tier it re-exports, mirroring `FamilyPackage.elm`'s own anti-drift discipline, lines
      8-18).
- [ ] **Step 1.3** Commit, identity guard first.

**Acceptance:** `homeSurface Table.Caption` (etc.) returns a surface whose names exactly match
`TypedHtml.Element.Table`'s current `exposing` list for that member. **Verify:** `elm-test` on the new
unit test; `elm make` on the codegen package. **Blocks:** Task 2. **Blocked by:** OQ-H1 (confirm Option
A before investing in this primitive — Option A′ needs the same primitive; Option B does not use it at
all and needs a different investment).

---

### Task 2: PoC on one real family (`Table`)

- [ ] **Step 2.1** Add a `_families` block to a **test fixture** config (not the real
      `brands/html/inputs/config.json` yet) declaring `Table` with its 9 non-root members
      (`brands/html/inputs/config.json`'s Table home group, minus the root itself).
- [ ] **Step 2.2** Build a minimal `HomeFamilyPackage.elm` (new sibling module, not a `FamilyPackage.elm`
      edit — keeps the home-sourced code path physically separate from the own-comp path per this
      repo's "smaller focused files" convention) that consumes `homeSurface` (Task 1) the way
      `FamilyPackage.elm:641-669`'s `resolveMember` consumes `compSurface`, and emits one
      `TypedHtml.Component.Table` module.
- [ ] **Step 2.3** Regenerate the fixture brand; confirm `TypedHtml.Component.Table` compiles and its
      exposing list is the union of `TypedHtml.Element.Table`'s 10 members' surfaces, member-prefixed
      where names would otherwise collide (none should collide here, since `Home.elm` already
      element-prefixes every type — verify this assumption explicitly rather than assuming it).
- [ ] **Step 2.4** A tiny hand-written consumer imports `TypedHtml.Component.Table` and successfully
      constructs a `<table>` with `<thead>`/`<tbody>`/`<tr>`/`<td>` — proves the façade's re-exported
      constructors are usable, not just present.

**Acceptance:** all four steps pass on the fixture brand. **Verify:** `elm make` on the codegen and on
the hand-written consumer; exposing-list diff recorded (should show pure re-export, zero behavior
change). **Blocks:** Task 3. **This is the "prove one leaf before the atomic remap" gate**, same
discipline the DAG-rework plan used for its `NavMenu` PoC (`dag-rework-plan.md:368-384`).

---

### Task 3: CRUX GATE — whole-brand expansion (all recommended families)

- [ ] **Step 3.1** Extend `HomeFamilyPackage.elm` to cover all families resolved in OQ-H1/H2/H3
      (`Table`, `Select`, `Details`, `Dl`, and `Picture` pending OQ-H2's resolution).
- [ ] **Step 3.2** Add the real `_families` block to `brands/html/inputs/config.json` (not the fixture
      this time), matching m3e's `_families` shape (`brands/m3e/inputs/cem/config/slots.json:31-48` for
      the `package`/`deps` shape; `:49-90` for the `families` map shape) with `lib: "TypedHtml"`,
      `namespace: "Component"`, `package.dir: "../elm-typed-html-components"`.
- [ ] **Step 3.3** Regenerate html whole-brand; assert every declared family's façade module compiles
      and its exposing list is the exact union of its members' `TypedHtml.Element.*` surfaces (no
      drift — same anti-drift discipline as Task 2, run across all 4-5 families this time).
- [ ] **Step 3.4** Confirm the ~95 non-family elements are **untouched** — no new modules, no changed
      `TypedHtml.Element.*` output for them (this generator change must be a pure ADD for families,
      never touching the elements tier's existing rendering at all).
- [ ] **Step 3.5** Run `elm-cem validate --packages=...` against the new package layout; confirm the new
      `elm-typed-html-components` docs.json is under the 768,000 B hard cap (§5's risk check).
- [ ] **Step 3.6** Determinism check: regenerate twice, confirm byte-identical output (mirrors
      `tools/check-drift.mjs`'s discipline, cited at `dag-rework-plan.md:390-391`).
- [ ] **Step 3.7** Commit the generator + config change. Identity guard first.

**Acceptance:** whole-brand regen produces the 4-5 family façades, is deterministic, and stays under the
registry cap. **Verify:** `elm make` per package; drift-check green; `validate` green. **Blocks:** Task 4.

---

### Task 4: MATERIALIZE — `packages.json` split + `family.json` registry

- [ ] **Step 4.1** Add `elm-typed-html-components` to
      `brands/html/generated/package/elm-typed-html/packages.json`'s `packages` list (new bucket
      `{"prefix": "TypedHtml.Component."}`), following the existing `elm-typed-html-elements` bucket's
      shape (`packages.json:56-76`) and depending on `jackhp95/elm-typed-html-elements` (the components
      tier consumes elements, never the reverse — same DAG direction as m3e/shoelace).
- [ ] **Step 4.2** Update `packages.json`'s `$scopeNote` (line 5) — it currently asserts "No
      Build/components tier is derivable... real ceiling is 3 tiers"; this is the exact claim this plan
      falsifies. Replace with a note recording the new 4-package ceiling and the Build-tier non-goal
      decision (§4), citing this plan doc.
- [ ] **Step 4.3** Add `elm-typed-html-components` to `tools/family.json`, mirroring the
      `elm-m3e-components` entry shape (`family.json:96-106`) — `srcDir`,
      `mirror: { auditedExclusions: false }` (no published mirror yet, matching every other html/shoelace
      sibling per the existing `$comment_elm_typed_html_split_siblings` note pattern, `family.json:136`).
- [ ] **Step 4.4** Update `family.json`'s `$comment_elm_typed_html_split_siblings` comment
      (`family.json:136`) to record the new 4-package shape and drop the now-false "no build/components
      tier is derivable" line.
- [ ] **Step 4.5** Run `npm run split` (or html's equivalent split command — confirm exact script name)
      to materialize the new sibling package directory on disk.
- [ ] **Step 4.6** `elm make` every html package; confirm the whole split compiles clean.

**Acceptance:** html ships 4 real packages (facts, core, elements, components); `family.json` and
`packages.json` both accurately describe the new shape (no stale claims left in either). **Verify:**
`elm make` per package; a manual re-read of both edited `$scopeNote`/`$comment` blocks confirms no
contradictory claims remain (this task exists specifically because the last version of these notes was
already wrong once — don't repeat that). **Blocks:** Task 5.

---

### Task 5: Package-DAG gate coverage for html

- [ ] **Step 5.1** `tools/check-package-dag.mjs` currently hardcodes `brands: [m3e, shoelace]`
      (`check-package-dag.mjs:40-59`) — **this is not automatic**, contra FU-1's "already brand-agnostic
      and would cover html" framing (verified false; logged as a friction). Add an `html` entry:
      `packageRoot: brands/html/generated/package`, `split: { components: "elm-typed-html-components",
      elements: "elm-typed-html-elements" }` (no `build` key — Option A ships no Build tier, so
      assertion (A)/(B) in the gate's own doc comment (`check-package-dag.mjs:8-19`) don't apply to
      html; only assertion (C), "no Element shortcut," is meaningful, and only in the direction
      Components→Elements since there is no Build tier to check for a shortcut).
- [ ] **Step 5.2** Confirm assertion (C) — no `TypedHtml.Component.*` module imports
      `TypedHtml.Element.*` **directly with an aliasing that bypasses the façade's own re-export** (this
      needs a small script adjustment since html's façade legitimately DOES import
      `TypedHtml.Element.*` — that's the whole point of a re-export façade, unlike m3e's Build→Component
      indirection rule which forbids Build from ever touching Element directly). Document this html-specific
      exception in the gate script's comment so it doesn't get "fixed" into a false positive later.
- [ ] **Step 5.3** Run the gate; confirm green.

**Acceptance:** `check-package-dag.mjs` explicitly asserts html's new shape (not silently uncovered).
**Verify:** gate exits 0 for html; stash-test that it correctly fails if a components module were made
to bypass its own re-export contract (prove both directions, matching the reconciliation plan's Task 5
discipline, `reconciliation-plan.md`-style). **Blocks:** Task 6.

---

### Task 6: `gate-all` green milestone

- [ ] **Step 6.1** Full `npm run gate:all` (or this repo's equivalent). **Acceptance:** exit 0.
- [ ] **Step 6.2** Re-run Task 0's registry-size measurement; confirm every html package (including the
      new components package) stays under the 768,000 B cap with headroom recorded for future growth.

**Acceptance:** gate-all green; registry sizes recorded. **Verify:** exit codes. **Blocks:** Tasks 7, 8.

---

### Task 7: Consumer surface check (docs/examples)

- [ ] **Step 7.1** Grep the workspace for any hand-authored code importing
      `TypedHtml.Element.{Table,Select,Details,Dl,Picture}` today (docs app, examples, fixtures).
      Because this plan is purely additive (§ Migration path), none of these should need to change —
      confirm that expectation rather than assuming it.
- [ ] **Step 7.2** If any docs/example page would read better against the new
      `TypedHtml.Component.*` façade (e.g. a "building tables" guide page), note it as a follow-up
      documentation improvement — **not** required for this plan's completion, since the façade is
      purely additive and existing code keeps working unchanged.

**Acceptance:** confirmed zero required consumer changes; optional doc-improvement follow-ups filed
separately if found. **Verify:** grep output reviewed by hand. **Blocks:** Task 8 (should run after, to
avoid re-baselining twice if Step 7.1 surfaces an unexpected required change).

---

### Task 8: Face-A bundle re-baseline + phantom re-bless

- [ ] **Step 8.1** Per the standing rule (`docs/plans` memory note "Generator change → D-046
      re-baseline"): any shared elm-cem emitter change requires a Face-A bundle re-baseline, an
      all-brand regen, and a phantom re-bless. This plan's Task 1 change (`homeSurface` +
      `HomeFamilyPackage.elm`) is exactly such a shared emitter change, even though it's additive and
      html-only in effect today — confirm it produces **zero diff** for m3e/shoelace/svg (the new code
      path is additive and should never fire for other brands unless they too declare home-family
      configs, which none currently do).
- [ ] **Step 8.2** Run the standard re-baseline + re-bless procedure; confirm zero diff for every brand
      except html's new components package.

**Acceptance:** re-baseline complete; only html shows new generated output. **Verify:** re-run emits
zero diff outside html. **Blocks:** Task 10.

---

### Task 9: Build-tier disposition record (doc-only, forces explicit go/no-go)

- [ ] **Step 9.1** Record, in this plan doc's Follow-ups section (or a dedicated ADR if the domain-modeling
      skill's decision-record convention is in use for this repo), the final decision on OQ-H1: Option A
      shipped (no Build tier) unless Jack overrode to A′ or B before Task 4 materialized. This closes
      FU-1's original "Build tier" half of its hand-off with an explicit, reasoned answer instead of
      letting it decay into another silent "future work" placeholder.

**Acceptance:** disposition recorded, citable. **No code.**

---

### Task 10: Final gate + verification

- [ ] **Step 10.1** Full `npm run gate:all` on the final tree.
- [ ] **Step 10.2** Diff Task 0's baseline against the final state; confirm the only changes are the
      additive Components tier (new package, new config block, new generator module) — no regressions
      to `elm-typed-html-{core,elements,facts}`.

**Acceptance:** html 4-tier (Components added, Build intentionally absent) shipped and gate-green; Task
0's baseline + this diff prove it.

---

## Dependency graph (sequencing / parallelism)

```
Task 0 ─▶ Task 1 ─▶ Task 2 (PoC: Table) ─▶ Task 3 (CRUX: all families) ─▶ Task 4 (materialize) ─▶ Task 5 (DAG gate)
                                                                                                        │
                                                                                                        ▼
                                                                                                  Task 6 [GREEN MILESTONE]
                                                                                                        │
                                                                        ┌───────────────────────────────┼───────────────┐
                                                                        ▼                               ▼               ▼
                                                                 Task 7 (consumer check)         Task 8 (bundle)   Task 9 (disposition, doc-only)
                                                                        └───────────────┬───────────────┘
                                                                                        ▼
                                                                                  Task 10 (final gate)
```

- **Gating:** Task 1 is blocked on OQ-H1 (confirm Option A before investing in the `homeSurface`
  primitive). Task 3 is blocked on OQ-H2/OQ-H3 (final family list). Tasks 7 and 9 can run in parallel
  with Task 8 after the Task 6 milestone. Task 9 is doc-only, no worktree needed, can run any time after
  OQ-H1 is confirmed (does not need to wait for Task 6).

---

## Friction note

Logged in full to `~/.claude/frictions/agent/` per its README schema; summarized here for anyone reading
this plan doc directly:

1. **FU-1's central technical claim is false.** `docs/plans/2026-08-21-dag-rework-plan.md`'s Task 9
   hand-off states `BuildPackage.elm` is "a general, brand-agnostic capability" that will produce
   `TypedHtml.Build.*` "with no new generator code" once html has a `_families` config. Verified false:
   `BuildPackage.elm:1293-1296`'s `hasBuilders` gate and `FamilyPackage.elm:793-826`'s
   `degenerateElements` both unconditionally exclude every comp where `homeOf /= Nothing`, which is
   **100%** of html's population. This is directly contradicted by an existing, correct note already in
   the tree (`brands/html/generated/package/elm-typed-html/packages.json:5`) that FU-1 apparently didn't
   cross-check against its own optimism. Suggested fix for future hand-off notes: when a hand-off claims
   "no new generator code," the claim should be spot-checked against the actual gating logic (grep the
   emitter for the discriminating filter, not just its module-level doc comment) before being repeated
   downstream — I nearly propagated it myself on a first pass before reading `BuildPackage.elm`'s body
   past its header comment.
2. **The commissioning brief's element count was off by ~7x.** "html only has 16 home elements" — html
   has 112 elements across 16 home **groups**. Minor, but shaped an early wrong assumption (that
   degenerate-single-member-family-for-everything, shoelace-style, would be cheap) until corrected by
   direct config enumeration.
3. **`docs/plans/2026-08-21-dag-rework-plan.md`'s blast-radius table is stale on shoelace's package
   shape.** It records shoelace as staying monolith; `tools/family.json:153-179` shows shoelace is now a
   5-package split (registry-cap driven). Not this plan's job to fix that doc, but worth flagging since
   it's a load-bearing precedent this plan cites.
4. **`check-package-dag.mjs` is not actually brand-agnostic today** (hardcoded `[m3e, shoelace]` array,
   `check-package-dag.mjs:40-59`), contradicting the DAG-rework plan's description of the gate as
   generically brand-agnostic. Minor but relevant to Task 5's scoping — it needs a manual edit, not just
   a config change, to cover a new brand.
5. **The `brainstorming` skill assumes an interactive human present to answer clarifying questions
   one-at-a-time.** This is a non-interactive gauntlet WORK-role leaf task with no user to dialogue
   with mid-task. Adapted by self-driving the skill's structure (context exploration → options with
   trade-offs → recommendation) internally rather than stalling on unanswerable clarifying questions,
   per the standing autonomy policy ("never stop to ask... just proceed and do the best work"). Suggested
   fix: either a non-interactive/self-answer mode for `brainstorming` when invoked from a subagent
   context, or explicit guidance in the skill on how to degrade gracefully when no user is present.

---

## Follow-ups (for whoever picks up execution)

- **FU-H1 — OQ-H1 disposition (Task 9) is the single highest-leverage checkpoint.** If Option A′ or B is
  chosen instead of Option A, re-read §4's type-system argument first — it's the reason this plan doesn't
  default to literal parity, not a hedge.
- **FU-H2 — svg is a second home-only brand** (`docs/plans/2026-08-21-dag-rework-plan.md`'s blast-radius
  table lists it as "exempt... home-only-ish; nothing to re-derive"). If html's Components tier ships,
  re-evaluate whether svg has any analogous structural composites worth the same treatment (SVG has
  real composite structures too — e.g. `<filter>` + its primitive children) — out of scope here, flagged
  for a future, separate plan.
- **FU-H3 — the html+svg barrel-in-core decoupling** (memory note "html+svg home brands, barrel-in-core":
  both brands are home-only, and moving their barrel from Elements into Core would need a cross-brand
  home-emitter decoupling, deferred). This plan's new Components tier does not depend on that
  decoupling landing first — it is additive on top of Elements regardless of where the barrel lives —
  but the two follow-ups touch the same `Home.elm`/`General.elm` generator surface
  (`General.elm:33-52`/`194-218`) and should probably be sequenced together if both are ever picked up,
  to avoid two separate people editing the same disjoint-pipeline generator code in the same quarter.
