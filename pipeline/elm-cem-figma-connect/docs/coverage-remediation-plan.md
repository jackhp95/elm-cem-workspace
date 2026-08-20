# Coverage remediation plan — the figma-only crescent

**Status:** PLAN ONLY. Nothing in this document has been applied. It dispositions every
figma-only family named in `plans/coverage-remediation-prompt.md` into exactly one of
**BIND** / **APPEND** / **UPSTREAM** / **SKIP**, with CEM↔Figma mappings verified against the
manifest and the Figma export. Extends `docs/coverage-and-gaps.md` (its four buckets A–D).

_Authored 2026-07-30 against: CEM `@m3e/web` 2.7.0 (`test/fixtures/m3e-web-2.7.0/dist/custom-elements.json`, 128 tags),
Figma export `research/figma-dumps/figma-export.m3-kit.json` (171 `COMPONENT_SET`s, `fileKey UtwpUdPiOZEuxp8Nq1d5yQ`),
`profiles/m3-kit/correspondence.json` (49 confirmed), and M3E-OKF `/Users/jhp/code/jackhp95/m3e-okf`._

---

## 1. Executive summary

The remediable crescent is **matching work, not new components.** Two families are genuine
`@m3e/web` gaps (Carousel, XR); everything else Figma draws is either a variant of an
already-bound component, a component `@m3e/web` already ships but the tool hasn't matched, or a
building-block fragment.

| Disposition | Families | Firm items | Net new confirmed CEM tags | Net new bound Figma sets |
|---|---|---|---|---|
| **BIND (new)** | Time picker (dial / input / period toggle) | 3 tags → 4 sets | **+3** | **+4** |
| **APPEND (+variant set)** | Modal date picker, List/Scrollable dialog, Range slider, Secondary tabs (×2), Search full-screen | 6 append targets → 7 sets | +0 (parents already confirmed) | **+7** |
| **UPSTREAM** | Carousel (2), XR spatial family (16) | 18 sets | — | — |
| **SKIP (fragment)** | ~23 building-block families | ~70 sets | — | — |
| **FLAGGED (human decides)** | Docked-input-desktop date picker, Centered slider, Bottom app bar | 3 sets | — | up to +3 |

**Firm outcome if executed:** 49 → **52** confirmed CEM entries; matched Figma sets 69 → **~80**;
figma-only crescent 102 → **~91** (or ~88 if the 3 flagged items are accepted). All new composed
bindings land **`gate:"example-verified"`** (force-published), not pixel-`approved` — consistent with
§6 of the prompt and the existing datepicker/dialog/list bankings.

**The single highest-value item** is the time-picker BIND: `@m3e/web` 2.7.0 added the whole
`m3e-timepicker*` family, so 3 real components are one manual-correspondence edit away from coverage.

---

## 2. Verification basis & method

Every BIND/APPEND below was checked on three axes (the prompt's hard requirement — a wrong binding
is worse than none):

1. **cemTag is real** — present in the 128-tag CEM manifest (`jq '.. | objects | select(.customElement)'`). ✓
2. **nodeId is a real `COMPONENT_SET`** — present in `figma-export.m3-kit.json .components[]` with `type:"COMPONENT_SET"`. ✓
3. **setName matches the export byte-for-byte** — `validateManualCorrespondence` compares `node.name === setName` exactly, **including the `.Building Blocks/` prefixes** several sets carry (e.g. the period selector's real name is `.Building Blocks/Period Selector`, **not** `Period Selector`). ✓
4. **Structure/example markup is authoritative** — taken from M3E-OKF `implementations/m3e-web/components/*.md` + `data/examples.json`, never invented. ✓

Mechanism facts that shape the dispositions (from `src/correspond/merge.mjs`):

- **`figmaSets`** (new bind) only applies to an **unbound** entry (`isUnbound`: `matcherKind:"code-only"` / `provenance:"auto-gap"` / proposed-with-empty-figmaSets). If the tag has **no** matcher candidate at all, `applyManualCorrespondence` **synthesizes** a fresh entry. A `figmaSets` array may hold **multiple** sets, each carrying its own `fixedAttrs` / `slugSuffix` / `example`.
- **`appendSets`** requires the parent tag to **already be bound** (`figmaSets.length ≥ 1`); it throws otherwise. `applyManualToExisting` mirrors it onto the confirmed entry so it lands live rather than parking in `proposedUpdate`.
- **Composed children** render via `examples.json[cemTag].children` (tag-level) or a per-set inline `example.children` (preferred for appendSets — it's per-file). The WC emitter always emits; the **Elm emitter emits only when the tag resolves an elm-facts `top` surface** (a few confirmed tags — `m3e-icon`, `m3e-tab`, the progress indicators — are Web-Components-only despite having a facts entry; confirm per tag empirically).
- **Banking**: appended sets ride their **already-confirmed** parent (no new `overrides.json` entry). A **new** BIND needs an `overrides.json` `{cemTag, status:"confirmed", gate:…}` line + `confirm`.

---

## 3. Per-family disposition table

Every family from the prompt's list, mapped. Node IDs and names are copied verbatim from the export.

### Group 1 — genuinely missing (bucket A)

| Family | Disposition | Reason |
|---|---|---|
| **Carousel** — `Carousel` (`53912:27480`), `Carousel - Full screen` (`54577:26060`) | **UPSTREAM** | No `m3e-carousel`. `m3e-slide`/`m3e-slide-group` are a pagination/scroll control, not an M3 media carousel (different semantics). |
| **XR / spatial family** (16 sets, see §6) | **UPSTREAM** | `@m3e/web` has **zero** XR tags. Largest genuine gap. |

### Group 2 — "covered by CEM but not matched"

| Family (Figma set → id) | Disposition | Target cemTag | Mechanism |
|---|---|---|---|
| **Dial picker** (`52949:27916`) | **BIND** | `m3e-timepicker-dial` | manual `figmaSets` |
| **Keyboard picker** (`52949:28053`) | **BIND** | `m3e-timepicker-input` | manual `figmaSets` |
| **Period Selector** (`.Building Blocks/Period Selector` `52949:28132`) + **- Horizontal** (`52949:28175`) | **BIND** | `m3e-timepicker-input-period-toggle` | manual `figmaSets` (2 sets) |
| **Modal date picker** (`51954:18136`) | **APPEND** | `m3e-datepicker` (`+ Input date picker`) | extend manual `figmaSets` (+set) |
| **Range slider** (`58008:11810`) | **APPEND** | `m3e-slider` (`+ Standard slider`) | `appendSets` |
| **Secondary tabs/Icon and label** (`54563:40366`), **Secondary tabs/Label only** (`54563:40319`) | **APPEND** | `m3e-tab` (`+ Primary tabs/*`) | extend manual `figmaSets` (+set) |
| **List dialog** (`52112:28937`), **Scrollable list dialog** (`52112:29186`) | **APPEND** | `m3e-dialog` (`+ Basic dialog`) | `appendSets` |
| **Docked input date picker [desktop]** (`51954:18567`) | **FLAGGED** → §5 | (`m3e-datepicker`?) | overlaps `Input date picker` |
| **Centered slider** (`58008:10979`) | **FLAGGED** → §5 | (`m3e-slider`?) | no distinct CEM attr |
| **Bottom app bar** (`51159:5105`) | **FLAGGED** → §5 | none faithful | no `m3e-bottom-app-bar` |
| **Local M3 calendar cell** (`51954:18817`), **Year** (`51954:18918`), **Menu button** (`.Building Blocks/Menu button` `51954:18957`) | **SKIP** | — | date-picker internals (§7) |
| **Hour / hour** (`52949:28086`, `52949:28218`) | **SKIP** | — | dial internals (§7) |

> **Note — the prompt bucketed a few items loosely.** `Bottom app bar` and `Menu button` appear in the prompt's "covered by CEM" group, but there is **no `m3e-bottom-app-bar` tag**, and `.Building Blocks/Menu button` is a date-picker-header dropdown building block (node prefix `51954:*` = the date-picker family), not a standalone `m3e-menu*` component. `docs/coverage-and-gaps.md` buckets both correctly (C/D); this plan follows the verified CEM, not the loose grouping.

> **Correction (value-add) — "Search full" is not a fragment.** The prompt lists it under group 3, but `Search full-screen layout` (`59178:4963`) is a real **mode variant** of the already-bound `m3e-search-view` (currently bound to `Search docked layout` with `mode:"docked"`). It is dispositioned **APPEND**, not SKIP. See §5.

### Group 3 — building blocks / states / fragments → all **SKIP** (except Search full-screen, promoted to APPEND)

See §7 for the full register with node IDs and per-family rationale.

---

## 4. BIND specifications (new tags)

All three tags are in the CEM manifest and **entirely unbound** today (absent from the 49-entry
correspondence). `m3e-timepicker-dial` / `-input` / `-input-period-toggle` are `display:block`, so
they render directly (unlike the `display:none` `m3e-timepicker` container — see the design note
below). All three have elm-facts entries, so each set yields **one WC + one Elm** file.

**Proposed `profiles/m3-kit/manual-correspondence.json` additions** (do NOT apply in this pass):

```jsonc
"m3e-timepicker-dial": {
  "figmaSets": [
    { "nodeId": "52949:27916", "setName": "Dial picker", "fixedAttrs": {}, "slugSuffix": "dial" }
  ],
  "note": "Time picker (2.7.0) dial surface. display:block — renders the clock face directly. Headline is m3e-timepicker container chrome (absent here), so a clean binding is example-verified, not pixel-approved."
},
"m3e-timepicker-input": {
  "figmaSets": [
    { "nodeId": "52949:28053", "setName": "Keyboard picker", "fixedAttrs": {}, "slugSuffix": "keyboard" }
  ],
  "note": "Time picker (2.7.0) keyboard/input surface. display:block."
},
"m3e-timepicker-input-period-toggle": {
  "figmaSets": [
    { "nodeId": "52949:28132", "setName": ".Building Blocks/Period Selector",              "fixedAttrs": {},                        "slugSuffix": "vertical" },
    { "nodeId": "52949:28175", "setName": ".Building Blocks/Period Selector - Horizontal", "fixedAttrs": { "orientation": "horizontal" }, "slugSuffix": "horizontal" }
  ],
  "note": "AM/PM period toggle. Vertical (default) + Horizontal variants. orientation is a real CEM attr (vertical|horizontal). Simple enough to pixel-gate."
}
```

| # | cemTag | Figma set (id) | exact `setName` | fixedAttrs / axes | `example.children` | gate |
|---|---|---|---|---|---|---|
| B1 | `m3e-timepicker-dial` ✓ | `52949:27916` ✓ | `Dial picker` ✓ | none (clock is self-rendered; `format` defaults `"12"`; optionally pin a determinate time via `set-attrs.json` `hour`/`minute`) | none | example-verified (possibly approvable) |
| B2 | `m3e-timepicker-input` ✓ | `52949:28053` ✓ | `Keyboard picker` ✓ | none (`format` default `"12"`) | none | example-verified |
| B3 | `m3e-timepicker-input-period-toggle` ✓ | `52949:28132` ✓ + `52949:28175` ✓ | `.Building Blocks/Period Selector` / `.Building Blocks/Period Selector - Horizontal` ✓ | 2nd set pins `orientation:"horizontal"` (real CEM attr per timepicker.md) | none | possibly `approved` (simple toggle) |

**Design note (why not bind the `m3e-timepicker` container?)** `<m3e-timepicker>` is `display:none`
and opens on a temporary surface (like `m3e-datepicker`/`m3e-dialog`). It has **no dedicated Figma
set** — the kit draws the picker through its dial/input *surface* sets, which map 1:1 to the
`display:block` sub-elements above. Binding the container would require a force-open harness for no
extra coverage and would double-bind the same sets. Recommendation: leave `m3e-timepicker` and
`m3e-timepicker-toggle` **code-only** (like `m3e-calendar`), and record that decision. If a future
pass wants the container too, bind it example-verified via force-open to `Dial picker`, mirroring
`m3e-datepicker` — but that is explicitly out of scope here.

**Axis-mapping caveat:** manual-correspondence entries always land with `axes:[] props:[]` (see
`applyManualCorrespondence`). Rich Figma-variant→CEM-attr axis maps (e.g. `Format=[12 hour,24 hour]`
→ `format`) are produced **only** by the auto-matcher, which these tags don't reach. So the manual
binds are *representative single-variant* bindings (the established pattern for `m3e-radio`,
`m3e-datepicker`, etc.). Pin the representative variant with `fixedAttrs`; full axis coverage is a
separate matcher-enhancement follow-up, not part of this remediation.

---

## 5. APPEND specifications (variants of already-bound components)

Each parent is **confirmed with ≥1 figmaSet** today (verified in `correspondence.json`), so the extra
set — whether via a new `appendSets` key (`m3e-slider`, `m3e-dialog`) or by extending an existing
manual `figmaSets` key (`m3e-datepicker`, `m3e-tab`, `m3e-search-view`; see the execution note) —
rides the parent's confirmed status: **no new `overrides.json` entry, no re-`confirm`.**

**Proposed `manual-correspondence.json` additions** (do NOT apply):

```jsonc
// (a) m3e-datepicker ALREADY has a manual figmaSets key — ADD the Modal set to THAT array
//     (a JSON object can't hold two "m3e-datepicker" keys, so this is not an appendSets key):
"m3e-datepicker": {
  "figmaSets": [
    { "nodeId": "51954:18540", "setName": "Input date picker", "fixedAttrs": { "variant": "docked" } },
    { "nodeId": "51954:18136", "setName": "Modal date picker",  "fixedAttrs": { "variant": "modal" }, "slugSuffix": "modal" }
  ],
  "note": "Docked (existing) + Modal (new). variant is a real CEM enum (datepicker.md). Calendar is internal shadow DOM → force-open, example-verified. Preserve the existing note text when merging."
},
// (b) m3e-slider and m3e-dialog are matcher-bound (NO existing manual key) → a new appendSets key is correct:
"m3e-dialog": {
  "appendSets": [
    { "nodeId": "52112:28937", "setName": "List dialog",            "fixedAttrs": {}, "slugSuffix": "list",            "example": { "children": [ { "tag": "span", "slot": "header", "text": "Choose an account" }, { "tag": "m3e-list", "children": [ { "tag": "m3e-list-item", "text": "ada@example.com" }, { "tag": "m3e-list-item", "text": "grace@example.com" }, { "tag": "m3e-list-item", "text": "Add account" } ] }, { "tag": "m3e-button", "slot": "actions", "attrs": { "variant": "text" }, "text": "Cancel" } ] } },
    { "nodeId": "52112:29186", "setName": "Scrollable list dialog",  "fixedAttrs": {}, "slugSuffix": "scrollable-list", "example": { "children": [ { "tag": "span", "slot": "header", "text": "Select a time zone" }, { "tag": "m3e-list", "children": [ { "tag": "m3e-list-item", "text": "GMT-08:00 Pacific" }, { "tag": "m3e-list-item", "text": "GMT-05:00 Eastern" }, { "tag": "m3e-list-item", "text": "GMT+00:00 UTC" } ] }, { "tag": "m3e-button", "slot": "actions", "attrs": { "variant": "text" }, "text": "Cancel" } ] } }
  ],
  "note": "M3 list/scrollable-list dialogs = m3e-dialog with a m3e-list body (dialog.md + list.md). No dedicated tags. example-verified (force-open)."
},
"m3e-slider": {
  "appendSets": [
    { "nodeId": "58008:11810", "setName": "Range slider", "fixedAttrs": {}, "slugSuffix": "range", "example": { "children": [ { "tag": "m3e-slider-thumb", "attrs": { "value": "25" } }, { "tag": "m3e-slider-thumb", "attrs": { "value": "75" } } ] } }
  ],
  "note": "Range slider = m3e-slider with two m3e-slider-thumb children (slider.md range example; isRange). Distinct from the single-thumb Standard slider already bound."
},
// (a) m3e-tab ALREADY has a manual figmaSets key (Primary tabs ×3, two already using slugSuffix+example) —
//     ADD these two Secondary entries to that SAME figmaSets array (identical shape to the existing ones):
"m3e-tab": {
  "figmaSets": [
    // …keep the 3 existing "Primary tabs/*" entries…
    { "nodeId": "54563:40366", "setName": "Secondary tabs/Icon and label", "fixedAttrs": {}, "slugSuffix": "secondary-icon-label", "example": { "children": [ { "tag": "m3e-icon", "slot": "icon", "attrs": { "name": "favorite" } }, { "tag": "span", "text": "Favorites" } ] } },
    { "nodeId": "54563:40319", "setName": "Secondary tabs/Label only",     "fixedAttrs": {}, "slugSuffix": "secondary-label-only", "example": { "children": [ { "tag": "span", "text": "Favorites" } ] } }
  ],
  "note": "Secondary tab-item sets mirror the existing Primary tabs/* entries. m3e-tab has NO primary/secondary attr (that lives on m3e-tabs) — same tag, distinct files via slugSuffix. Preserve the existing note + entries when merging."
},
// (a) m3e-search-view ALREADY has a manual figmaSets key (Search docked layout, mode:"docked") —
//     ADD the full-screen set to that SAME figmaSets array:
"m3e-search-view": {
  "figmaSets": [
    { "nodeId": "59178:4992", "setName": "Search docked layout",       "fixedAttrs": { "mode": "docked" } },
    { "nodeId": "59178:4963", "setName": "Search full-screen layout",  "fixedAttrs": { "mode": "fullscreen" }, "slugSuffix": "fullscreen", "example": { "children": [ { "tag": "input", "slot": "input", "attrs": { "placeholder": "Search" } }, { "tag": "m3e-list", "children": [ { "tag": "m3e-list-item", "text": "Result one" }, { "tag": "m3e-list-item", "text": "Result two" } ] } ] } }
  ],
  "note": "Docked (existing) + full-screen (new). mode:'fullscreen' VERIFIED against SearchViewMode = 'fullscreen'|'docked'|'auto' in the CEM .d.ts. Preserve the existing note when merging."
}
```

| # | Parent cemTag (existing set) | Append set (id) | exact `setName` | `slugSuffix` | fixedAttrs | example children | gate |
|---|---|---|---|---|---|---|---|
| A1 | `m3e-slider` (`Standard slider`) | `58008:11810` ✓ | `Range slider` ✓ | `range` | — | 2× `m3e-slider-thumb` (25/75) | example-verified |
| A2 | `m3e-tab` (`Primary tabs/*`) | `54563:40366` ✓ | `Secondary tabs/Icon and label` ✓ | `secondary-icon-label` | — | icon + label | example-verified |
| A3 | `m3e-tab` (`Primary tabs/*`) | `54563:40319` ✓ | `Secondary tabs/Label only` ✓ | `secondary-label-only` | — | label span | example-verified |
| A4 | `m3e-dialog` (`Basic dialog`) | `52112:28937` ✓ | `List dialog` ✓ | `list` | — | header + `m3e-list` + action | example-verified |
| A5 | `m3e-dialog` (`Basic dialog`) | `52112:29186` ✓ | `Scrollable list dialog` ✓ | `scrollable-list` | — | header + `m3e-list` + action | example-verified |
| A6 | `m3e-datepicker` (`Input date picker`) | `51954:18136` ✓ | `Modal date picker` ✓ | `modal` | `variant:"modal"` ✓ | none (calendar internal) | example-verified |
| A7 | `m3e-search-view` (`Search docked layout`) | `59178:4963` ✓ | `Search full-screen layout` ✓ | `fullscreen` | `mode:"fullscreen"` ✓ (CEM `.d.ts`) | input + `m3e-list` | example-verified |

**Execution note on JSON structure.** `manual-correspondence.json` is one object keyed by cemTag; a
key takes **either** the `appendSets` branch **or** the `figmaSets` branch (never both), and JSON
can't repeat a key. So the mechanism depends on whether the parent already has a manual key:

- **No existing manual key (matcher-bound):** `m3e-slider`, `m3e-dialog` → add a **new key with `appendSets`**. `applyManualToExisting` appends to the confirmed entry (confirmed-safe, idempotent).
- **Existing manual `figmaSets` key:** `m3e-datepicker`, `m3e-tab`, `m3e-search-view` → **extend that key's `figmaSets` array** with the new set(s), each carrying its own `fixedAttrs`/`slugSuffix`/`example`. `applyManualToExisting` adopts the full `figmaSets` list onto the confirmed entry, landing the new sets live. The blocks above already show the merged arrays — keep the existing entries and note text.

Either way the added set rides its parent's existing **confirmed** status (no new `overrides.json`
entry, no `confirm` needed for appends). Do a dry `pnpm match --profile m3-kit` and confirm no throw
+ a byte-stable diff of unrelated entries before proceeding.

---

## 6. UPSTREAM records (@m3e/web feature requests — out of scope for this repo)

The tool cannot bind a component that has no CEM tag. Record these as `@m3e/web` implementation
requests; there is no correspondence/emit/gate action here.

**U1 — Carousel.** Figma: `Carousel` (`53912:27480`), `Carousel - Full screen` (`54577:26060`).
No `m3e-carousel`. `m3e-slide`/`m3e-slide-group` are pagination, not a media carousel. Request an
`m3e-carousel` (hero / center-aligned / multi-browse / uncontained / full-screen layouts per the
Figma `Layout` axis).

**U2 — XR / spatial family (16 sets).** `@m3e/web` has no XR components at all. Sets:

| Node ID | Name |
|---|---|
| `58108:88092` | `XR/XR App Bar` |
| `58108:87558` | `XR/XR Dialog` |
| `57547:4795` | `XR/XR Navigation bar` |
| `57547:2577` | `XR/XR Navigation Rail` |
| `58823:1688` | `XR/XR Toolbar` |
| `58823:1763` / `58823:1786` / `58823:1831` | `XR/Building Blocks/Surface high/{Icon button, Icon button toggleable, Button toggleable}` |
| `58823:2013` / `58823:2036` / `58823:2081` | `XR/Building Blocks/Surface/{Icon button, Icon button toggleable, Button toggleable}` |
| `58823:1887` / `58823:1910` / `58823:1955` | `XR/Building Blocks/Tertiary container/{Icon button, Icon button toggleable, Button toggleable}` |
| `57547:1794` | `Building Blocks/XR/Navigation rail/Nav item` |
| `57547:4010` | `Building Blocks/XR/Navigation bar/Nav item` |

This is the single largest genuine gap. It is a whole spatial-surface subsystem, not a single
component — recommend one tracking issue for the family, not per-set.

---

## 7. SKIP register (building blocks / states / sub-parts)

These are not standalone design components — they are slot fillers, density/state building blocks,
color-style blocks, baselines, or demo assets. Rationale per `docs/coverage-and-gaps.md` bucket D.
Binding any of them would either double-bind a set already claimed by its parent tag or emit a
meaningless fragment snippet.

| Family (prompt label) | Node IDs | Why SKIP |
|---|---|---|
| **.Shape** | `55343:12390` | The real shape component is already bound (`m3e-shape` → `Shape Set` `58548:7248`). `.Shape` is the raw shape/token primitive page. |
| **Card states** | `52350:27635`, `52350:27728`, `52347:27855` | Elevated/Filled/Outlined surface-style blocks of `m3e-card` (already bound to Stacked/Horizontal card). |
| **Button group** | `57998:47021`, `:46976`, `:46931`, `:47066`, `:46886` | Connected-segment size blocks of `m3e-button-group` (already bound to Connected/Standard button group). |
| **Content** | `58966:4249`, `59106:13378` | Generic content-slot building blocks. |
| **Leading element** | `58966:4243`, `59106:13333`, `54061:37101` | List/menu leading-slot building blocks. |
| **Trailing element** | `58966:4255`, `59106:13356`, `54061:37105`, `55286:1288` | Trailing-slot building blocks (+ selected state). |
| **Reveal element** | `59106:13386` | List reveal-on-swipe building block. |
| **List Item** (swipe/density) | `59106:13321` (Swipe), `51964:65924`/`:68562`/`:63037` (density baselines), `59106:13414` (Accordion buttton) | Interaction/density blocks of `m3e-list-item` (bound to `List item`). Swipe is a low-value optional append at best (§8). |
| **Menu list item** | `54061:37026`, `:37051`, `:37076`, `54061:36963` (baseline), `58966:4171` (Vibrant) | Density/color blocks of `m3e-menu-item` (bound to `Menu item/Standard`). |
| **Navigation bars** | `58016:37099`, `58016:36961` | Horizontal/Vertical nav-item blocks; `m3e-nav-item` is already bound (`Building Blocks / Nav item`). |
| **Navigation rail** | `58016:36557`, `58016:36306` | Same — nav-item blocks; rail container already bound (`m3e-nav-rail`). |
| **Progress indicator** | `58005:7970`, `58005:7976` | Wave-segment internals of the (already bound) linear/circular progress indicators. |
| **Standard** | `58027:76103`, `58694:34208`, `58027:76098` | Standard-color icon-button blocks; `m3e-icon-button` already binds 8 icon-button sets. |
| **Vibrant** | `58027:76206`, `58694:35488`, `58027:76201` | Vibrant-color icon-button blocks (same as above). |
| **Bottom sheets** | `57314:35893` | Content block of `m3e-bottom-sheet` (bound to `Bottom sheet`). |
| **Side sheets** | `57314:35886` | Content block of `m3e-drawer-container` (bound to `Side Sheet`). |
| **Flat** / **On(-scroll)** | `58114:20523`, `58114:20530` | Search-bar scroll-state blocks; `m3e-search-bar` already bound. |
| **Examples** | `56384:120` | `Examples/Layout grid` — layout scaffolding, not a component. |
| **Keyboard** | `52515:32926` | On-screen keyboard **mockup asset** used in picker demos; not an M3 web component. |
| **Menu button** | `51954:18957` | Date-picker header month/year dropdown block (node family `51954:*` = date pickers). Not `m3e-menu*`. |
| **Local M3 calendar cell / Year** | `51954:18817`, `51954:18918` | Single day/year cells — internal to `m3e-calendar`/`m3e-year-view` rendering; no standalone tag. |
| **Hour / hour** | `52949:28086`, `52949:28218` | Single dial numeral + dial-hand-line — internals of `m3e-timepicker-dial`. |
| **Input / Direct Input (keyboard) input** | `52949:28114`, `52949:28121` | Single time-field building blocks — internals of `m3e-timepicker-input`. |

_(Also implicitly skipped: the `.Building Blocks/App bar/Content/*` and `.Building Blocks/Snackbar-*`
sub-part sets, and the `Search *-layout (baseline)` duplicates `52977:33958`/`52977:34015` — same
building-block rationale.)_

---

## 8. Flagged / ambiguous items (human decision required)

The prompt is explicit: flag ambiguous pairs rather than guess. These three do not have a clean,
faithful mapping; each carries a recommendation.

**F1 — `Docked input date picker [desktop]` (`51954:18567`).** A second docked-input date picker
set alongside the already-bound `Input date picker` (`51954:18540`, pinned `variant:"docked"`).
Binding it would emit a near-duplicate docked snippet.
**Recommendation: SKIP** (redundant with the existing docked binding). *Alternative:* low-priority
`appendSets` to `m3e-datepicker` with `slugSuffix:"docked-desktop"` if the team wants an explicit
desktop-layout Code Connect node. Not worth the acceptance-test churn on its own.

**F2 — `Centered slider` (`58008:10979`).** M3's centered slider fills from the track center.
`m3e-slider`'s CEM has **no `centered` (or centered-origin) attribute** (only `disabled`, `discrete`,
`labelled`, `min`, `max`, `step`, `size` — verified in slider.md). So there is no CEM feature that
distinguishes it from `Standard slider` (already bound).
**Recommendation: SKIP** (no distinct CEM representation). *Alternative:* if `@m3e/web` is confirmed
to render a centered-origin track for a symmetric range (e.g. `min:"-50" max:"50"` with a mid
value), append with those `set-attrs` — but do **not** assert centered rendering without verifying
it in the component. If centered origin is genuinely unsupported, this is an UPSTREAM note instead.

**F3 — `Bottom app bar` (`51159:5105`).** There is **no `m3e-bottom-app-bar`**. Neither existing
tag is a faithful match: `m3e-app-bar` is a *titled top bar* (has `title`/`subtitle`/`size`
small|medium|large, `centered`), whereas the bottom app bar is a title-less bottom action bar of
1–4 icon buttons + an optional FAB (`Show FAB`, `Icons=[1,2,3,4]`). `m3e-toolbar` (a row of
icon-buttons, floating/docked, standard/vibrant) is *structurally* the closest but semantically
distinct (a contextual action cluster, not a persistent bottom bar).
**Recommendation: UPSTREAM + SKIP** — record an `@m3e/web` gap ("bottom app bar" as a first-class
component) and do not bind, because a wrong binding is worse than none. *Alternative:* if coverage
is prioritized over fidelity, a **low-confidence** `appendSets` to `m3e-toolbar`
(`slugSuffix:"bottom-app-bar"`, an icon-button + FAB example) is the least-wrong option — but it
should be human-approved as `example-verified` with an explicit "semantic approximation" note.

---

## 9. Prioritized execution order

Ordered by value ÷ risk. P1–P5 reuse the proven `appendSets`+inline-example pattern (lowest risk);
P6 introduces new tags (needs `overrides` + `confirm` + `CONFIRMED_TAGS` update); P7–P8 are
non-code.

1. **P1 — Range slider → `m3e-slider`** (A1). Trivial, high value, mirrors existing thumb example.
2. **P2 — Secondary tabs → `m3e-tab`** (A2, A3). Trivial; direct mirror of the Primary tabs appends.
3. **P3 — List + Scrollable list dialog → `m3e-dialog`** (A4, A5). Composed inline examples; force-open example-verified.
4. **P4 — Modal date picker → `m3e-datepicker`** (A6). One `variant:"modal"` set; force-open.
5. **P5 — Search full-screen → `m3e-search-view`** (A7). `mode:"fullscreen"` (verified against `SearchViewMode` in the CEM `.d.ts`).
6. **P6 — Time-picker BIND** (B1, B2, B3). Biggest coverage gain: **+3 real components**. New tags → `overrides.json` + `confirm` + `CONFIRMED_TAGS`/`49`-count updates.
7. **P7 — Resolve the 3 flags** (§8) with the human. Default: SKIP F1/F2, UPSTREAM F3.
8. **P8 — File UPSTREAM tickets** (§6): one `m3e-carousel` request, one XR-family request.

P1–P5 can be batched into a single correspondence edit + one `confirm`/`emit` pass. P6 is a separate
commit (it touches the confirmed set and its acceptance tests).

---

## 10. Runbook — confirm → emit → gate → publish (per batch)

For each batch (P1–P5 together, then P6):

1. **Edit `profiles/m3-kit/manual-correspondence.json`** — add the `appendSets`/`figmaSets` keys from §4–§5 (merging into existing keys for `m3e-datepicker`/`m3e-tab`/`m3e-search-view`).
2. **(No `examples.json` edit needed)** — every composed binding above carries a **per-set inline `example`**, which the emitters prefer over the tag-level `examples.json`. (Only edit `examples.json` if you choose a tag-level example instead.)
3. **`pnpm match --profile m3-kit`** — validates manual-correspondence against the live CEM + export (fail-loud on any bad tag/nodeId/setName), applies it, and merges — preserving all confirmed entries. Confirm **no throw** and a clean diff.
4. **(BIND batch P6 only) edit `profiles/m3-kit/overrides.json`** — add `{ "cemTag": "m3e-timepicker-dial", "status":"confirmed", "gate":"example-verified", "note":"…" }` for each of B1/B2/B3, then **`node src/cli.mjs confirm --profile m3-kit`** to flip proposed→confirmed. (APPEND batches P1–P5 need **no** overrides edit — the appended sets ride their already-confirmed parent.)
5. **`pnpm emit --profile m3-kit`** — regenerates `generated/m3-kit/{web-components,elm}/**` deterministically. Note the printed `emit: wrote N file(s)` for both labels.
6. **`pnpm check`** — must report **0 drift, 0 orphan** + token byte-stability. (It will fail until the regenerated `generated/**` is committed — commit it.)
7. **Visual gate (optional, only for the pixel-gateable items — B3 period toggle, maybe B1 dial).** `node src/visual/gate.mjs --tag=<cemTag> --channel=cem-<hex>` needs the live Figma bridge (`bun extract/relay/socket.ts` on :3055 + the self-hosted plugin in DESIGN mode; `src/visual/harness/reveal.mjs` reveals hidden-by-default components). **Composed/force-open items (A4–A7, B1–B2) are banked `example-verified` and force-published — no pixel gate.**
8. **Update acceptance tests** (§11), then **`pnpm test`** → expect **706 pass / 0 fail** (adjusted counts).
9. **Publish** — blocked project-wide on the unresolved canonical `--file-key` (`STATUS.md`: `KujuFlfJSwHI6ua1b7RZvL` vs `UtwpUdPiOZEuxp8Nq1d5yQ`) and the `extract/` IP review. **Out of scope for this remediation** — do not publish as part of these edits. When unblocked: `publish --profile m3-kit --file-key <chosen>` (a copy via `--file-key`, never the canonical kit).

---

## 11. Acceptance-test updates required

Anchors verified this session. Update **only after** `pnpm emit` prints the real counts — set
assertions to the emitted numbers rather than a predicted number.

**`test/correspond.test.mjs`** (BIND batch P6 only):
- `CONFIRMED_TAGS` (line 494) — add `"m3e-timepicker-dial"`, `"m3e-timepicker-input"`, `"m3e-timepicker-input-period-toggle"` (keep the array sorted).
- The hard-coded `49` (line 503) → **`52`**; the assertion message and the stale `"exactly the 32 gate-banked tags"` comment (line 508) should be corrected too.
- APPEND batches (P1–P5) add **no** new cemTags → `CONFIRMED_TAGS` unchanged.

**`test/smoke.test.mjs`**:
- `emit: wrote 211 file(s)` (line 171) → new WC total. **Firm delta = +11** (one WC file per new set: B1, B2, B3×2, A1, A2, A3, A4, A5, A6, A7) → expect **`222`**. Update the stale arithmetic comment (line 170) too.
- The `nonIconFiles` `deepEqual` list (from line 179) — insert, in sorted position, the new filenames (each is `${cemTag}-${slug}`):
  `m3e-datepicker-modal.figma.ts`, `m3e-dialog-list.figma.ts`, `m3e-dialog-scrollable-list.figma.ts`, `m3e-search-view-fullscreen.figma.ts`, `m3e-slider-range.figma.ts`, `m3e-tab-secondary-icon-label.figma.ts`, `m3e-tab-secondary-label-only.figma.ts`, `m3e-timepicker-dial-dial.figma.ts`, `m3e-timepicker-input-keyboard.figma.ts`, `m3e-timepicker-input-period-toggle-vertical.figma.ts`, `m3e-timepicker-input-period-toggle-horizontal.figma.ts`.
- Any Elm-label MANIFEST/filename list — mirror the same basenames with the `-elm` suffix, **minus any Web-Components-only tag**. `m3e-tab` is flagged Web-Components-only in its confirmation note — if that holds, the two `m3e-tab-secondary-*-elm.figma.ts` files are **not** emitted, so the Elm delta is **+9**, not +11. **Confirm empirically** from the `emit` output; do not hard-code before running.

**`test/emitter-api.test.mjs`**:
- The filtered-emit `emit: wrote 26 file(s)` (line 327) and any per-label subtotal — re-derive from the run if the filter set overlaps the new tags; likely unchanged for P1–P5 unless the test's profile subset includes these tags.

**Rule of thumb:** each newly-bound/appended Figma set = **+1 Web Components file always**, **+1 Elm
file iff the tag resolves an elm-facts `top` surface**. Read the two `emit: wrote N` lines and set
every count assertion to the observed value; then `pnpm check` (drift) is the backstop that the
committed `generated/**` matches.

---

## 12. Coverage projection

| Metric | Now | After firm (P1–P6) | After firm + flags accepted |
|---|---|---|---|
| Confirmed CEM entries | 49 | **52** (+3 timepicker) | 52 |
| Matched Figma sets (of 171) | 69 | **~80** (+11) | ~83 (+3) |
| Figma-only crescent sets | 102 | **~91** | ~88 |
| Generated WC files | 211 | **222** (+11) | up to 225 |
| Generated Elm files | 211 | **~220** (+9, pending `m3e-tab` elm check) | ~223 |

Remaining crescent after this pass is, by construction, **only** genuine gaps (Carousel, XR → §6)
and building-block fragments (§7) — i.e. the "bottom line" of `docs/coverage-and-gaps.md` holds:
the matchable coverage work is closed, and what's left is upstream-implementation or
not-a-component.

---

## Appendix — one-line disposition index

- **BIND:** `m3e-timepicker-dial`←Dial picker · `m3e-timepicker-input`←Keyboard picker · `m3e-timepicker-input-period-toggle`←Period Selector(+Horizontal)
- **APPEND:** `m3e-slider`+Range · `m3e-tab`+Secondary(icon-label, label-only) · `m3e-dialog`+List(+Scrollable) · `m3e-datepicker`+Modal · `m3e-search-view`+Full-screen
- **UPSTREAM:** Carousel(×2) · XR family(×16)
- **FLAGGED:** Docked-input-desktop (→SKIP) · Centered slider (→SKIP) · Bottom app bar (→UPSTREAM)
- **SKIP:** ~23 building-block/state/sub-part families (§7)
