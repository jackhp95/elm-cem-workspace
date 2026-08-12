# Facts-bundle coverage audit (M1.b)

> **Status:** audit complete, specification proposed. Authored 2026-08-12.
> **Scope:** the de-risking task of the Phase-0 spine
> (`docs/superpowers/specs/2026-08-12-elm-cem-workspace-spine-design.md` §4 and §10).
> **Companions:** `coverage-map.json` (the machine-readable evidence, 145 cited entries),
> `schema.json` (the proposed bundle schema), `tools/check-coverage-map.mjs` (the consistency gate).

## 1. Verdict

**Yes — every consumer can fully drop its CEM parser, and cem-figma-connect can delete its
Elm re-parser. Two consumers keep a NON-CEM layer that was never a CEM parser to begin with,
and one of those layers is larger than the design spec implies.**

Precisely:

| Consumer | Can drop its CEM/Elm parser? | What it keeps, and why |
|---|---|---|
| **m3e-okf** | **Yes** — `scripts/extract.mjs`'s manifest parsing, its hand-ported `reconcileTagNames` (lines 47-88) and its TypeScript alias scanner (lines 144-164) all go | Keeps an **upstream-source layer**: README parsing + the README-vs-CEM drift audit (a thin layer over the bundle — §5.1) **and** the `:host` `display` derivation, which reads element CSS out of `packages/web/src/**/*.ts` (**a real gap** — §5.3) |
| **tailwind-m3e-web** | **Yes** — `bin/generate-component-utilities.mjs` loses its manifest read entirely | Keeps its own Tailwind type inference (not a CEM fact — the manifest declares no syntax for these vars) and `src/density.css`, which is hand-authored from `dist/core.js` runtime behaviour, **not** from the CEM (§5.4) |
| **cem-figma-connect (matcher)** | **Yes** — `src/ingest/cem.mjs` + `src/ingest/dts-inline.mjs` both go, and the vendored `test/fixtures/m3e-web-*` CEM copies with them | Nothing. All 39 audited reads map to Face B. Migrating **fixes a live bug**: it currently loses the `m3e-stepper-next` element (§5.5) |
| **cem-figma-connect (Elm emitter)** | **Yes** — `profiles/m3-kit/emitters/elm-facts.build.mjs` (995 lines) and the committed `elm-facts.json` both go | Keeps the userland seams (`textSeam`/`htmlSeam`/`attrSeam`) as **profile config**, which is where they already are and where they belong (§6) |

Nothing a consumer reads from the CEM is unrepresentable in Face B. Nothing the Elm re-parser
measures is unknown to elm-cem — but **Face C requires elm-cem to surface five families of fact
it currently computes only as a side effect of emitting code**, and along the way the audit found
**three facts the re-parser currently gets WRONG** (§7). The exceptions in `coverage-map.json`
are 14 of 145 entries, and not one of them is a CEM fact.

## 2. Method and audited states

Every claim below is cited to `file:line` in the consumer's own repo. Where a claim is a
*measurement* (a count, a coverage figure, a behaviour), it was produced by running the real code
against the real inputs, read-only.

| Repo | State audited |
|---|---|
| m3e-okf | `main` @ `8275e26`; evidence also from its committed `data/components.json` + `data/report.md` (pinned upstream SHA `a2844143`) |
| tailwind-m3e-web | `main` @ `e4f9767`; installed `@m3e/web` **2.5.11** (declared `^2.5.14`) |
| cem-figma-connect | `main` @ `6294992` (as instructed); CEM fixture `test/fixtures/m3e-web-2.7.0` (458 `.d.ts` files) |
| elm-cem | in-workspace `packages/elm-cem` (`bin/elm-cem.js`, `codegen/**`, `facts/src/Cem/Facts.elm`) |

No file under `/Users/jhp/code/jackhp95/{m3e-okf,tailwind-m3e-web,cem-figma-connect}` was
modified; `git status --porcelain` is empty in all three.

## 3. What the two faces must be

**Face B (`cem-facts.json`)** is the reconciled, `.d.ts`-resolved projection of the CEM. Three
things distinguish it from "the manifest, as JSON":

1. **It is post-reconciliation.** Tags come from the `custom-element-definition` registration
   export, not the jsdoc `decl.tagName`. Two repos implement this today
   (`m3e-okf/scripts/extract.mjs:47-88`, `packages/elm-cem/bin/elm-cem.js:258-317`) and one does
   not — which is why cem-figma-connect silently loses an element (§5.5).
2. **It is post-inlining.** Enum unions are already resolved from the shipped `.d.ts` tree, and
   the resolution is *described* (`type.aliasName`, `type.source`, `enum.open`) rather than merely
   applied, because two consumers need two different readings of the same union (§5.2).
3. **It is deduped, and says what it dropped** (`duplicates[]`), so no consumer re-derives a
   dedupe decision or loses an element to one.

**Face C (`elm-api-facts.json`)** is the API projection elm-cem *emitted*. It is keyed by CEM tag,
so Face B and Face C join with no name derivation — today the re-parser has to invent the tag by
kebab-casing an Elm noun (`elm-facts.build.mjs:684`), which is wrong by construction for grouped
components and for any renamed one.

Both faces carry a **provenance stamp** (`schema.json` → `faceBProvenance`, `faceCProvenance`).
It replaces four scattered pins: m3e-okf's `data/sources.json` SHA, elm-m3e's npm range,
cem-figma-connect's fixture version + `elmM3eCommit` + `elmM3eSentinel`, and tailwind's
declared-vs-installed drift. The stamp deliberately carries **both** the resolved npm version and
the upstream VCS SHA, because today a git SHA (`a2844143`) and a semver range (`^2.7.3`) are not
comparable without resolving one of them.

## 4. Consumer-by-consumer

Full field-level evidence is in `coverage-map.json`; this section states the shape and the
non-obvious parts.

### 4.1 m3e-okf — 53 entries (44 mapped, 9 exception)

`scripts/extract.mjs` merges three sources: the CEM (ground truth), the upstream TypeScript
source, and the README. Only the first is a bundle concern.

**From the CEM (all mapped):** the registration-export tag scan (67-88); `modules[].path` (92) and
its `[1]` segment as the card key (95); `decl.customElement` (99); `parsedType.text || type.text`
(123); `decl.attributes[]` with `name`/`default`/`description` (474, 491); `decl.description`
(501); `decl.members[]` as JS-only props, filtered on `kind`/`privacy`/`name`/`attribute`/
`description` and carrying `type`/`default`/`readonly` (291-309 — **331 properties emitted at the
pinned SHA**, so this surface is load-bearing, not theoretical); `decl.slots[]` (507);
`decl.events[]`, filtered to those with a resolvable name (511-513); `decl.cssProperties[]` (514);
`decl.cssParts[]` (515 — zero at the pinned SHA, but the field must exist for the parser to be
deletable); and the pinned SHA itself, read out of `.cache/m3e/.git/HEAD` (109-119).

**Two derived catalog fields stay okf-side but are bundle-derived:** `navigable` (a one-line
`href` predicate, 495 — 13 elements) and `summarizeCssProps`'s `[size]`/`[variant]` family
collapse (317-343). The collapse is marked `exception` on purpose: its `SIZE`/`VARIANT` token sets
and its "`text` is too ambiguous to collapse" carve-out are m3e-okf's editorial choices about card
rendering, and tailwind-m3e-web groups the *same* variables differently. Freezing one consumer's
taxonomy into the shared artifact would be a mistake; both consumers read `cssProperties[].name`
and `.description` and summarise as they see fit.

**The alias scanner (144-164) maps to `faceB.aliases`** — with one nuance that turns out to be the
highest-value detail in the whole audit, treated in §5.2.

### 4.2 tailwind-m3e-web — 12 entries (9 mapped, 3 exception)

The narrowest consumer: `bin/generate-component-utilities.mjs:125-168` walks
`manifest.modules[].declarations[]`, keeps `kind === "class"` declarations with a non-empty
`cssProperties` (131), groups by `decl.tagName || decl.name` (132), and reads `decl.description`
(133) plus each `prop.name` (136) and `prop.description` (137). Measured on the 2.7.0 manifest:
**2877 cssProperties rows across the component set — 2781 `--m3e-*` and 96 `--md-*`.**

Two things to flag:

- The grouping key at line 132 is the **raw, unreconciled** `tagName`, so today the generated
  `CSS_CUSTOM_PROPERTIES.md` mislabels the sections for the two declarations whose jsdoc tag
  collides with a sibling's, and the `prev`-merge branch at 155-163 exists only to paper over
  duplicate keys. Face B's reconciled, deduped component list deletes both problems.
- `inferType()` (105-112) is an `exception` and should be: the manifest declares **no** syntax and
  **no** default for any cssProperty (measured: zero entries carry either field in 2.7.0), so
  there is nothing upstream to publish. `faceB…cssProperties[].syntax` exists for a future
  manifest that does declare `@property` syntax; until then the suffix inference is correctly
  Tailwind's own.

Density is the other exception, and the design spec overstates it — see §5.4.

### 4.3 cem-figma-connect (matcher) — 39 entries, **all mapped, zero exceptions**

`src/ingest/cem.mjs` + `src/ingest/dts-inline.mjs` are the cleanest deletion in the family. The
loader's whole output shape is Face B's shape: `tag` (83), `description` (107), `module` (86),
classified `attributes` (91-102), and verbatim `slots`/`events`/`cssProperties` (110-112). Its
`classifyAttribute` taxonomy (51-77) maps onto `attributes[].kind`; measured on the 2.7.0 fixture:
**boolean 194, enum 109, string 193, number 41, none 33, other 7.**

Downstream, the reads are narrow and all covered: the matcher needs `tag` (matcher.mjs:79),
enum attributes with their `values` (:91), boolean attributes (:95), `slots[].name` (:316), the
enum's quote-wrapped `default` as a fusion fallback (:438), and `description` for the fuzzy
jaccard and doc-URL signals (:471, :474). The gap report needs `tag`/`description` (:96-100),
attribute lookup by name (:135), the full enum value list for its cartesian spine (:151-154), and
the component count (:299). `emitter-api.mjs:170` and `merge.mjs:417` need only the tag.

Note on the design spec's phrase "keyword/synonym descriptions used for fuzzy matching": there is
no synonym field in the CEM. The synonym table (`foldIdentity`, `DESCRIPTION_UNTRUSTED`) is
matcher-local heuristic data; the only upstream input is `description`, which Face B carries in
full (not just the summary line — the jaccard needs the whole text).

### 4.4 cem-figma-connect (Elm emitter) — 41 entries (39 mapped, 2 exception)

Two files: the 995-line `elm-facts.build.mjs` that *measures* facts out of a local elm-m3e
checkout, and `elm.mjs` that *reads* the resulting `elm-facts.json`. The audit covers both — the
brief's bar is that everything the re-parser measures must be in Face C, not merely everything the
emitter happens to read today.

The emitter's actual read set is small and exact: `FACTS.components[tag]` (elm.mjs:466, :561),
then per component `module` (:486), `enums` (:138) with each value's `elm`/`key`/`token`
(:147, :156), `setters` (:176), `setterArgTypes` (:203, :426), `actionModule` (:263, :369),
`tokenModule` (:360, :401), `slotSetters` (:128, :408) and `surfaces[key]`'s
`module`/`entry`/`form`/`finalizer` (:284-285, :300, :337); plus top-level `surfaceKeys` (:565)
and `defaultSurface` (:969). Every one maps to Face C.

The *measurement* side is where the findings are (§7): a token-module discovery heuristic (:637),
an exposing-list verification of every setter and token (:744-769), an Elm-type-annotation regex
for argument kinds (:492-525), a file-path convention for surfaces (:816), an entry-name guess
(:830), a finalizer guess (:839), a hardcoded facet→call-shape table (:439), and — for group
components — parsing constructor bodies and doc comments to recover CEM tags (:565-579). All of it
is elm-cem stating what it emitted, once Face C exists.

## 5. The risks, as first-class sections

### 5.1 Risk (pre-flagged): m3e-okf's README-drift provenance

**Verdict: it stays a THIN LAYER OVER the bundle. Not in it. This is the right call, and it does
not block m3e-okf dropping its parser.**

`verify()` (`extract.mjs:407-453`) compares README attribute tables against the manifest and emits
`DEFAULT-MISMATCH`, `DEFAULT-UNDOCUMENTED`, `UNDOCUMENTED` and `README-only`; a second pass emits
`EXAMPLE-DRIFT` by validating README HTML examples against ground truth (566-573). Measured at
okf's pinned SHA (`data/report.md`): **DEFAULT-UNDOCUMENTED 41, UNDOCUMENTED 44,
DEFAULT-MISMATCH 11, CEM-TAG-MISMATCH 1.**

Decompose the inputs:

- The **CEM side** is entirely bundle fields: `attributes[].default` verbatim-with-quotes (which
  is what `norm()`/`blank()` at 430-432 expects), `attributes[].name` for the undocumented sweep
  (449), and `tag`/`attributes[].name`/`slots[].name` for the example ground truth (566).
- The **README side** is upstream markdown that only m3e-okf reads — and that `extract.mjs`'s own
  fidelity rule (lines 3-6) declares explicitly *not* ground truth.

Putting the findings in the bundle would therefore require the producer to parse an upstream README
it has no other reason to read, and would promote one consumer's editorial policy — which tables
count as Attribute tables (412), whether a blank default is a soft or hard finding (433-443), how
em-dashes and backticks normalise (430-431) — into a shared fact every consumer inherits. The
provenance report is *m3e-okf's product*. The bundle's job is to make its CEM half a read instead of
a parse, and it does.

One piece of provenance **does** move into the bundle, because it is not README-derived at all:
`CEM-TAG-MISMATCH`. It is a fact about the analyzer, the producer already computes it
(`bin/elm-cem.js:301-308`), and publishing it as `faceB.tagReconciliation.mismatches[]` is what
lets m3e-okf delete its hand-port of `reconcileTagNames` and still render the finding.

### 5.2 Risk (pre-flagged): the `.d.ts`-resolved enum unions

**Verdict: representable — but only if the bundle publishes the resolution as data
(`type.aliasName`, `type.source`, `enum.values`, `enum.open`) rather than just applying it. Two
consumers deliberately disagree about the same union, and a single resolved string cannot serve
both.**

The evidence. m3e-okf resolves aliases from the upstream **`.ts` sources**
(`extract.mjs:144-164`); cem-figma-connect and elm-cem resolve from the shipped **`.d.ts`**
(`dts-inline.mjs:46-72`, `bin/elm-cem.js:721-771`). Measured coverage:

- m3e-okf's committed `data/components.json`: **544 attributes, `typeSource` = `cem` 525, `ts` 19,
  `readme` 0.** The README fallback (136, 484-489) is dead at this pin.
- Those 19 are exactly two aliases: `FormSubmitterType` on 8 `type` attributes and `LinkTarget` on
  11 `target` attributes.
- Running cem-figma-connect's loader on the 2.7.0 fixture: **87 aliases collected from 458 `.d.ts`
  files; 109 attribute rows fully inlined.** `FormSubmitterType` resolves identically
  (`"button" | "submit" | "reset"`). **`LinkTarget` does not resolve at all** — its union ends in
  `(string & {})`, which the literal-member regex (`dts-inline.mjs:50-52`) correctly refuses, so
  `m3e-button`'s `target` classifies as `kind: "string"`.

That refusal is deliberate and documented (`cem.mjs:44-50`: any frame name is legal, so String is
the *correct* classification). But m3e-okf wants the opposite reading — it normalises
`(string & {})` → `string` (`extract.mjs:155`) and publishes
`"_self" | "_blank" | "_parent" | "_top" | string` on the card, because an agent reading the card
needs to know those four names.

Both are right. So Face B carries the union **and its openness**:

```json
{ "name": "target", "kind": "string",
  "type": { "raw": "LinkTarget", "resolved": "\"_self\" | \"_blank\" | \"_parent\" | \"_top\" | (string & {})",
            "aliasName": "LinkTarget", "source": "dts-alias" },
  "enum": { "values": ["_self", "_blank", "_parent", "_top"], "open": true } }
```

The matcher reads `kind` and never treats it as an axis. m3e-okf reads `enum.values` (or
`type.resolved`) and renders the member list. Neither re-parses anything. Values are specified in
**declaration order**, because the matcher's overlap scoring and the gap report's cartesian both
walk that order.

**A second, sharper risk surfaced here, and it is not in the design spec.** `.d.ts` availability is
not a property of `@m3e/web`; it is a property of the *publish*. The `@m3e/web` installed in
tailwind-m3e-web today — **2.5.11** — ships **zero `.d.ts` files** (its `dist/` is 248 files of
`.js`/`.map` only), while the 2.5.14 and 2.7.0 fixtures ship 440 and 458. Under the current
architecture a bump onto such a version silently degrades **every** enum to `String` — no error,
just a much poorer API. Mitigation, cheap and in the producer: publish
`faceB.provenance.dts.fileCount`, `faceB.stats.aliasesCollected` and
`faceB.stats.attributesResolvedFromAlias`, and let the `bump` gate fail when
`attributesResolvedFromAlias` collapses. That turns the family's most silent failure mode into a
red gate.

### 5.3 Finding (not pre-flagged): m3e-okf's `display` cannot come from the bundle

`displayFor()` (`extract.mjs:248-265`) derives each element's resting `display` by finding the
first bare `:host { … display: X }` in the element's TypeScript `css` template literal
(`hostDisplayFrom`, 219-234), chasing relative style barrels and same-dir base classes to depth 3
(`relatedTsFiles`, 197-210), and falling back to a hand-authored overlay
(`data/display-overlay.json`) for elements whose `:host` lives behind a non-relative base class.
**All 116 elements in `data/components.json` carry a display value** (sources: `ts` and `overlay`).

This is neither a CEM fact nor a `.d.ts` fact: it lives in element CSS inside `.ts` sources that
the npm package does not even ship. elm-cem never reads element CSS, so the producer cannot know
it, and inventing a "display" field would mean the producer growing a CSS parser for one
consumer's catalog.

**Consequence, stated plainly:** m3e-okf drops its CEM parser but keeps a TypeScript-source layer
and its `matraic/m3e` clone. The spine's claim — "each consumer deletes its own CEM parser" —
holds. The broader reading — "m3e-okf stops reading upstream sources" — does not, and the
migration plan (spine design §7) should say so rather than discover it at Step 3.

### 5.4 Finding: tailwind's "density tokens" are not CEM facts

The design spec lists tailwind-m3e-web as reading "`cssProperties` (the `--md-*` surface) + density
tokens". The first is true (though the surface is overwhelmingly `--m3e-*`: 2781 vs 96 `--md-*`).
The second is not: **`src/density.css` is hand-authored**, and its own header documents that the
behaviour was read out of `@m3e/web`'s compiled `dist/core.js` `DensityToken` runtime
(`calc(max(minScale, --md-sys-density-scale) * size)`). No script in the repo reads density from a
manifest — `custom-elements.json` appears only in `bin/generate-component-utilities.mjs` and one
test. Density is a runtime contract in compiled JS, outside both the CEM and the `.d.ts` surface;
representing it would require the producer to parse `dist/core.js`, which Phase 0 explicitly does
not do (token-tier/density hardening is Phase 4). Recorded as an `exception`, and the spec's
phrasing should be corrected.

### 5.5 Finding: migrating cem-figma-connect's matcher onto Face B fixes a live bug

`src/ingest/cem.mjs:83` filters on the raw `decl.customElement && decl.tagName`, with no
registration reconciliation. Running the real loader on the 2.7.0 fixture:

- `uniqueTags: 128`, and `dupes: ["m3e-stepper-previous"]`;
- `m3e-stepper-next` is **absent** from `components`;
- the manifest contains **130** `custom-element-definition` exports, and `m3e-stepper-next` is one
  of them.

So the corrupt jsdoc tag makes `M3eStepperNextElement` masquerade as `m3e-stepper-previous`, the
keep-first dedupe drops it, and one real element vanishes from matching, gap reporting and
emission. Face B is post-reconciliation, so the element reappears. **This is a behaviour change in
the consumer's favour, and it will move `correspondence.json` / `gap-report.md`** — the migration
step must expect a non-empty diff there and not read it as a regression. (m3e-okf and elm-cem both
already reconcile; tailwind does not, but its symptom is a mislabelled doc section, not a lost
element.)

## 6. The userland seams are NOT bundle facts

`textSeam` = `Kit.text`, `htmlSeam` = `TypedHtml`, `attrSeam` = `Native` are **config-declared
userland conventions, not library exports, and must not be modelled as bundle facts.**

The evidence is in the re-parser's own design. `resolveTextSeam()`
(`elm-facts.build.mjs:375-419`) is the one place the script's cardinal "never record an unverified
name" rule is deliberately suspended, because there is no `exposing` list to verify against:
post-review elm-m3e's `M3e/Element.elm` states that text/link/label are config-declared,
generator-typed, userland-filled seams, and `docs/kit/Kit.elm` is a *documentation* example, not
library `src/`. A consuming project supplies its own Kit-shaped module. `htmlSeam`/`attrSeam` are
already correctly outside `elm-facts.json` entirely — they live only in
`profiles/m3-kit/profile.json:25`.

Modelling any of them as a bundle fact would assert that the generated library exports something it
deliberately does not. They stay profile config; what disappears with the re-parser is only the
corroboration grep, whose provenance note becomes unnecessary once every *other* name in Face C is
produced rather than measured.

## 7. Face C: what elm-cem already knows, what it must SURFACE, and what the re-parser gets wrong

For each Face-C field, elm-cem's own home:

| Face-C field | Where elm-cem knows it |
|---|---|
| `component`, `module`, `enums`, `slotSetterMap`, `slotUpgrades`, `requiredSlots`, `multiSlots`, `slotKinds`, `requiredAttrs`, `actionMap`, `usesAction`, `groupConstructors` | Already emitted as data: `Cem.Facts.Fact` (`facts/src/Cem/Facts.elm:61-76`), written by `Emit.factsModule` (`codegen/Generate/Phantom/Emit.elm:4989-5098`) |
| `lib`, `rootNamespace` | `Brand.lib` (`Generate/Phantom/Model.elm:401`) |
| `cemTag` | `Comp.tag` (`Model.elm:343`) — the authoritative tag, post-`reconcileTagNames` (`bin/elm-cem.js:258`) |
| `module` for a home-grouped component, `memberPrefix` | `memberRef` (`Emit.elm:4605-4623`) |
| `tokenModule` | `valuesModule`, emitted as `[lib, "Values"]` (`Emit.elm:4182`, `:4348`), and **omitted entirely** when the brand mints no unions (`:89-94`) |
| `actionModule` | `actionModule` (`Emit.elm:5271`), whose exposing list includes `none` (`:1057`) |
| `enums…elm` (token identifiers) | `Naming.tokenIdent` (`codegen/Naming.elm:199`), including the leading-underscore→trailing-underscore rule |
| `enums…raw` (the HTML value a token renders) | `Brand.tokenValues` (`Model.elm:445`) — **only** the producer has this; a config `attrTypes` MAP override can make identifier and payload differ |
| `setterArgTypes` | `Attr.AttrType = ABool \| ANumber \| AInt \| AEnum \| AEnumNum \| AEnumMap \| AString \| ASkip` (`codegen/Attr.elm:80-88`) |
| `surfaces{}.module` / `.entry` / `.form` / `.finalizer` | The emitter's own file layout: `compModule` (`Emit.elm:2363`), `htmlModule` (`:3445`), `buildModule` (`:2314`), and the exposing groups at `:2528-2551` |
| `pipeSetters`, `eventHandlers` | `attrPipeNames` / `slotPipeNameOf` (`Emit.elm:2486-2526`) and `handlerName` / `Brand.resolvedEventHandlers` (`Model.elm:408`) |

**Nothing needed for Face C is unknown to elm-cem.** Five families, however, are today *internal
to codegen* and must be surfaced as emitted data — this is the concrete work item M1.c inherits:

1. **The per-facet module + entry + form + finalizer table.** Known only as the shape of the files
   the emitter writes.
2. **`setterArgTypes`.** `Attr.AttrType` never leaves the generator.
3. **The exposed-setter / exposed-token sets.** Implicit in `exposeGroups`.
4. **`tokenModule` / `actionModule` / `memberPrefix`.** Emitted as module names, never stated as data.
5. **`enums…raw` (`tokenValues`).** Brand-wide today, needs to be joined per token.

### Three facts the re-parser currently gets WRONG — the argument for Face C, in evidence

These are not hypotheticals; they are measurements over the committed
`profiles/m3-kit/elm-facts.json` (129 components, pinned to elm-m3e `336e7242`) read against what
elm-cem actually emits.

1. **The surface file-path convention does not exist.** `elm-facts.build.mjs:816-818` derives each
   non-Standard surface as `src/M3e/<Facet>/<Component>.elm`. elm-cem emits no such tree: there is
   one per-component module, **one** per-brand `M3e.Html` holding every loose constructor
   (`Emit.elm:3445-3478`), and `M3e.Build`. Consequence: **all 129 components in the committed
   facts have exactly one surface (`top`)**; every other facet was skipped-with-concern. The
   `raw`/`html`/`record`/`build` surfaces the emitter advertises are unreachable — and a
   re-measuring consumer cannot distinguish "the producer did not emit this facet" from "my guessed
   path was wrong".
2. **The finalizer is wrong.** `:839` records `finalizer: "build"` whenever the module exposes
   `build` — so all 129 entries say `build`. But `build` is the pipeline **seed**; `toElement`
   closes it (`Emit.elm:2351`, re-exported per component at `:2536`). An emitter that used this
   fact to render `… |> M3e.Button.build` would emit Elm that does not compile. It has not bitten
   yet only because every reachable surface is `double-list`, which never reads the finalizer.
3. **The grouping model diverges.** The builder's group machinery
   (`measureGroupAliases`, `:542-626`) reconstructs variant groups by parsing constructor bodies
   for a qualified delegate call and cross-checking a doc comment. Today's phantom emitter
   hardcodes `groupConstructors = []` (`Emit.elm:5086`) and expresses multi-tag-one-module
   grouping differently — as *home* modules with a member prefix (`homeOf`/`memberRef`). So ~85
   lines of body-parsing are dead against current output, and the *live* grouping mechanism has no
   representation in `elm-facts.json` at all. Face C models both (`group`/`groupConstructors` for
   the `Cem.Facts` contract, `memberPrefix` for home grouping).

Two lesser observations, same root cause: `cemTag` is *derived* by kebab-casing an Elm noun
(`:684`) rather than read; and the `M3e.Token` staleness sentinel (`:117-137`) exists purely
because a re-measuring consumer cannot otherwise tell a pre-rename checkout from a post-rename one
— exactly what the provenance stamp replaces (spine design §9).

## 8. Reading the coverage map

- 145 entries; **131 mapped, 14 exception**.
- Per consumer: m3e-okf 53 (44/9), tailwind-m3e-web 12 (9/3), cem-figma-connect matcher 39 (39/0),
  cem-figma-connect Elm emitter 41 (39/2).
- Every exception is one of four honest kinds, and **none is a CEM fact**:
  1. **Not derivable from the CEM or `.d.ts`** — m3e-okf's `display` + its overlay, tailwind's
     density CSS and private-var check, m3e-okf's README prose and README paths.
  2. **A thin layer over the bundle** — m3e-okf's README-drift findings and `EXAMPLE-DRIFT`; its
     cssProperty family summariser.
  3. **A consumer-specific projection** — tailwind's Tailwind-v4 type inference.
  4. **Config-declared userland convention** — `textSeam`, `htmlSeam`, `attrSeam`.
- Where an entry's mapping implies a **behaviour change**, the note says so: the recovered
  `m3e-stepper-next` (matcher), the corrected tag labels (tailwind), the corrected finalizer and
  the now-reachable non-`top` surfaces (Elm emitter).

## 9. The checker, and what it does not prove

```
node tools/check-coverage-map.mjs
```

Fails loudly when: the map is missing/malformed/empty; a `mapped` entry lacks a `face` or has an
empty `bundleField`; an `exception` entry has a `face` or lacks a substantive `note`; any of the
four consumers is absent; any `bundleField` fails to resolve to a real property path in
`schema.json`; or `schema.json` is invalid JSON or lacks a provenance-stamp field. It prints the
totals and the per-consumer breakdown.

Verified red-team: twelve deliberate corruptions of *copies* of the two inputs (malformed JSON,
missing file, zero entries, `mapped` with `face: null`, `mapped` with an empty `bundleField`,
`exception` without a note, `exception` with a face, a deleted consumer, a nonexistent
`bundleField`, map-syntax applied to an array, and each of the two provenance-stamp fields removed
from the schema) each exit nonzero with a message naming the entry and the problem; the restored
copies pass.

**What it cannot prove**, and what a reviewer must therefore check by hand: that a cited line
really reads the field the entry claims; that a `mapped` entry is honest rather than aspirational;
and that no field was omitted from the map entirely. The checker is a floor — internal consistency
between the evidence and the schema — not a proof of truth.

## 10. What this hands to M1.c

1. Emit **Face B from `bin/elm-cem.js`**, not from the Elm generator. The JS wrapper already loads
   the CEM, reconciles tags (`:258-317`) and inlines `.d.ts` aliases while *recording* the alias
   name (`:608-685`) — it is holding the exact post-reconciliation, post-inlining, provenance-aware
   object Face B specifies. `codegen/Cem.elm` decodes every field Face B needs (attributes,
   members, slots, events, cssProperties, cssParts, cssStates, superclass, exports), so the Elm
   side is a viable alternative; the JS side is simply where the data already is.
2. Emit **Face C from `Generate.Phantom.Model.Brand`**, alongside `Review.Facts`, from the same
   projection — so the two can never disagree. Surface the five internal families from §7.
3. Add the producer-side assertions §5.2 argues for
   (`provenance.dts.fileCount`, `stats.aliasesCollected`, `stats.attributesResolvedFromAlias`),
   so a `.d.ts`-less publish is a red gate rather than a silent downgrade.
4. Expect and account for the three behaviour changes in §8's last bullet when each consumer is cut
   over; each is a real diff in a committed artifact, and each is an improvement.
5. Correct two statements in the spine design when it is next touched: tailwind's density tokens are
   not CEM-derived (§5.4), and m3e-okf keeps an upstream TypeScript-source layer for `display`
   (§5.3).
