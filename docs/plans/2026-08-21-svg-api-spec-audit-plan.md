# elm-typed-svg — SVG API-vs-spec audit plan

**Status:** plan only (no code, no audit execution). Design-bearing spec-research work.
**Author date:** 2026-08-21.
**Scope target:** `brands/svg/generated/package/elm-typed-svg` — the `TypedSvg` brand.
**Templates followed:** `docs/plans/2026-08-20-reconciliation-plan.md` (task/step + acceptance-test
house style), `writing-plans` structure.
**This plan is NOT executed by its author.** It is handed to a fresh execution agent after Jack reviews
it and resolves the open questions (§7). Several tasks are gated on those answers and say so.

---

## 0. Why this plan exists

Jack asked for the `TypedSvg` brand's API surface to be audited against the real SVG specification with
the same rigor "html was previously." A search of `docs/plans/`, `docs/superpowers/`, and the full git
history (`git log --all -i --grep=audit|whatwg|w3c|mdn|coverage`) turned up **no dedicated
html-vs-HTML-spec audit document** — that rigor was embedded directly into building `elm-typed-html`
(and its `manifest`/`config`), never tracked as a separate audit project. So this plan uses
`elm-typed-html`'s **current** structure and completeness as the implicit baseline to model SVG's audit
after, and additionally proposes making the audit **repeatable and gated** rather than one-shot — the
thing html never got.

### The baseline, measured (2026-08-21)

| axis | `elm-typed-html` (baseline) | `elm-typed-svg` (current) |
|---|---|---|
| elements modeled | **112** (config keys) | **27** (manifest + config) |
| global attributes | 29 (typed where finite) | ~40 presentation/core (6 typed, rest bare `String`) |
| per-element attrs (manifest) | large | **48** distinct (geometry/structural only) |
| typed enum value-domains | **~35** (`Values.elm`, phantom rows + `FromString`/`Values` round-trip) | **6** (`ClipRule`, `FillRule`, `StrokeLinecap`, `StrokeLinejoin`, `TextAnchor`, `Visibility`) |
| `Values.elm` / `Attributes.elm` size | 2870 / 1800 lines | 442 / 642 lines |
| ARIA modeling | `Aria.elm`, 986 lines | none |

The SVG package is a **faithful but deliberately pragmatic subset** — its own README says the manifest
was "authored from the W3C SVG spec + MDN, cross-checked against `elm/svg`." In practice its element and
attribute vocabulary tracks **`elm/svg`'s legacy scope** (the classic shapes, text, gradients, clipping,
structure), not the full SVG 2 vocabulary. That is a reasonable v1, but it is not the "rigor html had,"
and the gaps below are large and structured, not scattered.

### The spec, measured (this plan's own research)

Fetched live for this plan:
- W3C SVG 2 element index (`w3.org/TR/SVG2/eltindex.html`) → **74 elements**.
- W3C SVG 2 property index (`w3.org/TR/SVG2/propidx.html`) → **41 presentation properties**.
- MDN SVG attribute reference (`developer.mozilla.org/.../SVG/Reference/Attribute`) → the attribute
  **families** (core, conditional-processing, presentation, XLink, animation-timing/value/addition,
  event).

That 74-vs-27 element gap and 41-vs-~40-but-only-6-typed property gap is the shape of the audit.

---

## 1. Scope decision (GATED on OQ-1, OQ-2)

SVG is not one spec surface; it is several with very different browser-support realities. The audit's
first job is to **draw the scope line explicitly** rather than inherit `elm/svg`'s accidental one. The
candidate lines, and this plan's recommendation:

- **SVG 1.1** — the historical baseline; superseded, but the vocabulary most tutorials assume. Reject as
  the *target* (it under-specifies geometry-as-presentation, `transform-origin`, etc.).
- **SVG 2** — the current W3C Candidate-Recommendation / living target. **Recommended as the spec of
  record** for the static rendering surface (elements + presentation/geometry/structural attributes).
- **Pragmatic browser-supported subset** — SVG 2 *minus* the parts browsers never shipped or actively
  deprecated. This matters most for **SMIL animation** (`animate`, `animateTransform`, `animateMotion`,
  `set`, `mpath`, `discard`) and the `xlink:` attribute namespace (deprecated in favour of bare `href`).

**Recommendation:** target **SVG 2 for the static surface** (rendering, filters, clipping/masking,
gradients, markers, text), and treat **SMIL animation and `xlink:` as explicit, separately-decided
scope buckets** (OQ-2). The static surface is where "type-safe native SVG for Elm" earns its keep and
where the current package's gaps are least defensible; SMIL is spec'd but is a genuinely different
animation model (declarative timeline elements, not attributes-on-shapes) and Chromium has repeatedly
threatened parts of it — modeling it fully may be effort spent on a surface many apps drive from CSS/JS
instead.

**Buckets the audit will classify every spec element/attribute into:**
1. **Static render surface** — in scope, SVG 2 (shapes, structure, gradients, paint, clip/mask/marker,
   text, `image`, `foreignObject`, `view`).
2. **Filters** — `filter` + the 20-odd `fe*` primitives + filter presentation props. In scope but
   sequenced last (largest single family, self-contained).
3. **SMIL animation** — `animate*`/`set`/`mpath`/`discard` + timing/value/addition attrs. **Decision
   deferred to Jack (OQ-2).** Default assumption if unanswered: *document as out-of-scope for v1, leave a
   modeled seam.*
4. **Non-rendering / document metadata** — `metadata`, `script`, `style`, `title`/`desc` (present),
   `unknown`. Mostly out-of-scope for a *typed* surface (`script`/`style` carry raw text).
5. **Deprecated / namespace-legacy** — `xlink:*`, SVG-1.1-only elements. Out-of-scope, documented.

---

## 2. Coverage-audit methodology

The audit must be **systematic and diffable**, not a hand-scan, and — the improvement over html — it
should leave behind a **committed coverage map + a gate** so drift from spec is caught mechanically, the
same way this repo already gates regen drift (`tools/check-drift.mjs`) and elm-shape drift
(`tools/check-elm-shape-drift.mjs`).

### 2.1 The three enumerations to diff

1. **SPEC set** — machine-extract the element and attribute vocabulary from the W3C SVG 2 indexes
   (`eltindex.html`, `attindex.html`, `propidx.html`) into a small committed JSON fixture
   (`docs/svg-audit/spec-index.json`), one entry per element and per attribute with its family tag and
   which elements it applies to. Provenance-stamped (spec URL + fetch date), exactly like the
   facts-bundle provenance the repo already requires.
2. **MODELED set** — extract what the package actually generates: element ctors from the manifest +
   config keys, attribute setters from `TypedSvg/Attributes.elm` exposing lists, enum types from
   `TypedSvg/Values.elm`. This is pure AST/JSON reading, no API cost.
3. **DIFF** — `SPEC − MODELED` (missing), `MODELED − SPEC` (extraneous / typo'd / renamed),
   `SPEC ∩ MODELED but String-typed where spec says enum` (type-fidelity gap, feeds §4).

### 2.2 Reuse-or-extend decision on existing tooling

- `tools/check-coverage-map.mjs` is **NOT reusable as-is** — it is hard-wired to the m3e facts-bundle
  (`docs/facts-bundle/coverage-map.json`, four fixed m3e consumers, Face-B/C provenance). It is the
  *pattern* to imitate (well-formed map + provenance stamp + a gate that proves map⋈schema agree, and is
  honest that "green only means the evidence file and the schema agree with each other"), not the code.
- **Recommendation:** author a new, brand-agnostic `tools/check-svg-spec-coverage.mjs` that diffs
  `spec-index.json` against the generated SVG package and fails on any *un-annotated* gap. A gap is
  allowed only if it carries an explicit `exception` with a reason bucket from §1 (e.g. `"smil-deferred"`,
  `"xlink-legacy"`). This mirrors `check-coverage-map`'s mapped/exception contract. Register it in
  `tools/gate-all.mjs` behind the SVG brand (see Task 6). If, during Task 1, the diff logic turns out
  genuinely brand-neutral, generalize it (`check-brand-spec-coverage.mjs` taking a brand + spec-index
  path) — but do not over-abstract on spec; one concrete consumer first.

### 2.3 What "green" means (honesty clause, inherited from check-coverage-map)

The gate proves the coverage map is **well-formed and internally consistent** with the generated
package, and that every gap is *accounted for* — not that a modeled attribute is *semantically correct*.
Value-domain fidelity (§4) and content-model correctness (`admits`) are **reviewer judgment**, checked
per-task, not by the gate.

---

## 3. Concrete candidate gaps (from real SVG 2 spec research)

These are named from the live W3C/MDN fetches above, cross-checked against the current manifest (27
elements) and config. They are **candidates to confirm during Task 2**, not a pre-executed audit.

### 3.1 Whole element families absent (spec 74 → modeled 27)

- **Filter primitives — entirely absent.** `filter` and all `fe*`: `feBlend`, `feColorMatrix`,
  `feComponentTransfer`, `feComposite`, `feConvolveMatrix`, `feDiffuseLighting`, `feDisplacementMap`,
  `feDistantLight`, `feDropShadow`, `feFlood`, `feFuncA/B/G/R`, `feGaussianBlur`, `feImage`, `feMerge`,
  `feMergeNode`, `feMorphology`, `feOffset`, `fePointLight`, `feSpecularLighting`, `feSpotLight`,
  `feTile`, `feTurbulence`. ~24 elements — the single largest gap. The config *models the `filter`
  presentation attribute* (as a bare string `url(#id)`), but there is **no way to build a filter
  definition** in the typed surface today.
- **SMIL animation — entirely absent.** `animate`, `animateMotion`, `animateTransform`, `set`, `mpath`,
  `discard`. (Scope-gated — OQ-2.)
- **Document/embedding elements absent.** `foreignObject` (embed HTML in SVG — a real, common need and
  the natural bridge back into `TypedHtml`), `view`, `metadata`, `script`, `style`, `unknown`. Also the
  media embeds `audio`/`video`/`iframe`/`canvas` that SVG 2 newly admits.

### 3.2 Presentation-attribute gaps (spec 41 props → 6 typed + ~34 bare)

Present in the SVG 2 property index but **missing from `config.json`'s `_globals`** entirely:
- `alignment-baseline`, `baseline-shift`, `dominant-baseline` (partially present as bare string) — the
  text-baseline family; each is a **finite enum** in the spec (candidates for typed value-domains).
- `color-interpolation`, `color-interpolation-filters`, `color-rendering`, `image-rendering`,
  `shape-rendering` (present), `text-rendering` — the rendering-hint family, all **finite enums**.
- `direction`, `writing-mode`, `white-space`, `unicode-bidi`, `glyph-orientation-vertical`,
  `font-variant`, `line-height` — text-layout family.
- `overflow`, `marker`/`marker-start`/`marker-mid`/`marker-end` — the marker-binding presentation
  attributes (the package models the `marker` *element* but not the attributes that *attach* a marker to
  a shape).
- Filter-scoped presentation props: `flood-color`, `flood-opacity`, `lighting-color` (only meaningful
  once §3.1 filters land).

### 3.3 Conditional-processing and namespace families absent

- **Conditional processing** — `requiredExtensions`, `requiredFeatures` (SVG-1.1 legacy),
  `systemLanguage`. These pair with the `switch` element (which *is* modeled) — modeling `switch` without
  its selector attributes is a content-model half-measure to flag.
- **XLink namespace** — `xlink:href` (superseded by `href`, which *is* modeled) and the rest
  (`xlink:title`, `xlink:show`, …). Recommend explicit out-of-scope with an `exception`.

### 3.4 Per-element geometry/attribute spot-gaps to verify

The 48 modeled attributes cover the classic shapes well, but Task 2 should confirm no drops in, e.g.:
`marker`'s `refX/refY/orient/markerUnits` (present), `pattern`'s `patternContentUnits` (present),
`text`/`tspan` positional lists `x`/`y`/`dx`/`dy`/`rotate` as **lists** vs single values (spec allows
number-lists — a likely type-fidelity gap), and `path`'s `d` as bare `String` (see §4).

---

## 4. Type-safety opportunities specific to SVG

SVG's spec defines named **value grammars** that the current package flattens to bare `String`. This is
where "true to the spec" beats "renders correctly," and where html's `Values.elm` already sets the
pattern (phantom-tagged enum tokens + `FromString`/`Values` round-trip). Ranked by payoff:

1. **Enumerated presentation values → phantom enums.** Every finite-token presentation property in §3.2
   (`dominant-baseline`, `color-interpolation`, `image-rendering`, `text-rendering`, `direction`,
   `writing-mode`, `overflow`, `unicode-bidi`, `vector-effect`, `paint-order`, `pointer-events`,
   `shape-rendering`, …) is currently a bare `String` in `_globals`. These are **drop-in** for the
   existing `{ "name": ..., "type": [tokens] }` config shape that already produced the 6 enums — the
   cheapest, highest-fidelity win. Target: bring SVG's typed-enum count from 6 toward parity with the
   spec's finite-domain count (candidate ~20+).
2. **`<paint>` — a real sum type.** A paint is `none | currentColor | <color> | url(#ref) [fallback]`.
   Today `fill`/`stroke`/`stop-color` are bare strings. A `Paint` opaque type with constructors
   (`paintNone`, `currentColor`, `paintColor`, `paintRef`) would reject `fill="rect"` at compile time.
   Note there is already a `TypedSvg/Element/Paint.elm` **home module** (gradients live there) — do not
   confuse the *value type* `Paint` with that element-group module; name accordingly.
3. **`<length>` / `<coordinate>` / `<percentage>`.** `10`, `10px`, `50%`, `10em`. A phantom `Length`
   builder (`px`, `percent`, `em`, `num`) would make `width (px 100)` truer than `width "100"`. Weigh
   against ergonomics — SVG authors are used to raw numbers; a `String`-accepting escape hatch stays.
4. **`transform` → `<transform-list>`.** Today a bare string. A typed builder
   (`translate x y`, `rotate deg`, `scale`, `skewX`, `matrix …`) composing to a list is a well-scoped,
   high-value type (this is exactly what the legacy `elm-community/typed-svg` shipped and users liked).
5. **`viewBox` / `preserveAspectRatio` / `points`.** `viewBox` is 4 numbers; `points` is a
   coordinate-pair list; `preserveAspectRatio` is `<align> [<meetOrSlice>]` — all finite/structured, all
   bare strings today. Medium payoff.
6. **`d` (path data) — leave as String (documented).** A fully-typed path-command DSL is a large surface
   and a legitimate ergonomic loss; flag as an explicit non-goal with rationale, don't silently skip.

Each promotion above is a config-only or config+small-emitter change fed through the same generator —
**no post-codegen tweaks** (the brand's zero-tweak contract, enforced by `regen-diff-gate.sh`).

---

## 5. Task breakdown (gauntlet-shaped, atomic leaves with acceptance tests)

Sequenced so every task lands on a green tree. Tasks 1–2 are the audit *itself* (enumerate + diff, no
package change); Tasks 3–5 are the *fixes*, each independently shippable; Task 6 makes it permanent.
**Expected model tier (informational):** Task 0–2 opus@medium (research+tooling); Tasks 3–5 sonnet
workers under opus orchestration (mechanical config regen + verify); Task 6 opus@medium (gate wiring).

### Task 0: Baseline + identity guard
- [ ] **0.1** From repo root run `GATE_ALL_CONCURRENCY=1 node tools/gate-all.mjs`, save to
      `/tmp/svg-audit-baseline-gate.log`. Must be green as-shipped. If red, STOP and surface.
- [ ] **0.2** `git status --short` empty before starting.
- [ ] **0.3** IDENTITY GUARD: `git config user.name && git config user.email` == `JackHP95` /
      `git@jackhpeterson.com`. `env | grep -iE 'GIT_AUTHOR|GIT_COMMITTER'` empty.
- **Acceptance:** baseline gate log saved and green; identity confirmed.

### Task 1: Build the machine-readable SPEC index
- [ ] **1.1** Fetch and parse W3C SVG 2 `eltindex.html`, `attindex.html`, `propidx.html` into
      `docs/svg-audit/spec-index.json`: `{ elements: [...], attributes: [{name, family, appliesTo,
      valueGrammar}], provenance: {specUrl, fetchedAt} }`. Family ∈ {core, presentation,
      conditional-processing, xlink, filter, animation-timing, animation-value, animation-addition,
      geometry, event}.
- [ ] **1.2** Cross-check the element list against MDN's per-element pages for any element MDN documents
      as shipped that the W3C index omits (and vice-versa); annotate discrepancies.
- **Acceptance:** `spec-index.json` validates against a small committed JSON schema; `elements` length
  == 74 ± documented deltas; provenance stamped. Reviewer spot-checks 5 random entries against the live
  spec.

### Task 2: Diff SPEC vs MODELED → the audit report
- [ ] **2.1** Extract the MODELED set (manifest elements + config keys + `Attributes.elm` exposing +
      `Values.elm` enum types) into `docs/svg-audit/modeled-index.json` (AST/JSON only, no API cost).
- [ ] **2.2** Compute the three diffs (§2.1) into `docs/svg-audit/2026-08-21-svg-coverage-audit.md`:
      table of every missing element (with §1 bucket), every missing/mistyped attribute, every
      String-where-spec-says-enum. This is the audit deliverable.
- [ ] **2.3** Reviewer classifies each gap: **fix now / defer (with bucket) / non-goal (with rationale)**.
      Feeds Task 3–5 scope and OQ answers.
- **Acceptance:** report enumerates 100% of `spec-index.json` entries with a disposition each; no entry
  left unclassified. Numbers reconcile with §0/§3 (any deviation explained).

### Task 3: Land the low-risk presentation-enum type-fidelity wins (§4.1)
- [ ] **3.1** For each confirmed finite-domain presentation attribute, add `"type": [tokens]` to
      `config.json` `_globals` (drop-in, same shape as the existing 6 enums). Batch by family
      (baseline, rendering-hints, text-layout).
- [ ] **3.2** Regenerate the package through the generator; **zero post-codegen edits**.
- [ ] **3.3** Add a `verify/src/Sample.elm` usage of each new enum so a wrong token is a compile error.
- **Acceptance:** `scripts/regen-diff-gate.sh` green (output is pure generator output); `Values.elm`
  typed-enum count rises to the target from Task 2; `verify` compiles; a deliberately-wrong token fails
  to compile (recorded).

### Task 4: Add the missing static-surface elements + their attributes (§3.1, §3.3)
- [ ] **4.1** Add `foreignObject` (+ the `TypedHtml` bridge in `admits`), `view`, `symbol`/`marker`
      completeness, media embeds per Task-2 disposition, to `manifest/svg.cem.json` + `config.json`
      (`home`/`admits`).
- [ ] **4.2** Add `switch`'s conditional-processing selector attributes (`systemLanguage`, …) per
      disposition.
- [ ] **4.3** Regenerate; zero tweaks. Extend `RenderTest.elm` to render each new element and assert the
      namespaced-node output (`createElementNS`).
- **Acceptance:** regen-diff green; each new element renders with the SVG namespace; content-model
  `admits` reviewed (a `<circle>` still can't nest a `<div>` except via `foreignObject`).

### Task 5: Model the filter family (§3.1) — GATED on OQ-3
- [ ] **5.1** Add `filter` + `fe*` primitives to manifest/config as a new `home` module
      (`TypedSvg/Element/Filter.elm`), with the filter presentation props (`flood-color`,
      `color-interpolation-filters`, …) and the filter-primitive-specific attributes.
- [ ] **5.2** Model filter-value enums (`feBlend` `mode`, `feComposite` `operator`, `feColorMatrix`
      `type`, …) as typed domains.
- [ ] **5.3** Regenerate; zero tweaks; `verify` builds a small drop-shadow filter end-to-end.
- **Acceptance:** regen-diff green; a representative filter graph compiles and renders; enums reject bad
  operators. (Large task — may be split into 5a shapes/5b lighting.)

### Task 6: Make it permanent — the spec-coverage gate (§2.2)
- [x] **6.1** Author `tools/check-svg-spec-coverage.mjs`: diff `spec-index.json` vs the generated SVG
      package; fail on any gap lacking an `exception{reason}`. Provenance-stamp check like
      `check-coverage-map`.
- [x] **6.2** Author `docs/svg-audit/coverage-map.json` recording every deferred/non-goal gap with its
      bucket (`smil-deferred`, `xlink-legacy`, `path-data-non-goal`, …).
- [x] **6.3** Add `tools/check-svg-spec-coverage.test.mjs` (mutation test: appending a fake spec element
      with no exception turns the gate red — the honesty proof).
- [x] **6.4** Register in `tools/gate-all.mjs` + `tools/gate-all-expected-steps.json`.
- **Acceptance:** gate green on the post-Task-5 tree; mutation test proves it can go red; `gate-all`
  step-membership tests pass. From here, any spec-index bump or package regen that opens an un-excepted
  gap fails CI — the drift protection html never had.

### Task 7: Close-out
- [x] **7.1** Update the SVG package README scope section to state the audited SVG-2 scope + the
      documented deferrals (SMIL, xlink, path-DSL).
- [x] **7.2** Note in `MEMORY.md` that the SVG brand is now spec-audited + gated, with the coverage map
      as source of truth.
- **Acceptance:** `git status` clean except intended files; full `gate-all` green.

---

## 6. Sequencing / blast radius

- Tasks 1–2 are **read-only** (no package change) — safe to run any time, no worktree mutation risk.
- Tasks 3–5 each regenerate the SVG package only; blast radius is contained to `brands/svg/**` plus the
  generator's zero-tweak contract. None touches shared `pipeline/elm-cem` emitter code **unless** a §4
  type (e.g. typed `transform-list`) needs an emitter capability the config can't express — if so, that
  is a **generator change** and per `MEMORY.md` triggers a Face-A bundle re-baseline + all-brand regen
  (call it out loudly in the task; prefer config-only paths first).
- Task 6 touches `tools/` + `gate-all` wiring only.
- **Order flexibility:** Tasks 3, 4, 5 are independent and may be reordered/parallelized in worktrees.
  Task 6 must be last (it gates the finished surface).

---

## 7. Open questions for Jack

- **OQ-1 (scope of record):** confirm **SVG 2** as the spec target for the static surface (not SVG 1.1,
  not a frozen browser subset). *Plan assumes yes.*
- **OQ-2 (SMIL animation in/out):** model the `animate*`/`set`/`mpath`/`discard` timeline elements now,
  or **defer with a documented seam**? SMIL is spec'd but is a distinct declarative-timeline model and
  parts have been perennially at deprecation risk in Chromium. *Plan defaults to defer (bucket
  `smil-deferred`) unless you say otherwise* — this is the single biggest scope lever.
- **OQ-3 (filters now or next pass):** the filter family (~24 elements) is the largest single chunk of
  the static surface. Land it in this audit (Task 5) or spin it into a follow-up? *Plan includes it but
  isolates it as the last, splittable task.*
- **OQ-4 (`xlink:` namespace):** confirm out-of-scope (bare `href` is modeled and is the SVG-2-preferred
  form). *Plan assumes out-of-scope, bucket `xlink-legacy`.*
- **OQ-5 (value-type ambition):** how far up §4 do we go? Enums (§4.1) are cheap and clearly worth it.
  `Paint` (§4.2) and `transform-list` (§4.4) are higher-value but bigger. `Length` (§4.3) trades
  ergonomics. Which of these are in v1 vs a follow-up? *Plan lands §4.1 in Task 3 and leaves §4.2–4.6 as
  reviewer-dispositioned during Task 2.*
- **OQ-6 (package split):** html is a 3-tier split (`-core` + siblings); SVG is a single monolith
  package today. Does a spec-complete SVG (esp. once filters + animation land) warrant the same
  tier split, or stay one package? Not required by the audit, but the growth makes it a live question.

---

## 8. Deliverables summary

| artifact | task | purpose |
|---|---|---|
| `docs/svg-audit/spec-index.json` | 1 | machine-readable SVG 2 vocabulary, provenance-stamped |
| `docs/svg-audit/modeled-index.json` | 2 | what the package actually generates |
| `docs/svg-audit/2026-08-21-svg-coverage-audit.md` | 2 | the human audit report + dispositions |
| `docs/svg-audit/coverage-map.json` | 6 | every deferral/non-goal, bucketed |
| `tools/check-svg-spec-coverage.mjs` (+ test) | 6 | the permanent drift gate |
| regenerated `brands/svg/**` | 3–5 | the actual fidelity fixes |
