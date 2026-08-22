# elm-typed-svg — SVG 2 API-vs-spec coverage audit

**Date:** 2026-08-21  
**Plan:** `docs/plans/2026-08-21-svg-api-spec-audit-plan.md` (Tasks 0–2 executed; Tasks 3–5 not run — this audit is read-only).  
**Artifacts:** `docs/svg-audit/spec-index.json` (SPEC, schema-validated), `docs/svg-audit/modeled-index.json` (MODELED), this report (DIFF + disposition per entry).  
**Spec of record:** SVG 2 (W3C Candidate Recommendation), cross-checked against MDN. Scope buckets per plan §1.

## 0. Baseline note (Task 0)

`GATE_ALL_CONCURRENCY=1 node tools/gate-all.mjs` on this fresh worktree was initially **RED for the trivial reason that the worktree had no `node_modules`** (every package failed identically: `run-p: command not found` / `elm: No such file or directory` / `spawn ENOENT`). After `pnpm install --frozen-lockfile` the gate went to **54/57 passed, 1 skipped (chronic okf clone-gate), 2 failed**. Both failures are `elm-cem-figma-connect` (a pre-existing 225-file emit-drift in its Web-Components output, unrelated to SVG, present on the branch before this audit). **`elm-typed-svg: check` and `elm-typed-svg: test` both PASS.** Tasks 1–2 are read-only and touch no package code, so the pre-existing figma-connect drift does not affect this audit. Log: `/tmp/svg-audit-baseline-gate.log`.

## 1. Headline numbers (SPEC vs MODELED)

| axis | SPEC (SVG 2, live-fetched 2026-08-21) | MODELED (current package) | gap |
|---|---|---|---|
| elements | **69** | **27** | 42 missing, 0 extraneous |
| presentation properties | **45** (41 core + 4 filter-scoped) | 24 present | 21 missing |
| finite-enum presentation props | **21** | **6** typed | 15 un-typed or missing |
| `Values.elm` enum types | 21 candidate domains | **6** (ClipRule, FillRule, StrokeLinecap, StrokeLinejoin, TextAnchor, Visibility) | — |
| total spec attributes (all families) | **306** | 86 named attr setters | — |

**Corrections to the plan's §0 research numbers (verified against the live W3C indexes):**
- Plan claimed **74 elements**; the live `eltindex.html` lists **69** (regex over raw HTML; a WebFetch of the same page independently returned 69). The plan's 74 over-counted. MDN's element reference documents **63** (modern shipped set) — it omits the 4 SVG-2 HTML-embeds (`audio`/`canvas`/`iframe`/`video`) and `unknown` that the W3C index still lists.
- Plan claimed **41 presentation properties**; the live `propidx.html` main table has **38 rows** + the 3 `marker-start/mid/end` sub-props = **41 core** — the plan's 41 is correct. This audit adds the **4 filter-scoped** props (`flood-color`, `flood-opacity`, `lighting-color`, `color-interpolation-filters`) → **45 total**.
- Plan claimed **27 modeled elements** — **confirmed exactly**.
- Plan claimed **6 typed enums** — **confirmed exactly** (`ClipRule`, `FillRule`, `StrokeLinecap`, `StrokeLinejoin`, `TextAnchor`, `Visibility`).
- Of the 45 presentation props, **21 are strict finite-token enums** (no `<...>` grammar, no `||`/`[...]` combinators) — the drop-in typed-enum candidates for plan Task 3 (vs the current 6).

## 2. Disposition summary (Task 2.3)

Every one of the **375 SPEC entries** (69 elements + 45 presentation properties + 261 other attributes) carries exactly one disposition — **none left unclassified**.

| verdict | count | share |
|---|---|---|
| modeled | 93 | 25% |
| **fix-now** | 33 | 9% |
| defer | 237 | 63% |
| non-goal | 12 | 3% |
| **total** | **375** | 100% |

Per axis:

| axis | modeled | fix-now | defer | non-goal |
|---|---|---|---|---|
| elements (69) | 27 | 3 | 32 | 7 |
| presentation props (45) | 19 | 21 | 4 | 1 |
| other attributes (261) | 47 | 9 | 201 | 4 |

> The large **defer** count is dominated by two spec families the Elm surface handles differently by design: **48 `aria-*` attributes** (SVG has no `Aria.elm` yet — future parity task, mirroring html's 986-line `Aria.elm`) and **77 `on*` event attributes** (SVG events flow through `TypedSvg.Events`, not attribute setters). Neither is a rendering-fidelity gap. Excluding aria+events, the defer set is the filter family and SMIL, both explicitly scope-gated (OQ-2/OQ-3).

## 3. The actionable set — fix-now (feeds plan Tasks 3–4)

**33 entries** are in-scope static-surface gaps worth closing now.

### 3a. Type-fidelity: finite-enum presentation props modeled as bare `String` (plan Task 3, §4.1)
5 properties are already in `_globals` but typed `String` where the SVG-2 grammar is a strict finite token set — drop-in `"type":[tokens]` promotions:

| property | spec value grammar |
|---|---|
| `display` | `inline \| block \| list-item \| run-in \| compact \| marker \| table \| inline-table \| table-row-group \| table-header-group \| table-footer-group \| table-row \| table-column-group \| table-column \| table-cell \| table-caption \| none` |
| `dominant-baseline` | `auto \| use-script \| no-change \| reset-size \| ideographic \| alphabetic \| hanging \| mathematical \| central \| middle \| text-after-edge \| text-before-edge` |
| `pointer-events` | `bounding-box \| visiblePainted \| visibleFill \| visibleStroke \| visible \| painted \| fill \| stroke \| all \| none` |
| `shape-rendering` | `auto \| optimizeSpeed \| crispEdges \| geometricPrecision` |
| `vector-effect` | `non-scaling-stroke \| none` |

### 3b. Missing presentation properties (plan Task 3)
16 presentation properties absent from `_globals` entirely (add as enum or bare String per grammar):

| property | family | spec grammar | strict finite-enum? |
|---|---|---|---|
| `alignment-baseline` | presentation | `auto \| baseline \| before-edge \| text-before-edge \| middle \| central \| after-edge \| text-after-edge \| ideographic \| alphabetic \| hanging \| mathematical` | yes |
| `baseline-shift` | presentation | `baseline \| sub \| super \| <percentage> \| <length>` | no |
| `color-interpolation` | presentation | `auto \| sRGB \| linearRGB` | yes |
| `color-rendering` | presentation | `auto \| optimizeSpeed \| optimizeQuality` | yes |
| `direction` | presentation | `ltr \| rtl` | yes |
| `font-variant` | presentation | `normal \| small-caps` | yes |
| `glyph-orientation-vertical` | presentation | `auto \| <angle> \| <number>` | no |
| `image-rendering` | presentation | `auto \| optimizeSpeed \| optimizeQuality` | yes |
| `line-height` | presentation | `normal \| <number> \| <length-percentage>` | no |
| `marker-end` | presentation | `none \| <url>` | no |
| `marker-mid` | presentation | `none \| <url>` | no |
| `marker-start` | presentation | `none \| <url>` | no |
| `overflow` | presentation | `visible \| hidden \| scroll \| auto` | yes |
| `text-rendering` | presentation | `auto \| optimizeSpeed \| optimizeLegibility \| geometricPrecision` | yes |
| `white-space` | presentation | `normal \| pre \| nowrap \| pre-wrap \| pre-line` | yes |
| `writing-mode` | presentation | `lr-tb \| rl-tb \| tb-rl \| lr \| rl \| tb` | yes |

### 3c. Missing static-surface elements + attributes (plan Task 4)
| item | kind | rationale |
|---|---|---|
| `foreignObject` | element (static-render) | In-scope SVG-2 static surface; plan Task 4 (foreignObject bridges to TypedHtml; view is a viewport). |
| `metadata` | element (non-rendering-metadata) | metadata is a real document element; cheap manifest add (plan Task 4 candidate). |
| `view` | element (static-render) | In-scope SVG-2 static surface; plan Task 4 (foreignObject bridges to TypedHtml; view is a viewport). |
| `requiredExtensions` | attr (conditional-processing) | switch selector; modeling switch without it is a content-model half-measure (plan §3.3). |
| `systemLanguage` | attr (conditional-processing) | switch selector; modeling switch without it is a content-model half-measure (plan §3.3). |
| `lang` | attr (core) | Universal core attribute; cheap _globals add. |
| `role` | attr (core) | Universal core attribute; cheap _globals add. |
| `tabindex` | attr (core) | Universal core attribute; cheap _globals add. |
| `xml:space` | attr (core) | Universal core attribute; cheap _globals add. |
| `method` | attr (geometry) | textPath layout attrs; textPath is modeled but these are dropped. |
| `side` | attr (geometry) | textPath layout attrs; textPath is modeled but these are dropped. |
| `spacing` | attr (geometry) | textPath layout attrs; textPath is modeled but these are dropped. |

## 4. Full element disposition (all 69)

| element | bucket | verdict | scope bucket | rationale |
|---|---|---|---|---|
| `a` | static-render | modeled | — | Already in package. |
| `animate` | smil-animation | defer | smil-deferred (OQ-2) | Distinct declarative-timeline model; deprecation-risk in Chromium; plan default defer. |
| `animateMotion` | smil-animation | defer | smil-deferred (OQ-2) | Distinct declarative-timeline model; deprecation-risk in Chromium; plan default defer. |
| `animateTransform` | smil-animation | defer | smil-deferred (OQ-2) | Distinct declarative-timeline model; deprecation-risk in Chromium; plan default defer. |
| `audio` | html-embed | non-goal | html-embed-legacy | audio/canvas/iframe/video in the SVG namespace were never broadly shipped; drive from HTML instead. |
| `canvas` | html-embed | non-goal | html-embed-legacy | audio/canvas/iframe/video in the SVG namespace were never broadly shipped; drive from HTML instead. |
| `circle` | static-render | modeled | — | Already in package. |
| `clipPath` | static-render | modeled | — | Already in package. |
| `defs` | static-render | modeled | — | Already in package. |
| `desc` | static-render | modeled | — | Already in package. |
| `discard` | smil-animation | defer | smil-deferred (OQ-2) | Distinct declarative-timeline model; deprecation-risk in Chromium; plan default defer. |
| `ellipse` | static-render | modeled | — | Already in package. |
| `feBlend` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feColorMatrix` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feComponentTransfer` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feComposite` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feConvolveMatrix` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feDiffuseLighting` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feDisplacementMap` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feDistantLight` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feDropShadow` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feFlood` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feFuncA` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feFuncB` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feFuncG` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feFuncR` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feGaussianBlur` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feImage` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feMerge` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feMergeNode` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feMorphology` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feOffset` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `fePointLight` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feSpecularLighting` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feSpotLight` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feTile` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `feTurbulence` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `filter` | filter | defer | filter-family (OQ-3) | Largest single family (~26 els); plan Task 5, gated on OQ-3. |
| `foreignObject` | static-render | **fix-now** | static-surface | In-scope SVG-2 static surface; plan Task 4 (foreignObject bridges to TypedHtml; view is a viewport). |
| `g` | static-render | modeled | — | Already in package. |
| `iframe` | html-embed | non-goal | html-embed-legacy | audio/canvas/iframe/video in the SVG namespace were never broadly shipped; drive from HTML instead. |
| `image` | static-render | modeled | — | Already in package. |
| `line` | static-render | modeled | — | Already in package. |
| `linearGradient` | static-render | modeled | — | Already in package. |
| `marker` | static-render | modeled | — | Already in package. |
| `mask` | static-render | modeled | — | Already in package. |
| `metadata` | non-rendering-metadata | **fix-now** | static-surface | metadata is a real document element; cheap manifest add (plan Task 4 candidate). |
| `mpath` | smil-animation | defer | smil-deferred (OQ-2) | Distinct declarative-timeline model; deprecation-risk in Chromium; plan default defer. |
| `path` | static-render | modeled | — | Already in package. |
| `pattern` | static-render | modeled | — | Already in package. |
| `polygon` | static-render | modeled | — | Already in package. |
| `polyline` | static-render | modeled | — | Already in package. |
| `radialGradient` | static-render | modeled | — | Already in package. |
| `rect` | static-render | modeled | — | Already in package. |
| `script` | non-rendering-metadata | non-goal | raw-text-carrier | Carries raw text/JS; not a typed surface. |
| `set` | smil-animation | defer | smil-deferred (OQ-2) | Distinct declarative-timeline model; deprecation-risk in Chromium; plan default defer. |
| `stop` | static-render | modeled | — | Already in package. |
| `style` | non-rendering-metadata | non-goal | raw-text-carrier | Carries raw text/JS; not a typed surface. |
| `svg` | static-render | modeled | — | Already in package. |
| `switch` | static-render | modeled | — | Already in package. |
| `symbol` | static-render | modeled | — | Already in package. |
| `text` | static-render | modeled | — | Already in package. |
| `textPath` | static-render | modeled | — | Already in package. |
| `title` | static-render | modeled | — | Already in package. |
| `tspan` | static-render | modeled | — | Already in package. |
| `unknown` | non-rendering-metadata | non-goal | not-real | Placeholder for unrecognised elements; never authored. |
| `use` | static-render | modeled | — | Already in package. |
| `video` | html-embed | non-goal | html-embed-legacy | audio/canvas/iframe/video in the SVG namespace were never broadly shipped; drive from HTML instead. |
| `view` | static-render | **fix-now** | static-surface | In-scope SVG-2 static surface; plan Task 4 (foreignObject bridges to TypedHtml; view is a viewport). |

## 5. Full presentation-property disposition (all 45)

| property | kind | verdict | scope bucket | rationale |
|---|---|---|---|---|
| `alignment-baseline` | enum | **fix-now** | type-fidelity (Task 3) | Missing entirely; add as typed enum global (drop-in config, plan §4.1). |
| `baseline-shift` | value | **fix-now** | presentation-gap (Task 3) | Missing presentation property; add to _globals (bare String or enum per grammar). |
| `color` | value | modeled | — | Present in _globals or a per-element attr. |
| `color-interpolation` | enum | **fix-now** | type-fidelity (Task 3) | Missing entirely; add as typed enum global (drop-in config, plan §4.1). |
| `color-interpolation-filters` | enum | defer | filter-family (OQ-3) | Only meaningful once the filter family lands (plan Task 5). |
| `color-rendering` | enum | **fix-now** | type-fidelity (Task 3) | Missing entirely; add as typed enum global (drop-in config, plan §4.1). |
| `direction` | enum | **fix-now** | type-fidelity (Task 3) | Missing entirely; add as typed enum global (drop-in config, plan §4.1). |
| `display` | enum | **fix-now** | type-fidelity (Task 3) | Modeled but bare String; spec value-domain is finite — promote to typed enum (plan §4.1). |
| `dominant-baseline` | enum | **fix-now** | type-fidelity (Task 3) | Modeled but bare String; spec value-domain is finite — promote to typed enum (plan §4.1). |
| `fill` | value | modeled | — | Present in _globals or a per-element attr. |
| `fill-opacity` | value | modeled | — | Present in _globals or a per-element attr. |
| `fill-rule` | enum | modeled | — | Present in _globals or a per-element attr. |
| `flood-color` | value | defer | filter-family (OQ-3) | Only meaningful once the filter family lands (plan Task 5). |
| `flood-opacity` | value | defer | filter-family (OQ-3) | Only meaningful once the filter family lands (plan Task 5). |
| `font-variant` | enum | **fix-now** | type-fidelity (Task 3) | Missing entirely; add as typed enum global (drop-in config, plan §4.1). |
| `glyph-orientation-vertical` | value | **fix-now** | presentation-gap (Task 3) | Missing presentation property; add to _globals (bare String or enum per grammar). |
| `image-rendering` | enum | **fix-now** | type-fidelity (Task 3) | Missing entirely; add as typed enum global (drop-in config, plan §4.1). |
| `lighting-color` | value | defer | filter-family (OQ-3) | Only meaningful once the filter family lands (plan Task 5). |
| `line-height` | value | **fix-now** | presentation-gap (Task 3) | Missing presentation property; add to _globals (bare String or enum per grammar). |
| `marker` | value | non-goal | shorthand | `marker` is a shorthand for marker-start/mid/end; model the longhands instead. |
| `marker-end` | value | **fix-now** | presentation-gap (Task 3) | Missing presentation property; add to _globals (bare String or enum per grammar). |
| `marker-mid` | value | **fix-now** | presentation-gap (Task 3) | Missing presentation property; add to _globals (bare String or enum per grammar). |
| `marker-start` | value | **fix-now** | presentation-gap (Task 3) | Missing presentation property; add to _globals (bare String or enum per grammar). |
| `opacity` | value | modeled | — | Present in _globals or a per-element attr. |
| `overflow` | enum | **fix-now** | type-fidelity (Task 3) | Missing entirely; add as typed enum global (drop-in config, plan §4.1). |
| `paint-order` | value | modeled | — | Present in _globals or a per-element attr. |
| `pointer-events` | enum | **fix-now** | type-fidelity (Task 3) | Modeled but bare String; spec value-domain is finite — promote to typed enum (plan §4.1). |
| `shape-rendering` | enum | **fix-now** | type-fidelity (Task 3) | Modeled but bare String; spec value-domain is finite — promote to typed enum (plan §4.1). |
| `stop-color` | value | modeled | — | Present in _globals or a per-element attr. |
| `stop-opacity` | value | modeled | — | Present in _globals or a per-element attr. |
| `stroke` | value | modeled | — | Present in _globals or a per-element attr. |
| `stroke-dasharray` | value | modeled | — | Present in _globals or a per-element attr. |
| `stroke-dashoffset` | value | modeled | — | Present in _globals or a per-element attr. |
| `stroke-linecap` | enum | modeled | — | Present in _globals or a per-element attr. |
| `stroke-linejoin` | enum | modeled | — | Present in _globals or a per-element attr. |
| `stroke-miterlimit` | value | modeled | — | Present in _globals or a per-element attr. |
| `stroke-opacity` | value | modeled | — | Present in _globals or a per-element attr. |
| `stroke-width` | value | modeled | — | Present in _globals or a per-element attr. |
| `text-anchor` | enum | modeled | — | Present in _globals or a per-element attr. |
| `text-decoration` | value | modeled | — | Present in _globals or a per-element attr. |
| `text-rendering` | enum | **fix-now** | type-fidelity (Task 3) | Missing entirely; add as typed enum global (drop-in config, plan §4.1). |
| `vector-effect` | enum | **fix-now** | type-fidelity (Task 3) | Modeled but bare String; spec value-domain is finite — promote to typed enum (plan §4.1). |
| `visibility` | enum | modeled | — | Present in _globals or a per-element attr. |
| `white-space` | enum | **fix-now** | type-fidelity (Task 3) | Missing entirely; add as typed enum global (drop-in config, plan §4.1). |
| `writing-mode` | enum | **fix-now** | type-fidelity (Task 3) | Missing entirely; add as typed enum global (drop-in config, plan §4.1). |

## 6. Other-attribute disposition (all 261, grouped by family)

### family `animation-addition` (2 attrs — {'defer': 2})
| attr | verdict | scope bucket | rationale |
|---|---|---|---|
| `accumulate` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `additive` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |

### family `animation-timing` (10 attrs — {'defer': 9, 'modeled': 1})
| attr | verdict | scope bucket | rationale |
|---|---|---|---|
| `attributeName` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `begin` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `dur` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `end` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `fill` | modeled | — | Present (global or per-element). |
| `max` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `min` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `repeatCount` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `repeatDur` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `restart` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |

### family `animation-value` (8 attrs — {'defer': 8})
| attr | verdict | scope bucket | rationale |
|---|---|---|---|
| `by` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `calcMode` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `from` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `keyPoints` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `keySplines` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `keyTimes` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `origin` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |
| `to` | defer | smil-deferred (OQ-2) | Attribute of a deferred SMIL element. |

### family `aria` (48 attrs — {'defer': 48})
48 attributes, all **defer** — No Aria.elm for SVG yet (html has one, 986 lines); future parity task. e.g. `aria-activedescendant`, `aria-atomic`, `aria-autocomplete`, `aria-busy`, `aria-checked`, `aria-colcount` …

### family `conditional-processing` (2 attrs — {'fix-now': 2})
| attr | verdict | scope bucket | rationale |
|---|---|---|---|
| `requiredExtensions` | **fix-now** | static-surface (Task 4) | switch selector; modeling switch without it is a content-model half-measure (plan §3.3). |
| `systemLanguage` | **fix-now** | static-surface (Task 4) | switch selector; modeling switch without it is a content-model half-measure (plan §3.3). |

### family `core` (18 attrs — {'modeled': 5, 'defer': 8, 'fix-now': 4, 'non-goal': 1})
| attr | verdict | scope bucket | rationale |
|---|---|---|---|
| `class` | modeled | — | Present (global or per-element). |
| `crossorigin` | defer | embed-scoped | crossorigin/download/hreflang/media/ping/referrerpolicy/rel — apply to a/image/script embeds; add with embed disposition. |
| `download` | defer | embed-scoped | crossorigin/download/hreflang/media/ping/referrerpolicy/rel — apply to a/image/script embeds; add with embed disposition. |
| `href` | modeled | — | Present (global or per-element). |
| `hreflang` | defer | embed-scoped | crossorigin/download/hreflang/media/ping/referrerpolicy/rel — apply to a/image/script embeds; add with embed disposition. |
| `id` | modeled | — | Present (global or per-element). |
| `lang` | **fix-now** | core-gap (Task 4) | Universal core attribute; cheap _globals add. |
| `media` | defer | embed-scoped | crossorigin/download/hreflang/media/ping/referrerpolicy/rel — apply to a/image/script embeds; add with embed disposition. |
| `ping` | defer | embed-scoped | crossorigin/download/hreflang/media/ping/referrerpolicy/rel — apply to a/image/script embeds; add with embed disposition. |
| `referrerpolicy` | defer | embed-scoped | crossorigin/download/hreflang/media/ping/referrerpolicy/rel — apply to a/image/script embeds; add with embed disposition. |
| `rel` | defer | embed-scoped | crossorigin/download/hreflang/media/ping/referrerpolicy/rel — apply to a/image/script embeds; add with embed disposition. |
| `role` | **fix-now** | core-gap (Task 4) | Universal core attribute; cheap _globals add. |
| `style` | modeled | — | Present (global or per-element). |
| `tabindex` | **fix-now** | core-gap (Task 4) | Universal core attribute; cheap _globals add. |
| `target` | modeled | — | Present (global or per-element). |
| `title` | non-goal | element-not-attr | `title` is the <title> child element, already modeled; not an attribute. |
| `type` | defer | context-specific | `type` is script/style/animation-scoped; add with those elements. |
| `xml:space` | **fix-now** | core-gap (Task 4) | Universal core attribute; cheap _globals add. |

### family `event` (77 attrs — {'defer': 77})
77 attributes, all **defer** — SVG events flow through TypedSvg.Events, not attribute setters. e.g. `onabort`, `onafterprint`, `onbeforeprint`, `onbegin`, `oncancel`, `oncanplay` …

### family `filter` (43 attrs — {'defer': 43})
| attr | verdict | scope bucket | rationale |
|---|---|---|---|
| `amplitude` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `azimuth` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `baseFrequency` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `bias` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `diffuseConstant` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `divisor` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `edgeMode` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `elevation` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `exponent` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `in` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `in2` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `intercept` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `k1` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `k2` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `k3` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `k4` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `kernelMatrix` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `kernelUnitLength` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `limitingConeAngle` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `mode` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `numOctaves` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `operator` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `order` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `pointsAtX` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `pointsAtY` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `pointsAtZ` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `preserveAlpha` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `radius` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `result` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `scale` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `seed` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `slope` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `specularConstant` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `specularExponent` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `stdDeviation` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `stitchTiles` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `surfaceScale` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `tableValues` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `targetX` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `targetY` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `xChannelSelector` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `yChannelSelector` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |
| `z` | defer | filter-family (OQ-3) | Attribute of a deferred filter primitive. |

### family `geometry` (51 attrs — {'modeled': 41, 'defer': 6, 'fix-now': 3, 'non-goal': 1})
| attr | verdict | scope bucket | rationale |
|---|---|---|---|
| `clipPathUnits` | modeled | — | Present (global or per-element). |
| `cx` | modeled | — | Present (global or per-element). |
| `cy` | modeled | — | Present (global or per-element). |
| `dx` | modeled | — | Present (global or per-element). |
| `dy` | modeled | — | Present (global or per-element). |
| `filterUnits` | defer | filter-family (OQ-3) | Filter-scoped geometry. |
| `fr` | modeled | — | Present (global or per-element). |
| `fx` | modeled | — | Present (global or per-element). |
| `fy` | modeled | — | Present (global or per-element). |
| `gradientTransform` | modeled | — | Present (global or per-element). |
| `gradientUnits` | modeled | — | Present (global or per-element). |
| `height` | modeled | — | Present (global or per-element). |
| `lengthAdjust` | modeled | — | Present (global or per-element). |
| `markerHeight` | modeled | — | Present (global or per-element). |
| `markerUnits` | modeled | — | Present (global or per-element). |
| `markerWidth` | modeled | — | Present (global or per-element). |
| `maskContentUnits` | modeled | — | Present (global or per-element). |
| `maskUnits` | modeled | — | Present (global or per-element). |
| `method` | **fix-now** | static-surface (Task 4) | textPath layout attrs; textPath is modeled but these are dropped. |
| `offset` | modeled | — | Present (global or per-element). |
| `orient` | modeled | — | Present (global or per-element). |
| `path` | defer | smil-deferred (OQ-2) | Animation-scoped. |
| `pathLength` | modeled | — | Present (global or per-element). |
| `patternContentUnits` | modeled | — | Present (global or per-element). |
| `patternTransform` | modeled | — | Present (global or per-element). |
| `patternUnits` | modeled | — | Present (global or per-element). |
| `playbackorder` | defer | smil-deferred (OQ-2) | Animation-scoped. |
| `points` | modeled | — | Present (global or per-element). |
| `preserveAspectRatio` | modeled | — | Present (global or per-element). |
| `primitiveUnits` | defer | filter-family (OQ-3) | Filter-scoped geometry. |
| `r` | modeled | — | Present (global or per-element). |
| `refX` | modeled | — | Present (global or per-element). |
| `refY` | modeled | — | Present (global or per-element). |
| `rotate` | modeled | — | Present (global or per-element). |
| `side` | **fix-now** | static-surface (Task 4) | textPath layout attrs; textPath is modeled but these are dropped. |
| `spacing` | **fix-now** | static-surface (Task 4) | textPath layout attrs; textPath is modeled but these are dropped. |
| `spreadMethod` | modeled | — | Present (global or per-element). |
| `startOffset` | modeled | — | Present (global or per-element). |
| `textLength` | modeled | — | Present (global or per-element). |
| `timelinebegin` | defer | smil-deferred (OQ-2) | Animation-scoped. |
| `transform` | modeled | — | Present (global or per-element). |
| `values` | defer | smil-deferred (OQ-2) | Animation-scoped. |
| `viewBox` | modeled | — | Present (global or per-element). |
| `width` | modeled | — | Present (global or per-element). |
| `x` | modeled | — | Present (global or per-element). |
| `x1` | modeled | — | Present (global or per-element). |
| `x2` | modeled | — | Present (global or per-element). |
| `y` | modeled | — | Present (global or per-element). |
| `y1` | modeled | — | Present (global or per-element). |
| `y2` | modeled | — | Present (global or per-element). |
| `zoomAndPan` | non-goal | deprecated | zoomAndPan is deprecated in SVG 2. |

### family `xlink` (2 attrs — {'non-goal': 2})
| attr | verdict | scope bucket | rationale |
|---|---|---|---|
| `xlink:href` | non-goal | xlink-legacy (OQ-4) | Superseded by bare `href` (modeled); SVG-2-preferred form. |
| `xlink:title` | non-goal | xlink-legacy (OQ-4) | Superseded by bare `href` (modeled); SVG-2-preferred form. |

## 7. Extraneous / typo check (MODELED − SPEC)

**0 extraneous elements** — every one of the 27 modeled element tags is a real SVG-2 element (no typos, no renames beyond the intended `text`→`text_` Elm ctor rename, which keeps `tagName:"text"`). The package is a clean *subset*, not a drifted one.

## 8. Reviewer disposition notes → OQ answers

- **OQ-1 (SVG 2 of record):** confirmed as the diff basis. No SVG-1.1-only element surfaced except `requiredFeatures` (dropped from the SVG-2 attindex → correctly non-goal).
- **OQ-2 (SMIL):** 6 elements + ~25 timing/value/addition attrs → all **defer** (`smil-deferred`). Plan default upheld.
- **OQ-3 (filters):** 26 elements + 4 filter-presentation props + filter-primitive attrs → all **defer** (`filter-family`). Largest single deferred family.
- **OQ-4 (xlink):** `xlink:href`, `xlink:title` → **non-goal** (`xlink-legacy`); bare `href` already modeled.
- **OQ-5 (value-type ambition):** the type-fidelity gaps (§3a) + missing enum props (§3b) are the cheap, high-fidelity Task-3 wins. `Paint`/`transform-list`/`Length` remain reviewer-choice for a follow-up (ergonomics, not coverage — not surfaced as gaps here).

---

*SPEC parsed by regex over the raw W3C SVG 2 index HTML (fetched 2026-08-21); MODELED extracted by AST/JSON read of the current `brands/svg/generated/package/elm-typed-svg` (no package mutation). All numbers re-derivable from `spec-index.json` + `modeled-index.json`.*