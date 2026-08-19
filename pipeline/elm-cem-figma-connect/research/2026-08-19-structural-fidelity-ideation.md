# Structural fidelity in the Figma ⋈ Elm round-trip — an idea menu

> **Status: pre-decision ideation.** This is a menu for review, not a plan. Nothing here is
> decided, sequenced, or authorized. `plans/` is for decided work; this is not that.
>
> Written 2026-08-19, after running all four directions of the round-trip across two example
> screens ("Detailed view" = Figma→Elm→Figma; "Feed" = Elm→Figma→Elm).
>
> **Anti-goal, stated by Jack and honored throughout:** hardcoding widths/heights and using
> absolute positioning would get exact pixel diffs and is *the completely wrong approach*. The
> target is **semantic/structural losslessness** — right component, right variant, right slot,
> right container semantics, right content. Ideas that are pixel-matching in disguise are
> collected and rejected explicitly in [§6](#6-rejected-pixel-matching-in-disguise).

---

## 1. The problem, restated

### 1.1 What actually happened

The Feed example (`Route.Examples.Feed`, authored fresh in Elm with **no** pre-existing Figma
counterpart) round-tripped Elm → Figma → Elm.

**Content fidelity was perfect.** Every string — authors, timestamps, titles, categories,
excerpts, filter labels, nav labels — came back byte-for-byte identical.

**Structural fidelity was not.** Four distinct failures, all of them introduced in the
**code → Figma** leg. The Figma → code read-back was *faithful*; it accurately reproduced a
wrong-but-present structure. That asymmetry is the single most important fact in this document:

> The read direction does not need fixing. It needs something correct to read.

### 1.2 The four failures, as a drift taxonomy

Naming these matters, because each lever below fixes a specific subset.

| ID | Name | Feed instance | What was lost |
|---|---|---|---|
| **D1** | **Substitution drift** | The real Elm `Card` for a feed post is plain — no avatar, no overflow menu. The build picked the kit's closest ready-made "social card", which has a **mandatory** avatar + author/timestamp header row + a `⋮` menu button. | Component identity. Chrome was *invented* that has no code counterpart, and the read-back dutifully coded it. |
| **D2** | **Slot drift** | Real code puts the category label **above** the title. The kit card exposes only a "Subhead" slot **below** the title. Category went there. | Slot identity — and note the precise mechanism: `M3e.card`'s slots are `unnamed, header, content, actions, footer` (`brands/m3e/inputs/cem/config/slots.json`), all `kinds:["any"]`, all `multi:false`. So category-above-title is **order within one slot**, which is the one case where child order genuinely *is* semantic (§ 5). Figma promoted it into a *different named slot*, which destroys exactly the information that mattered. |
| **D3** | **Flattening drift** | The real media area is itself a nested `M3e.card` — a real component with a real M3 token shape/colour class, containing an icon. Figma got a flat rounded rectangle with a *resolved literal fill*. | Two things at once: component identity **and** token identity. Unrecoverable from the Figma side as built. (Card-in-card does type-check — Card's slots are kind-permissive `any` — though no example in the repo nests one today; `DetailedView.elm`'s `thumbnail` is the nearest precedent, a `filled` card used as a media tile.) |
| **D4** | **Container-elision drift** | Real code wraps the filter chips in a semantic `M3e.filterChipSet`. Figma got a plain auto-layout row of individual chip instances. | Container semantics — and this one is **not** a Figma limitation. See § 1.3b: `m3e-filter-chip-set` was *deliberately left unbound* on the read side, and the substitution is not benign (it silently drops roving-focus keyboard nav, `#updateChipRole` radio-vs-checkbox assignment, form association, and selection tracking). |

Every one of the four is a **composition** failure. None is a prop failure and none is a content
failure. That is diagnostic: the existing correspondence model covers component *boundaries*
(tag + attrs + variant axes) and covers them well. It does not model *trees*.

### 1.3 Root cause

The repo has, for the **read** direction: a JSON-Schema'd checked-in data model
(`src/correspond/schema.json` + `profiles/m3-kit/correspondence.json`), a tiered scored matcher
with an explicit `gap` tier, a provenance enum with a human-protection merge law, an `unmapped`
field with a written reason for every axis and prop that has no counterpart, pure
determinism-gated emitters, and a publish gate that refuses to ship an unverified binding.

For the **write** direction it has *nothing*, and that is by explicit prior decision —
`plans/00-mission-and-decisions.md` decision **D6**: *"Code-only / Figma-only gaps are logged as
a first-class report; **no Figma authoring in this plan**."*

So the Feed build was necessarily improvised by an agent driving `use_figma` and
`search_design_system` per node. And in improvising, it violated two of the repo's own standing
doctrines:

- `docs/upstream-requests.md` U3, on the bottom-app-bar: *"`m3e-toolbar` is structurally the
  closest but semantically distinct … so it was **not** bound — **a wrong binding is worse than
  none**."* D1 is precisely a wrong binding, made in the direction that has no policy.
- `VISION.md` § Principles: *"Nothing hardcoded. Every module, setter, token, and binding is
  measured or generated from the CEM. **A name that can't be verified is surfaced as a concern,
  never guessed.**"* The write direction guessed, four times.

Meanwhile `VISION.md` § "What done looks like" commits to the direction outright:

> **Code → Figma.** Write Elm and see it mirrored in Figma, built from the real design-system
> components — not redrawn by hand.

…but no roadmap phase covers it (Phases 0–5 are all read-direction or infrastructure). The
capability was promised, never modeled, and then exercised.

### 1.3b A sharper root cause for D4: a recorded read-side decision became a write-side hole

`docs/coverage-and-gaps.md`, under "Correspondence candidates evaluated & skipped":

> **`m3e-radio-group` / `m3e-selection-list` / `m3e-filter-chip-set` / `m3e-input-chip-set`** —
> would double-bind sets already bound to their base tags (`m3e-radio`→Radio buttons,
> `m3e-list`→List, `m3e-chip-set`→Chip groups).

That is a *correct* decision for the read direction (avoid ambiguous double-binding) and it is
recorded in the right place. `brands/m3e/inputs/cem/config/figma.generated.json` confirms the
consequence: it has entries for `ChipSet` and `FilterChip`, and **none** for `FilterChipSet`.

But in the write direction the same decision means "there is no way to say
`m3e-filter-chip-set`" — and nobody noticed, because the write direction has no gap report. The
substitution is **not** semantically neutral: both `m3e-chip-set` and `m3e-filter-chip-set` stamp
`role="group"` (via `slots.json`'s `staticAttrs`), but only the filter set implements roving-focus
arrow-key navigation, `#updateChipRole` (radio-vs-checkbox roles depending on `multi`), form
association (`formAssociated = true`), and `selected` / `value` tracking. Scale matters too: the
same doc's Venn snapshot puts ~79 CEM tags in the "web-components-only crescent — mostly
primitives & sub-parts". **D4 is a class of failure roughly 79 tags wide, not a one-off.**

**The generalizable lesson:** a read-direction "deliberately unbound, and here's why" entry is
simultaneously a write-direction *hazard*, and nothing today connects the two.

### 1.4 One framing claim, stated up front so it can be argued with

**This is not a Figma expressiveness gap.** Figma has named `SlotNode`s, component properties,
hard instance boundaries, arbitrary invisible per-node key/value metadata, and a REST channel to
read that metadata back. All four failures are *representable* in Figma today. The gap is that
(a) the write direction has no model, and (b) the design system being written **into** — the M3
Community Kit — is not isomorphic to `elm-m3e`, so every write is a translation between two
non-isomorphic vocabularies, performed ad hoc, per node, by an agent.

---

## 2. Figma-side levers

### F1 — `sharedPluginData` structural stamp

**Mechanism.** Every node the writer creates gets
`node.setSharedPluginData("<ns>", "src", JSON.stringify({...}))` carrying its code-side identity:
cemTag / Elm module+function, the **slot path** it occupies, the recipe id + recipe version, and
the `kitVersionTag` epoch. Invisible in the UI; survives in the file.

Three independent read-back paths, which is what makes this more than a toy:

1. `use_figma` traversal — read it in the plugin sandbox.
2. `findAllWithCriteria({ sharedPluginData: { namespace, keys } })` — an **indexed** query, per
   the Plugin API typings. So "find every node I stamped" is cheap, which makes idempotent
   re-write and structural diffing tractable rather than a full-tree scan.
3. **REST**: `GET /v1/files/:key?plugin_data=shared`. Confirmed against the current REST docs —
   `plugin_data` takes *"a comma separated list of plugin IDs and/or the string `shared`"* and
   *"Any data present in the document written by those plugins will be included in the result in
   the `pluginData` and `sharedPluginData` properties."* The existing extraction pipeline is
   REST/plugin-bridge shaped already, so adopting this is close to a query-param change plus a
   schema field.

Note the Plugin API surface exposed to `use_figma` has **only** the `Shared` variants
(`getSharedPluginData` / `setSharedPluginData` / `getSharedPluginDataKeys` on `PluginDataMixin`) —
not private `setPluginData`. That is fine and arguably better: shared data is namespaced and
readable by any tool, including the REST path above.

**Drift fixed.** All four. D1 (the instance is stamped "I stand for a plain `M3e.card`", so the
avatar/menu are readable as *unmapped chrome* rather than content); D2 (slot path is explicit —
no positional inference needed); D3 (a flat rect stamped `{tag:"m3e-card", slot:"media"}` is
recoverable); D4 (a plain auto-layout row stamped `{tag:"m3e-filter-chip-set"}` is recoverable).

**Cost.** Low–moderate. The stamp payload shape is the real design work; the mechanics are trivial.

**Risks / downsides.**
- **A stamp is a claim, not a fact.** A designer editing the frame by hand will desynchronize
  stamp from reality — deleting the avatar, adding a row, swapping a variant. So the read side
  must *validate* the stamp against the observed structure, not trust it. Untrusted-metadata
  handling is a real subsystem, not a footnote. (The matcher already has exactly this concept for
  descriptions: `descriptionUntrusted` in `profiles/m3-kit/matcher.json`.)
- 100 kB cap per `(namespace, key, value)` entry.
- **`get_design_context` does not surface it.** The default, MCP-blessed read path is blind to
  stamps; recovering them means switching the read-back to REST-with-`plugin_data` or a
  `use_figma` traversal. That is a real cost on the read side, and it forfeits some of
  `get_design_context`'s Code-Connect substitution work unless combined with F2.
- **Identity anchoring.** Node IDs and component keys re-mint on file duplication — this repo's
  evidence #5, the fact that shapes its whole identity model (*"Duplication mints new component
  keys … Node IDs ARE stable [within a file] ⇒ per-copy republish"*). Stamps must therefore carry
  **name/slug anchors**, never Figma ids, or they break on the first copy.

**Novelty.** The *mechanism* is unused: `grep -ri plugindata` over `core/cem-figma-connect`
returns **zero hits**. But the *pattern* is fully built — `src/tokens/stamp.mjs` (499 lines)
already generates idempotent, **name-anchored**, human-gated, invertible stamp scripts with a
pre-stamp snapshot, for variable `codeSyntax`. Extending "stamp identity onto Figma objects from a
checked-in table" from variables to nodes is a generalization of existing machinery, not an
invention. Read its header before designing anything here; the portability, idempotency, chunking
and inverse-script doctrines are all already worked out.

---

### F2 — The Code Connect coverage invariant ("every node is bound or slotted")

**Mechanism.** Define the write direction's output as *legal* only if every node in the emitted
frame is one of:

1. an instance of a component that has a **published Code Connect binding** for the target label, or
2. content inside a **`SLOT`** of such an instance, or
3. an **explicitly declared escape hatch**, with a written reason.

Then Figma → code stops being visual re-inference and becomes **interpretation of a bound tree**.
This works because Code Connect templates are already recursive and composable, not flat
snippet lookups: `instance.getSlot('Name')`, `instance.findConnectedInstance(id)`,
`instance.findConnectedInstances(fn)`, `child.executeTemplate().example`, and
`metadata.props` for passing structured data from a child template up to its parent. A fully
bound tree evaluates to code deterministically.

**Drift fixed.** D1, D3, D4 by construction — an unbound rounded rectangle standing in for a card
is *illegal output*, so the build fails instead of silently lying. D2 only in combination with F3.

**Cost.** Moderate as an invariant + checker. The expensive part is that **the invariant is
currently unsatisfiable against the M3 Community Kit** — which is the finding, not the objection.
See C3.

**Risks / downsides.**
- It converts fidelity failures into **build refusals**. That is correct by this repo's doctrine
  ("a wrong binding is worse than none") but will feel like the tool can't build your screen.
  Needs the escape hatch (3) to be first-class and *reported*, the way `unmapped` and
  `gap-report.md` already are on the read side, or people will just disable it.
- Coverage is per-`(fileKey, label)` — bindings do not follow duplicated files.

**Novelty.** Builds on committed artifacts: `generated/m3-kit/{web-components,elm}/MANIFEST.json`
(224 files per label; 141 of them icons from a single `kind:"iconTable"` entry) and
`profiles/m3-kit/published.json` (`{ [fileKey]: { [label]: { publishedAt, nodeIds, … } } }`).
Both are checked in, so **the invariant is checkable offline** — no Figma call needed to know
whether a component you're about to instantiate has a binding. Also: every emitted binding
already carries `metadata: { nestable: true }`, so nested composition is already switched on.

---

### F3 — Read and use Figma `SLOT` properties and `SlotNode`s

**Mechanism.** Figma has a first-class slot concept: `SlotNode` (`type: 'SLOT'`),
`component.createSlot()` which auto-wires a `SLOT`-typed component property, and
`instance.findAllWithCriteria({types:["SLOT"]})` to find them by name in an instance. A slot in
the layer tree is a *named, machine-readable* "arbitrary content goes here" marker — the closest
native analogue to a CEM slot that exists.

**This is a documented outstanding gap in this repo's own schema.**
`src/ingest/figma-export.schema.json` already enumerates `SLOT` in the `setProperties[].type`
enum, annotated *"not mapped by the current matcher/emitter surface."* The capture records slot
properties and the matcher ignores them.

**Drift fixed.** D2 outright (slot identity becomes named and explicit rather than positional).
Enables D3 and D4 (a nested card living inside a `media` `SlotNode` is unambiguous both ways).

**Cost.** Low to start *reading* — the schema already carries the data; the matcher needs a slot
dimension alongside its existing `axes` / `props`. Moderate to start *authoring* slots, because
**you cannot add a slot to a remote library component** — authoring slots requires components you
own (see C3).

**Risks.** Slot restrictions are real but mild: no `GRID` layoutMode on a slot; slots can't nest
inside slots; `instance.setProperties({slotKey: …})` throws (content is set by appending
children); appending can invalidate a stale node handle. All documented, all worked around.

**Novelty.** Reading is *already scoped and deferred* in this repo. Authoring is new.

---

### F4 — Component `description` as a structured micro-format

**Mechanism.** Promote a reserved fenced block inside a component/component-set `description`
to a **trusted structured** channel, rather than the prose it is today.

Descriptions are already in the pipeline on both sides: the capture records
`components[].description` (confirmed in `research/figma-dumps/figma-export.m3-kit.json` — the
per-component record is exactly `{description, id, key, name, page, type}`), the matcher already
consumes them as a *fuzzy* signal (`descSignal = jaccard(descriptionTokens)`, weighted 0.25, plus
`docUrls` extraction of `m3.material.io/components/…` links weighted 0.15), and
`get_design_context` surfaces a "Component descriptions" section to the reading agent.

**Drift fixed.** D1, partially — a description can declare "this kit component corresponds to
`m3e-card`, plus a mandatory avatar + menu that have **no** code counterpart", turning invented
chrome into *declared* unmapped chrome.

**Cost.** Low.

**Risks / downsides — and these are close to disqualifying for the kit case.**
- **Descriptions are library-owned.** You cannot edit the M3 Community Kit's component
  descriptions. This channel is only available on components you own, which collapses it into C3.
- Human-visible and human-editable, so it rots; the matcher already carries a
  `descriptionUntrusted` denylist precisely because kit descriptions are unreliable.
- **Per-component, not per-instance.** It can never carry a slot path for a particular screen.

**Verdict.** Good for *component-level* identity in a library you own. Useless for
*instance-level* composition — which is where three of the four Feed failures live.

---

### F5 — Layer-naming convention as the identity channel

**Mechanism.** Every node has a `name` whether you use it or not. Adopt a reserved grammar —
`m3e-card/media`, `⟦m3e-filter-chip-set⟧`, or similar — so structural identity rides on a field
that already exists.

**Drift fixed.** Same set as F1 (all four), at a fraction of the mechanical cost, and
**visibly**: a designer can see it, audit it, and understand why it's there. It also survives
copy/paste, export, and any tool that reads Figma at all — no special read path needed, unlike F1.
Name-anchoring is already this repo's chosen portability primitive (evidence #5; the entire
`stamp.mjs` `TARGETS` array is name-keyed, with a test asserting no `VariableID:` appears).

**Cost.** Very low.

**Risks / downsides.**
- **Names are the one field designers freely rewrite.** This is the rot-prone channel by
  construction.
- It pollutes the layer panel, and on instances a custom name is an *override*, which Figma marks
  as changed — designers may reset it.
- Escaping / collision / grammar-parsing fiddliness.

**Verdict.** Best as the **human-readable mirror** of F1's machine stamp — stamp authoritative,
name as the affordance and the review surface. That dual pattern is already the repo's house
style: `provenance` (machine enum) sits next to `rationale` (human string) on every correspondence
entry.

---

### F6 — Annotations, Dev Resources, Dev Status

**Annotations — reject as a metadata channel.** `node.annotations = [{ label, labelMarkdown,
properties, categoryId }]`, where `AnnotationPropertyType` is literally
`'width' | 'height' | 'maxWidth' | 'minWidth' | … | 'cornerRadius' | 'padding' | 'itemSpacing' |
'layoutMode' | 'gridRowGap' | …`. That is a **measurement-pinning** feature; using its
`properties` channel is one step from the rejected pixel approach (see §6.2). `labelMarkdown` is
free-form and *could* carry structure, but annotations render as visible pins on the canvas and
are a designer-facing review artifact, not a data channel.

**Annotations — possible legitimate use:** surfacing **escape hatches and unmapped nodes to a
human reviewer**, i.e. as a *report* rendered into the file. "This rectangle stands for a nested
card the kit can't express — review me." That is the same move as `gap-report.md`, just rendered
where the designer is. Cheap, honest, and it makes the gap visible rather than invisible.

**Dev Resources — small, real, weak.** `addDevResourceAsync(url, name)` puts a per-node link in
Dev Mode. Stamping each node with a link back to its source (e.g. the `elm-m3e` docs URL for the
Elm function that produced it) is low-cost, human-facing, and genuinely useful for a developer
reading the frame. As an *identity* channel it's weak: keyed by URL, and instances inherit
resources from their main component (`DevResource.inheritedNodeId`), so per-instance identity is
awkward.

**Dev Status — not relevant.** `devStatus` can only be set on a node directly under a page or
section, so it can't mark anything inside a frame.

**Variant "restrictions" — not a thing in the API.** There is no mechanism to constrain which
variants a consumer may instantiate. The nearest relative is `INSTANCE_SWAP`'s
`preferredValues` / `InstanceSwapPreferredValue`, which is a *suggestion list*, not a constraint,
and is already captured by the ingest schema (`setProperties[].preferredValues`).

---

### F7 — Variables: reject for component identity; **apply** the already-built token stamp

**Component identity through variables — reject.** Variables are typed values bound to node
*properties*. There is no property to bind "I am an `m3e-card`" to, and minting identity variables
would pollute the token namespace and the library publish surface. This is abuse of the mechanism.

**Token identity through `codeSyntax` — sanctioned, already built, and *not yet applied*.**
`setVariableCodeSyntax("WEB", value)` is the blessed channel for pushing code vocabulary into
Figma, and `plans/01-architecture.md` § 1 names it in the authority table: *"Naming for generated
code — **Code**, via codeSyntax stamping, we **push** our vocabulary into Figma."* The whole
subsystem exists: `src/tokens/stamp.mjs` generates six committed scripts under
`profiles/m3-kit/stamp/` plus a read-only `00-snapshot.js` and a 1:1 `unstamp/` inverse. Evidence
#6 proves it live: `setVariableCodeSyntax("WEB", "var(--md-sys-color-on-surface)")` →
`get_design_context` immediately emits `var(--md-sys-color-on-surface,#1d1b20)`. Evidence #13
measures **0 of 304** variables currently carrying any `codeSyntax`.

**Drift fixed.** The *token half* of **D3**. The Feed media area came back as "a flat rounded
rectangle with a **resolved literal fill colour** — no token name, no hint". If that fill were
bound to a `codeSyntax`-stamped variable, the read-back recovers
`var(--md-sys-color-surface-container-*)` **even when component identity is lost**. It converts an
unrecoverable failure into a partially recoverable one, for zero new engineering.

**Cost.** The work is done. It needs a ⚑ human-authorized run per file
(`profiles/m3-kit/stamp/README.md` is the runbook).

**Risk.** Writes to a real design file; mitigated by design — idempotent, name-anchored,
snapshot-first, fully invertible. Only `status: "mapped"` rows are stamped, deliberately, so
unmapped tokens keep Figma's own slug as *"a visible 'not yet wired' signal"* rather than a
confident wrong vocabulary word. That doctrine — **leave the gap visible rather than guess** — is
the one to carry into every other lever here.

**Novelty.** None. Existing, tested, unapplied. Highest value-per-remaining-effort item on the board.

---

## 3. Code-side levers

### C1 — A write-direction correspondence: the "instantiation recipe"

**Mechanism.** Mirror `src/correspond/schema.json` for the inverse direction: a checked-in,
schema-validated recipe keyed by the **code** construct (cemTag, and/or an Elm module+function),
naming the exact Figma component (name-anchored + node-id, per evidence #5), the variant
selections, the slot → child assignments, and — critically — an explicit
`unsupported` / `escapeHatch` field **with a written reason**, exactly like the read model's
`unmapped`.

Reuse the read model's proven governance wholesale: `provenance` enum
(`auto-exact | auto-fuzzy | auto-contains | auto-gap | human | manual`), `status`
(`proposed | confirmed | rejected`), `confidence`, `rationale`, and above all the merge law from
`src/correspond/merge.mjs` — `isProtected(entry) = provenance === 'human' || status === 'confirmed'`,
and a differing re-proposal lands in `proposedUpdate` rather than overwriting a human decision.

**Drift fixed.** D1 and D2 **outright**. A recipe for the Feed card would have been *forced* to
record "the M3 kit Card exposes no above-title slot" as `unmapped` with a reason — a visible
refusal instead of a silent mis-slotting. And it would have had to record the social card's
mandatory avatar + menu as Figma-only chrome, which is exactly the shape the read model already
uses for Figma-only props (`{figmaProp: "Image", kind: "instanceSwap", unmapped: "no CEM
counterpart (Figma-only property)"}`).

**Cost.** Moderate–high as a new subsystem, but architecturally cheap: schema, merge law,
review CLI (`match`/`review`/`confirm`/`gap`), gap report, and determinism gate are all patterns
that exist and work.

**Risks.** Two models to keep mutually consistent — needs a cross-check gate asserting a write
recipe and its read correspondence agree about slots, axes, and values, or they will drift into
disagreement and you'll have two truths.

**Novelty.** New artifact, existing pattern. Also note it partially reverses decision **D6**
("no Figma authoring in this plan"), which is a decision Jack's team should re-open deliberately
rather than by accident — which is arguably what happened on 2026-08-19.

---

### C2 — The structural contract already exists: `slots.json` + `examples.json`

This is the lever I most under-estimated before reading the code. **The machine-readable slot
model the write direction needs is already checked in, and it is richer than the correspondence
model that consumes it.**

**Mechanism, part 1 — `brands/m3e/inputs/cem/config/slots.json` (57 KB).** The elm-cem codegen
*input*. Keyed by PascalCase component, it declares per-slot **admitted kinds, multiplicity,
requiredness**, plus `staticAttrs` and `actionMap`. Slot insertion order in the JSON **is** the
declared order:

```json
"Card": { "actionMap": [["onClick","onClick"],["href","link"]],
  "admits": { "unnamed":  {"kinds":["any"],"multi":false,"required":false},
              "header":   {"kinds":["any"],"multi":false,"required":false},
              "content":  {"kinds":["any"],"multi":false,"required":false},
              "actions":  {"kinds":["any"],"multi":false,"required":false},
              "footer":   {"kinds":["any"],"multi":false,"required":false} } }

"FilterChipSet": { "staticAttrs": { "role": "group" },
  "admits": { "unnamed": {"kinds":["filterChip"],"multi":true,"required":false} } }
```

Read that second entry against D4: the contract *already says* a filter-chip-set admits filter
chips, many of them, in a `role="group"` container. A write-direction recipe validated against
`slots.json` cannot silently elide it.

The same contract exists in two more machine-readable forms, all derived from one CEM parse:
`brands/m3e/outputs/elm-m3e/src/M3e/Review/Facts.elm` (`requiredSlots`, `multiSlots`, `slotKinds`,
`slotUpgrades`, `slotRewrites`, `actionMap` — what the `Cem.all` elm-review rules read), and the
**phantom types** in `src/M3e/Internal/Types/*.elm` (`SlotCaps`, `Content`, `ChildAdmittedBy`),
which enforce slot admittance **at compile time**, not merely by lint. `m3e-filter-chip-set`'s
`Content = { filterChip : Brand }` — only filter chips, checked by the Elm compiler.

**Mechanism, part 2 — `profiles/m3-kit/examples.json` (1,568 lines)** already holds a **recursive
child tree** (`{ tag, slot?, attrs?, text?, children? }`) and `src/emit/example-content.mjs`'s
`validateExamples` already asserts every `tag` is a real CEM element (or one of an allowlist:
`span div p img input button label`) **and every `slot` is a real slot of its parent.** That
validator is nearly the missing guard, and it only needs to be strengthened from "is a real slot"
to "is a real slot, admitting this child's kind, respecting `multi`" — data it can read from
`slots.json`.

**Drift fixed.** D2, D3, D4. D2 in particular becomes checkable rather than aspirational: because
Card's named slots are all `multi:false`, "category and title in the same slot, in that order" is
*structurally distinguishable* from "category in a different slot" — which is exactly the
distinction Figma's card component erased.

**Cost.** **LOW.** Reuse, not construction. `slots.json` exists, `Facts.elm` exists, the recursive
tree exists, the slot validator exists. Probably the cheapest structurally-correct foundation
available anywhere in this menu.

**Risks.** `examples.json` is hand-authored and scoped to one canonical example per component;
scaling to screens needs generation from the Elm side (C4), and a screen-scale tree is a different
maintenance proposition. Also `slots.json` is a codegen *input* — reaching into it from
`cem-figma-connect` would couple the two; the honest route is via the facts bundle
(`brands/m3e/outputs/m3e-api-okf/data/cem-facts.json` — which `VISION.md` describes as
"tags/attrs/enums/**slots**"), preserving the one-producer rule.

**Bonus — a free coverage seed already exists.** `Feed.elm`'s `exampleFooter` carries a
machine-readable list of the components the screen is built from:
`[("appbar","AppBar"),("navrail","NavRail"),("navbar","NavBar"),("card","Card"),
("filterchipset","FilterChipSet"),("filterchip","FilterChip")]`. Every example screen declares its
own component inventory. A write-direction coverage check has a checked-in oracle *today*: cross
that list against `figma.generated.json` / the binding MANIFEST and `FilterChipSet` falls out
immediately as unrepresentable — D4, caught before a single Figma call.

**Novelty.** None mechanically. The reframe — "the structural contract we need already exists as
codegen input, and the correspondence model consumes only its flat props" — is the contribution.

---

### C2b — Transpose the escape ladder to the Figma write direction

**This is the policy Jack asked whether `m3e-okf` documents. It doesn't — but the repo does,
one layer over, and in almost exactly the right shape.**

`brands/m3e/outputs/elm-m3e/skills/auditing-m3e-escapes/SKILL.md` states **"The ladder"**:

> 1. **`M3e.*`** — a design-system component or its typed setter. If M3e models the thing, use
>    M3e, even if raw HTML would be shorter.
> 2. **`TypedHtml.*`** — standard HTML element, attribute, ARIA helper, or event.
> 3. **Escape** — `M3e.Unsafe.*` … and only for something the first two genuinely cannot express.
>
> "A escape that could have been rung 1 or 2 is a **defect, not a style preference**." … "Every
> surviving escape needs a comment saying **which rungs were checked and why they failed**. …
> **Silence is not** [a justification]." … "If an escape survives because the *library* is missing
> something … that is a codegen/config bug. **File it.** Do not let a library gap masquerade as
> userland necessity."

It even carries a `## Known library gaps` register (currently "None currently known").

**Mechanism.** Transpose it verbatim to the write direction:

1. **Bound design-system instance** — a kit (or owned) component with a published Code Connect
   binding for this cemTag. If a binding models the thing, use it.
2. **Owned local wrapper** — a `figma.createComponent()` component in this file that adds the
   missing slot/container, itself Code-Connect bound (C3-lite).
3. **Declared escape** — a raw frame/rect, permitted **only** with a stamped, written reason
   naming which rungs were checked and why they failed.

Rung-3 nodes are exactly F2's escape hatches, F1's stamp is where the reason lives, and the
"**file it**" clause maps onto the existing `docs/upstream-requests.md` register — which already
has the right voice for it ("a wrong binding is worse than none").

**Drift fixed.** All four, at the level of *policy* rather than mechanism. Today's Feed build took
rung 1 with a component that doesn't model the thing (D1), which the ladder classifies flatly as a
defect. And the "silence is not a justification" clause is the exact rule that would have forced
D2/D3/D4 to be written down instead of absorbed.

**Cost.** Very low as a document. The value is entirely in whether rung-3 nodes are *mechanically
detectable* — which is F1 + F2 + the § 4 checker.

**Risks.** A ladder without a checker is a doc nobody reads (§ 4). And there's a subtlety the code
ladder doesn't have: rung 2 (own a wrapper component) has an ongoing *design-system ownership*
cost that rung 2 in the Elm ladder (use plain HTML) does not. So the Figma ladder's rungs are not
equally cheap, and that should be said out loud in it.

**Novelty.** The ladder exists; the transposition is new. **The `m3e-okf` gap is real and worth
closing separately:** the KB has a thorough forward map (`skills/m3e/concepts/choosing-components.md`,
intent → component, 9 families) and exactly one tie-break rule (`applying-material-design/SKILL.md`
§ 1: *"When two classes seem to fit … prefer the lower-emphasis one that still communicates"*) —
which covers "two fit", never "**none** fit". Its 7 anti-patterns include nothing about
substitution or borrowing; the closest are one-off negatives (`card.md`: *"Don't use a card merely
to draw a box around content that isn't a distinct unit"*; `chips.md`: *"Do not use chips … as a
substitute for tabs"*). Meanwhile the reasoning is *practised* and never codified —
`docs/app/Route/Examples/DetailedView.elm` documents five separate substitution decisions inline
(status/gesture bar = "no Material equivalent"; `thumbnail` = card borrowed as a media tile;
`thumbnailIcon` = plain div *because* `ListItem`'s leading slot's kind row rejects `card`;
`playerRow` = bespoke row because `ListItem`'s trailing slot can't host an icon-button; body copy
classless because `Heading` carries no body role). That file is the best available specification
for the missing KB page.

---

### C3 — The kit is the real problem: generate the Figma library from the CEM

**Mechanism.** Instead of borrowing the closest M3 Community Kit component, generate a Figma
library whose component sets, variant axes, and — decisively — **slots** are 1:1 with the CEM.
The CEM enumerates slots (`VISION.md` describes `cem-facts.json` as
*"tags/attrs/enums/**slots**"*), and the Figma side has the primitives to realize them:
`figma.createComponent()`, `combineAsVariants`, `addComponentProperty`, and `createSlot()` (which
auto-wires a `SLOT` property, one per CEM slot).

Consequences: F2's coverage invariant becomes **satisfiable**; Code Connect bindings exist **by
construction**; and D1 becomes *structurally impossible* because there is no closest-match
borrowing left to do.

**Drift fixed.** All four, at the root.

**Cost.** **HIGH.** A generated design library is a major deliverable — plus the visual-design
work to make it not look generated, plus ongoing versioning.

**Risks / downsides.**
- You now own a design system inside Figma, with all the version-cascade pain that implies.
- **Adoption is the real killer:** designers want Google's M3 kit, not your mirror. A perfectly
  lossless library nobody designs in is worth nothing.
- It does **not** violate `plans/01-architecture.md` § 1(C)'s rejection of Figma-as-spine — the
  CEM stays the spine and Figma becomes a *generated projection*, which is precisely consistent
  with the standing principle *"Generated code is the specification. Never hand-edit an emitted
  file to make a gate pass."* Of everything in this menu, this is the most doctrinally aligned
  option. It is also the most expensive.

**Softer variant — C3-lite, the local adapter layer.** Create, in the target file, a thin set of
**local** components that wrap kit instances and add the missing slots (an avatar-less card
wrapper; a card with an above-title slot; a `filter-chip-set` container). This is explicitly
sanctioned by the `figma-generate-design` skill, which makes componentization mandatory rather
than optional: *"For anything the design system does not cover that repeats or maps to a reusable
source component, create a local component once with `figma.createComponent()` and place
instances."* Medium cost. Fixes D2/D3/D4; only partially D1. Risk: a second, shadow design system
that designers didn't ask for and won't maintain — the same adoption risk as C3, smaller.

---

### C4 — Emit the recipe from the code side; don't discover it

**Mechanism.** The write direction should be a **pure function** — `Elm view → composition tree →
Figma build script` — under the same contract as `src/emit/emitter-api.mjs`: *"no fs, no network,
no `process.env`, no `Date.now()`/`Math.random()`, no mutation of ctx/entry"*, byte-stable on
re-run, DRIFT-gated by `src/publish/check.mjs`. Today's Feed build was an agent calling
`search_design_system` per node; the four failures are exactly what per-node improvisation
produces.

The code-side tree already exists and is *not* a new IR. Every `M3e.*` view **is** an
`HtmlIr.Element` — `core/elm-html-intermediate-representation` is the Tier-0 substrate every brand
builds on, and `HtmlIr.Query` already exposes structural accessors built for exactly this kind of
inspection: `tagOf : Node msg -> Maybe String`, `childrenOf : Node msg -> List (Node msg)`,
`keysOf`, `classesOf`. What's missing is small and concrete: an attribute accessor and a slot
accessor (`attrsOf` / `slotOf`), so a recipe extractor can see `slot="media"` and the
`m3e-` tag beneath it.

**Drift fixed.** It's the *delivery mechanism* for C1/C2 rather than a fix in itself — but it is
what turns "the recipe is correct" into "the frame matches the recipe, provably, every time."

**Cost.** Moderate.

**Risks.** Careful against `plans/01-architecture.md` § 1(B), which **rejected** a fresh
source-agnostic IR on the grounds that *"the CEM already is a standardized, tool-supported
interchange format."* The counter: that argument covers the *component vocabulary*, which the CEM
does enumerate. It does not cover *page composition*, which the CEM does not enumerate at all —
and the composition IR already exists as `elm-html-intermediate-representation`, already in the
family table. Nothing new is being minted. Worth having that argument explicitly rather than
tripping over the old decision.

---

### C5 — Port the existing semantic round-trip harness to the Figma direction

**Mechanism.** `brands/m3e/outputs/elm-m3e/docs/scripts/roundtrip/` already implements, for the
raw-HTML → Elm direction, exactly the gate this problem needs — and it is **semantic, not
pixel**:

- `dom-diff.mjs` — canonicalizes both trees (sort attrs, collapse insignificant whitespace,
  normalize boolean-attr form, canonical slot ordering) and produces
  `{ matches, functionalMatches, deviations: [{ kind, path, from, to, cosmetic }] }` with kinds
  `changed-node | changed-text | changed-element | added-attr | removed-attr | changed-attr`.
- A **cosmetic-vs-functional classifier**: `class`/`style` differences are always cosmetic; `id`
  differences are cosmetic *unless the id is referenced elsewhere*; `functionalMatches =
  deviations.every(d => d.cosmetic === true)`.
- `escape-scan.mjs` — inventories the places a conversion had to fall back to a raw-HTML escape
  hatch.
- `verify-roundtrip.mjs` — a two-layer harness (Layer 1 config-join + escape scan; Layer 2 SSR
  render + semantic diff per cell) writing `docs/data/roundtrip-report.json`.

Point the same machinery at (original Elm view → HTML) vs (Figma read-back → Elm → HTML). All four
Feed failures fall out automatically as **functional** deviations: added elements (avatar, menu
button) = D1; changed slot / reordered = D2; `changed-element` rect-vs-`m3e-card` = D3; removed
element = D4.

**Cost.** LOW–MODERATE. Reuse the taxonomy, the classifier, and the cosmetic/functional split
verbatim; the new part is the tree source.

**Risks.** It's a detector, not a fixer. But it turns "structural fidelity" from a vibe into a
number, which is a prerequisite for evaluating every other lever on this list — and for noticing
regressions.

**Novelty.** None. It exists, it's tested (`dom-diff.test.mjs`, `escape-scan.test.mjs`,
`join.test.mjs`), and it's wired into `test:fast`.

**Bonus:** it also already answers the coordinates/grouping question — see § 5.

---

## 4. Conventions as a bridge

Jack asked whether conventions can bridge the gap. They can, but **only** on this repo's terms:
a convention here is real when it has a deterministic checker, and a doc otherwise.

The pattern is mature and worth copying exactly. `tools/check-layout-only-classes.mjs` (491 lines)
enforces "Tailwind is layout-only", and its header states the design rules that make it work:

- **Zero dependencies, <100 ms, no network, no codegen** — so it can run as a Claude Code
  `PostToolUse` hook on *every* Edit/Write, not just at pre-push. Wired in `.claude/settings.json`
  alongside `nudge-m3e-skill.mjs`. The stated reason is directly relevant here: *"Agents write
  violations and present work as 'done' long before that gate fires. This script closes the
  feedback gap."* Today's Feed build is that same failure mode in a different medium.
- **Drift discipline: the taxonomy is not duplicated.** The four keyword/prefix lists are parsed
  at runtime *from the authoritative elm-review rule's own source*, and utility names come from
  the same committed manifest the rule uses. Mirror only stable scaffolding.
- **A documented deliberate subset**, with what it cannot catch spelled out, and the AST rule left
  authoritative.

Sibling precedents for a *cross-artifact* checker: `tools/check-cc-elm-refs.mjs` already gates
every emitted Code Connect snippet's module references against the real `elm-m3e` module set,
offline; `tools/check-coverage-map.mjs` gates an evidence file against a schema and is admirably
clear about its limits (*"A green run only means the evidence file and the schema agree with each
other"*).

There are **two** hook shapes in use, and the write direction probably wants both:

- **Blocking** (`check-layout-only-classes.mjs --hook`): reads the hook JSON on stdin, uses
  `tool_input.file_path`, **exits 2** so the message is blocking feedback to the agent. Internal
  errors `console.error` + **exit 0** — *"never block an edit because THIS script broke."*
- **Non-blocking nudge** (`nudge-m3e-skill.mjs --hook`): pattern-matches (`/\bimport\s+M3e\b/`,
  `/<m3e-[a-z-]+/`, `/@m3e\/web\b/`, …) and emits
  `{ hookSpecificOutput: { hookEventName, additionalContext } }`, always exit 0. Stateless,
  re-nudges every edit by design. Used for conventions where *"no deterministic 'did you look it
  up' check can exist"* — which is exactly the shape of "did you check the ladder before
  substituting a component". (`m3e-okf` also ships its own variant,
  `hooks/m3e-disclosure.mjs`, a one-time PreToolUse disclosure with repo detection — note its
  bundled `settings.*.json` contain a stale path, `/Users/jack/Documents/code/m3e-docs/`.)

The design rationale for all of this is written up at
`docs/plans/2026-08-19-durable-m3e-convention-enforcement.md`, under the lens
*"deterministic-over-nondeterministic — machine gates over stronger prompts."* It names the three
gaps the pattern closes: the **agent-time gap**, the **worktree false-green gap**
(`check-review-guard.mjs` exits 0 in a worktree with no `node_modules`), and the **CI silent-skip
gap** (`REQUIRE_CLONE_GATES=1`). Read it before proposing any new Figma convention; the Feed build
is the agent-time gap in a different medium.

**The proposal, then:** a `tools/check-figma-frame-coverage.mjs` that takes a REST dump of a built
frame (fetched with `plugin_data=shared`, per F1) and asserts the F2 invariant offline and
deterministically — every node bound, slotted, or declared — exit 1 on unbound nodes, with the
unbound list as the report. Plus the cheap precursor from C2's bonus: a checker that crosses an
example screen's own declared component inventory against the binding MANIFEST, needing **no**
Figma access at all. A layer-naming convention doc (F5) ships **in the same commit as its
checker** or not at all.

---

## 5. Coordinates and groupings — what genuinely informs code, and what's a trap

Jack asked directly. The repo already contains a rigorous answer, in `dom-diff.mjs`'s
`canonSlotOrder` doctrine:

> "The light-DOM SOURCE order of children **ACROSS** different slots is not significant — the
> shadow DOM positions each child by its slot … stable-sorting by `orderKeyOf` on BOTH sides
> normalizes that while **PRESERVING order WITHIN a tag/slot (where order genuinely matters)**.
> Only applied to custom elements; plain-HTML child order stays significant."

Translated to Figma:

| Figma signal | Verdict | Notes |
|---|---|---|
| **Child order within one slot** | **Reliable.** Use it. | Maps to list order in Elm. |
| **Child order across slots** | **Not semantic.** | Reading position as order is exactly what produced D2. **Infer position from slot; never infer slot from position.** |
| **Instance boundary** | **Reliable** = component boundary. | Hard, machine-checkable, and the basis of F2. |
| **`SlotNode` boundary** | **Reliable** = slot boundary. | See F3. |
| **Plain frame / group boundary** | **Weak hint only.** | Groups and wrapper frames are created and destroyed casually as layout artifacts; a boundary that exists for spacing reasons is indistinguishable from one that exists for semantic reasons. Treating a frame as a component boundary is how you invent components that aren't in the code — the mirror image of D4. |
| **Auto-layout direction / gap / padding / alignment** | **Legit but low-value.** | Maps to the layout-only Tailwind lane, and is *cosmetic* in the C5 diff sense. Fine to carry; never let it decide identity. |
| **Absolute x/y, width, height** | **Reject as data.** | The trap. See § 6. |

The general rule: **structure informs code only where the structure is itself a declared semantic
boundary** (instance, slot). Everything else is geometry wearing a tree costume.

---

## 6. Rejected: pixel-matching in disguise

Jack asked to see what was ruled out. Six ideas that looked structural and were not.

**6.1 — Visual-diff-driven fidelity ("minimize the screenshot diff").**
The existing D8 visual gate (`src/visual/status.mjs`; publish refuses anything not `pass` or
`approved`) is a legitimate *publish* gate on a bound component's render. But adopting visual
diff as the **definition** of round-trip success is the rejected approach with a respectable
name. Decisive argument: **the Feed build would have passed it.** It looked right. It was the
wrong structure that looked right. Keep it as a supplementary regression check; never as the
fidelity metric.

**6.2 — Figma annotations' `properties` channel.**
`AnnotationPropertyType` is `width | height | maxWidth | minWidth | maxHeight | minHeight |
strokeWeight | cornerRadius | fontSize | lineHeight | letterSpacing | itemSpacing | padding |
layoutMode | gridRowGap | …`. That is a dimension-pinning vocabulary end to end. Using it is
measurement transfer, not semantics. (`labelMarkdown` is separately discussed in F6.)

**6.3 — "Infer the component from the geometry."**
Tempting for D3: a 12px-rounded rect with a surface-container-ish fill and 16px padding *must* be
a card. This is pixel-matching with an inference step bolted on, and it is precisely what the
read-back was reduced to for the media area. It produces confident wrong answers, which violates
*"a name that can't be verified is surfaced as a concern, never guessed."* Reject.

**6.4 — Constraints and layout grids as the correspondence channel.**
Same family as 6.2. Constraints encode resize behaviour. Resize behaviour is not identity.

**6.5 — Reconstructing containers from render-tree bounding boxes.**
The seductive one, because it appears to "recover" D4: the filter chips *do* share a bounding box,
so infer a container. But a container that exists only as a bounding box is indistinguishable from
an accidental alignment, and the inference will fire on things that aren't containers. Reject —
and note that F1's stamp or F3's slot recovers the same information *declaratively*, which is the
whole point.

**6.6 — Hardcoding widths/heights so the read-back emits matching layout classes.**
Named explicitly as the anti-goal. Additionally: it breaks the repo's own layout-only-Tailwind
convention (`tools/check-layout-only-classes.mjs`) and its density/spacing policy
(`docs/density-and-spacing.md`), where spacing authority is **code**, not Figma —
`plans/01-architecture.md` § 1 lists "Spacing/density → **Code** (Figma has no density tokens)".
So this isn't merely inelegant; it inverts a decided authority.

---

## 7. If I had to bet

**My opinion, for the team to weigh — not a decision.**

**Bet 1 — Apply F7 (the token `codeSyntax` stamp), then build F1 (the node stamp).**
F7 is finished, tested, invertible work sitting unapplied, and it directly recovers the token half
of D3 — the failure currently described as "completely unrecoverable". Zero engineering, one human
authorization. F1 then generalizes the *same machinery* (`src/tokens/stamp.mjs`: generated,
name-anchored, idempotent, snapshot-first, with an inverse) from variables to nodes, and the read
path already exists via REST `plugin_data=shared`. Lowest risk, highest recoverability-per-hour.
Caveat to hold onto: a stamp is a claim, not a fact, so it needs the same untrusted-input
discipline the matcher already applies to descriptions.

**Bet 2 — Port C5 (the semantic round-trip harness).**
You cannot manage what you don't measure, and right now "structural fidelity" is a narrative
assembled by hand after the fact. `dom-diff.mjs` already has the right taxonomy *and* the right
cosmetic/functional split, and all four Feed failures fall out of it as functional deviations
without new thinking. It is also the only lever that prevents this class of regression rather than
just fixing today's instance.

**Bet 3 — C2 + C2b + C1: a slot-validated write recipe, governed by a transposed escape ladder.**
C2 is nearly free, and cheaper than I expected before reading the code: the slot contract with
**admitted kinds, multiplicity and declared order** already exists as codegen input
(`brands/m3e/inputs/cem/config/slots.json`), is already mirrored into `Facts.elm` and into
compile-time phantom types, and the recursive slot-validating child tree already exists in
`src/emit/example-content.mjs`. C2b is a document that transposes an already-proven house
policy — the `auditing-m3e-escapes` ladder, including its two clauses that matter most here
(*"a defect, not a style preference"* and *"silence is not a justification"*). C1 wraps both in the
read direction's governance. Together they are the only levers that **prevent** D1/D2/D4 rather
than making them *recoverable*: a recipe validated against `slots.json` cannot elide
`m3e-filter-chip-set`, and a ladder that demands a written reason per escape turns a silent
mis-slotting into a visible refusal.

If forced to pick a single first commit from this bet, it's the smallest possible slice of it:
cross `Feed.elm`'s existing `exampleFooter` component inventory against `figma.generated.json` and
the binding MANIFEST. That is a ~50-line offline checker over checked-in data, and it already
catches D4.

**And the thing I'd want argued explicitly, not decided by default:** the honest long-run answer
to D1 is probably **C3** — generate the Figma library from the CEM so the two vocabularies are
isomorphic and substitution drift becomes structurally impossible. It's the most doctrinally
aligned option in the menu ("generated code is the specification", CEM as spine, Figma as
projection) and it fixes all four drifts at the root. It is also expensive, and its real risk is
not engineering but **adoption**: designers want Google's kit. C3-lite (a local adapter layer of
wrapper components, which the `figma-generate-design` skill already mandates for uncovered cases)
is the pragmatic middle. That's a strategy call for Jack, not an engineering one.

**Finally, a decision to re-open on purpose:** `plans/00-mission-and-decisions.md` **D6** says
*"no Figma authoring in this plan."* On 2026-08-19 we did Figma authoring. Either D6 stands and
the Feed build was out of scope, or D6 is superseded and the write direction gets a model. Leaving
it ambiguous is how the four drifts happened.

---

## 8. Appendix — what already exists, and where

For whoever picks a lever up. All paths relative to the workspace root.

| Thing | Path | Relevance |
|---|---|---|
| Read-direction correspondence schema | `core/cem-figma-connect/src/correspond/schema.json` | The model to mirror for the write direction (C1) |
| Its 5,135-line instance | `core/cem-figma-connect/profiles/m3-kit/correspondence.json` | `axes` / `props` / `unmapped` / `provenance` in practice |
| Merge law + human protection | `core/cem-figma-connect/src/correspond/merge.mjs` | `isProtected`, `proposedUpdate` |
| **Slot contract: admitted kinds, `multi`, `required`, declared order** | `brands/m3e/inputs/cem/config/slots.json` | **C2 — the structural contract, already checked in** |
| Same contract, Elm-side | `brands/m3e/outputs/elm-m3e/src/M3e/Review/Facts.elm` (`slotKinds`, `multiSlots`, `requiredSlots`) + `src/M3e/Internal/Types/*.elm` phantom types | Slot admittance is compile-time enforced, not just linted |
| Slot-validated composition tree | `core/cem-figma-connect/profiles/m3-kit/examples.json` + `src/emit/example-content.mjs` (`validateExamples`) | C2 — the cheapest real foundation |
| **The escape ladder** | `brands/m3e/outputs/elm-m3e/skills/auditing-m3e-escapes/SKILL.md` | **C2b — the policy to transpose**, incl. `## Known library gaps` register |
| Substitution reasoning, practised but uncodified | `brands/m3e/outputs/elm-m3e/docs/app/Route/Examples/DetailedView.elm` (five inline decisions) | C2b — the spec for the missing `m3e-okf` page |
| Per-screen component inventory | `brands/m3e/outputs/elm-m3e/docs/app/Route/Examples/Feed.elm` (`exampleFooter`) | C2 bonus — a free coverage oracle |
| Deliberately-unbound tags | `core/cem-figma-connect/docs/coverage-and-gaps.md` ("evaluated & skipped"); `brands/m3e/inputs/cem/config/figma.generated.json` (no `FilterChipSet`) | § 1.3b — read-side decision, write-side hazard; ~79 tags in the web-components-only crescent |
| `SLOT` captured but unmapped | `core/cem-figma-connect/src/ingest/figma-export.schema.json` | F3 — a documented gap in this repo's own schema |
| Variable `codeSyntax` stamp generator | `core/cem-figma-connect/src/tokens/stamp.mjs` + `profiles/m3-kit/stamp/` | F7 (apply) and F1 (generalize) |
| Emitter purity contract | `core/cem-figma-connect/src/emit/emitter-api.mjs` | C4's contract |
| Determinism / drift gate | `core/cem-figma-connect/src/publish/check.mjs` | C4's gate |
| Visual gate | `core/cem-figma-connect/src/visual/status.mjs` | § 6.1 — keep, but don't promote |
| "A wrong binding is worse than none" | `core/cem-figma-connect/docs/upstream-requests.md` (U3) | The doctrine the write direction lacks |
| Semantic round-trip harness | `brands/m3e/outputs/elm-m3e/docs/scripts/roundtrip/` (`dom-diff.mjs`, `escape-scan.mjs`) + `scripts/verify-roundtrip.mjs` | C5, and the § 5 order rule |
| Convention-checker pattern | `tools/check-layout-only-classes.mjs`, `tools/check-cc-elm-refs.mjs`, `tools/check-coverage-map.mjs`, `.claude/settings.json` | § 4 — what makes a convention real here |
| Composition IR | `core/elm-html-intermediate-representation/src/HtmlIr/Query.elm` | C4 — `tagOf` / `childrenOf` exist; `attrsOf` / `slotOf` don't |
| Figma Plugin API typings | `~/.claude/plugins/cache/claude-plugins-official/figma/<v>/skills/figma-use/references/plugin-api-standalone.d.ts` | `PluginDataMixin` L5459, `Annotation` L7976, `DevResourcesMixin` L5490 |
| Slot / component-property recipes | `…/figma-use/references/component-patterns.md` § Slots, § INSTANCE_SWAP | F3, C3 |
| Code Connect template composition | `…/skills/figma-code-connect/SKILL.md` (`getSlot`, `findConnectedInstance`, `executeTemplate`, `metadata.props`) | F2 — why a bound tree evaluates deterministically |
| Today's write-direction frictions | `~/.claude/frictions/2026-08-19-figma-feed-roundtrip-code-to-figma.md` | F-01 variant-swap ID invalidation, F-02 silent FILL no-op, F-03 same-name-different-component |
