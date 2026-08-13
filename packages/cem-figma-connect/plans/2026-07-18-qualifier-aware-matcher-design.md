# Qualifier-Aware Matcher Tier — Design

**Status:** approved-in-principle 2026-07-18 (Jack). Design-bearing matcher change.

**Goal:** Bind the ~9 real single-element components the matcher currently drops because the M3 Figma kit names them with *descriptive qualifiers* the CEM tags don't carry (`Generic avatar`→`m3e-avatar`, `Stacked card`→`m3e-card`, `Connected button group`→`m3e-button-group`, …). Maximize coverage **exactly up to where the CEM can distinguish the variants** — never guess past that.

---

## 1. Root cause (recap)

`match()` (src/match/matcher.mjs) has two binding tiers:

- **exact** — `bySlug.get(candidate.slug)`, where `slugify` (src/match/normalize.mjs) strips only `m3e-` and `Building Blocks/`, kebab-folds, and singularizes.
- **fuzzy** — a weighted name/description/doc-URL score, accepted at ≥ `FUZZY_ACCEPT_THRESHOLD` (0.5).

The kit prefixes component sets with qualifiers — `Generic`, `Plain`, `Basic`, `Stacked`, `Horizontal`, `Standard`, `Connected`, `Circular-determinate` — that `slugify` does not strip. So `stacked-card ≠ card` (exact miss), and the qualifier tokens dilute the fuzzy name signal to ~0.42 (< 0.5). 18 CEM tags have a token-containment Figma set that the matcher drops; ~9 are real standalone components.

---

## 2. The containment tier

A **new binding tier, ordered between exact and fuzzy.** It fires only for Figma candidates that did **not** exact-match.

### 2.1 Matching rule — token-subset, longest-CEM-wins

Let `setTokens` = the candidate slug split on `-` (a Set). A CEM tag *contains-matches* the candidate when **every** token of the CEM tag's slug is present in `setTokens` (subset — order-independent, so an *infixed* qualifier is handled). Among all contain-matching CEM tags, the **longest** (most tokens) wins — the most-specific match; ties (equal token count) → the lexicographically-smallest tag via the shared ordinal comparator (deterministic, but no real tie occurs in the fixture).

- `connected-button-group` → `{connected, button, group}`; `button-group` (2 tokens ⊆) beats `group`/`button` (1) → `m3e-button-group`.
- `stacked-card` → `card` (1) → `m3e-card`; qualifier tokens = `{stacked}`.
- `circular-determinate-progress-indicator` → `{circular, determinate, progress, indicator}`; `circular-progress-indicator` (3 tokens ⊆, infix `determinate` ignored) → `m3e-circular-progress-indicator`; qualifier = `{determinate}`.
- `button-segment` → `button-segment` (2) beats `button` → `m3e-button-segment`, never `m3e-button`.

The tokens of `setTokens` not in the winning CEM slug are the **qualifier**.

### 2.2 Qualifier resolution — reuse `valueMatch`, never guess

Resolution runs in one of three modes, chosen by the group's shape. It reuses the **existing** `valueMatch`/`bestValueMatch` (exact/synonym/fuzzy), `proposeBooleanAxis` polarity words, and — critically — `proposeFusionValues`' **leftover** rule (fusion already assigns the bare `Button` the one enum value no sibling claimed, e.g. `filled`).

1. **Sole set for the head-noun** (avatar=`Generic avatar`, tooltip=`Plain Tooltip`, radio=`Radio buttons`) → bind directly. The qualifier is a strippable adjective; with exactly one set there is nothing to be ambiguous *with*.

2. **Attr-resolvable group** — the members' qualifiers collectively map to ONE CEM attribute: at least one member's qualifier value-matches a value of that attr, and any member whose qualifier does *not* value-match takes that attr's **unique leftover** value (the `proposeFusionValues` mechanism). Bind all members, each with its fixed attr — one entry, N `.figma.ts` files, like button.
   - card: `Horizontal`→`orientation:horizontal` (exact value-match); `Stacked` takes the leftover `vertical` — so `Stacked` never needs a hand-written synonym.
   - button-group: `Connected`→`variant:connected`, `Standard`→`variant:standard` (both exact).
   - progress: `determinate`/`indeterminate`→the `indeterminate` boolean (indeterminate=true; determinate=false).

3. **Canonical-only** — the group's qualifiers do NOT collectively map to a single attr (`dialog`: Basic/List/Scrollable; `slider`: Standard/Centered/Range have no matching CEM attr values, and no unique-leftover attr exists). Bind ONLY the member whose qualifier is a recognized base marker (`basic`, `standard`, `plain`, `generic`, `default`) as the plain component (`Basic dialog`→`m3e-dialog`, `Standard slider`→`m3e-slider`); **the other members become gaps** for human review. Exactly one base-marker set per head-noun → unambiguous.

If none of the three apply (multiple sets, no attr resolution, no base marker), **bind nothing** at this tier — fall through to fuzzy/gap. This is the no-ambiguity guarantee.

`Range slider` stays gapped by construction: it is a structurally different (two-thumb) element that `m3e-slider` (single-value) would render *wrong* — an error, not coverage.

### 2.3 Multi-set → one tag: qualifier groups (fusion-shaped)

Two candidates (`Stacked card`, `Horizontal card`) binding `m3e-card` would collide — `buildProposals` fails loud on two candidates sharing a `cemTag`. Fusion (src/match/fusion.mjs) already solves the identical problem for button's 5 sets, but it groups on a `<Base> - <value>` **suffix**; our qualifier is a **prefix**, so fusion won't group these.

**New CEM-aware grouping** (a `qualifier.mjs` sibling to `fusion.mjs`): among the not-exact-matched sets, group those that contain-match the *same* CEM tag slug as head-noun into ONE candidate carrying per-set resolved qualifiers. The group reuses the existing **FusionGroup shape** (`{ base, baseSlug, page, setIds, members:[{id,name,set,value}], variantAxes, nonVariantProps }`) where each member's `value` is its resolved fixed-attr value. Downstream is UNCHANGED: `proposeFusionValues` binds the values, and the html-label + elm emitters already emit one `.figma.ts` per member set (button's 5 files). A sole-set head-noun (avatar) yields a one-member group → a single ordinary set candidate.

**Implementation note (post-approval fix):** the shared fusion-shape helpers (`mergedVariantAxes`, `mergedNonVariantProps`) and the identity fold (`foldIdentity`, previously `foldToken`/`foldWord`) now live in `normalize.mjs` (the zero-dep primitives home), imported by both `fusion.mjs` and `qualifier.mjs` — no import cycle exists. The original implementation comment claiming the modules "must stay independent" was incorrect; `normalize.mjs` has no deps on either, so both can freely import from it.

### 2.4 Integration point

`match()` (matcher.mjs) already calls `buildFigmaCandidates(figma)`. Thread the CEM slug index (`bySlug` keys) into candidate assembly so the qualifier grouping is CEM-aware:

```
buildFigmaCandidates(figma, cemSlugs):
  groups        = detectFusionGroups(figma.sets)                    // existing, suffix-based
  consumed      = union(group.setIds)
  qualGroups    = detectQualifierGroups(remaining sets, cemSlugs)   // NEW, prefix/head-noun
  consumed     += union(qualGroups.setIds)
  … remaining singleton sets, standalones, icon page (unchanged)
```

In the `match()` tier loop, a qualifier-group candidate carries its resolved fixed-attrs; it binds at a new `tier:"contains"` with `score` below exact's 1.0 (so a genuine exact match always wins) and above fuzzy. Leading-dot internal sets stay excluded (as at exact tier). Sets already consumed by a real exact match are never re-grouped, so `m3e-chip` (base) can never grab `Filter chip` (consumed at exact).

---

## 3. Guarantees

- **No ambiguity / no wrong bindings:** a set binds only when its qualifier value-matches an attr, or it is the sole/canonical set. Unresolved multi-set variants become gaps.
- **False-positive guard is structural:** exact-tier consumption runs first (specific chips gone before containment); most-specific longest-match prevents `button` grabbing `button-segment`/`button-group`.
- **Determinism / byte-stability:** every comparison uses the existing ordinal comparators (`byString`/`byKey`) and `valueMatch`; longest-match and group ordering are deterministic. The A8 tracer test's byte-stable re-match must still hold.

---

## 4. Coverage outcome (grounded in verified CEM + dump data)

| CEM tag | Figma set(s) | Binds via | Result |
|---|---|---|---|
| m3e-avatar | Generic avatar | sole-set | ✅ |
| m3e-tooltip | Plain Tooltip | sole-set | ✅ |
| m3e-radio | Radio buttons | — | ❌ GAP (execution finding): `radio-button` slug contains `button`; the 1-token tie `radio` vs `button` breaks by ordinal to `m3e-button` (fusion-consumed) → radio drops rather than mis-bind. Safe, but a coverage miss. |
| m3e-button-group | Connected / Standard button group | `variant` (exact value-match) | ✅ fused |
| m3e-card | Stacked / Horizontal card | `orientation` (Horizontal exact; Stacked = leftover `vertical`) | ✅ fused |
| m3e-circular-progress-indicator | Circular-determinate / -indeterminate | `indeterminate` (boolean) | ✅ fused |
| m3e-linear-progress-indicator | Linear-determinate / -indeterminate | `indeterminate` (boolean) | ✅ fused |
| m3e-dialog | Basic dialog (canonical) | canonical; List/Scrollable = gap | ⚠️ partial |
| m3e-slider | Standard slider (canonical) | canonical; Centered/Range = gap | ⚠️ partial |

Net (as-built): **6 clean** (avatar, tooltip, button-group, card, both progress-indicators) **+ 2 partial** (dialog, slider canonical) **+ 2 bonus sub-parts** (menu-item, nav-item — proposed, harmless) **− radio** (button-tie gap). 10 `tier:contains` proposed entries total. Each newly-matched component is then gate-verified OFFLINE (its set is already captured) and banked only on a passing gate + human visual review — the established bank loop; matching is necessary, not sufficient.

---

## 5. Testing

- **Unit (`normalize`/`qualifier`):** `containsMatch` longest-wins (`connected-button-group`→`button-group` not `button`); qualifier resolution (`Horizontal`→orientation:horizontal, `Connected`→variant:connected, `determinate/indeterminate`→boolean); sole-set + canonical paths; the no-bind case (`List dialog`→null).
- **Integration (`matcher`):** on the real m3-kit fixture, assert the 7 clean tags now bind at `tier:"contains"` with the expected fixed-attrs, and `List dialog`/`Range slider` remain gaps. Assert `m3e-chip` still does NOT grab the specific chips (exact-consumed).
- **Regression:** the A8 tracer byte-stable re-match holds; the existing 13 confirmed entries are unchanged (they exact-match, unaffected by the new tier); full `pnpm test` green.

---

## 6. Out of scope (explicit)

- **Content-modeling** for the gapped variants (List/Scrollable dialog, Centered slider) and any `m3e-range-slider` — separate effort; they stay in the gap report.
- **Sub-part / building-block** contain-matches (nav-item, menu-item, accordion, calendar-cell, button-segment) — these are composites/building-blocks, deferred with the earlier composite-fidelity finding. The tier *may* bind them structurally, but banking them is out of scope here.
- **Banking** the newly-matched components — a follow-on (gate + confirm + emit + tracer-test updates), one per component, after this matcher change lands.
