# Gate Content-Remediation Plan

Source: the visual-gate review pass over all 81 non-icon bindings (review UI at
`render-cache/coverage-review-all/`). The overriding priority (user, verbatim):
**"a thousand times more important than anything else, get content to match."**
Then: trim whitespace, and set representative widths for size-mismatched components.

## Guiding principles
- **Content-match is the top goal.** Use the Figma plugin (`mcp__plugin_figma_figma__*`,
  esp. `get_code_connect_map` / `get_design_context` / `get_metadata`) to extract
  the actual content/props inside each Figma set; the MCP server is a rate-limited
  fallback. Match code examples to what Figma shows.
- **Two surfaces to fix, keep them straight:**
  - **Render-harness only** (`scratchpad/render-all.mjs` + `gate-review.mjs`): whitespace
    trim, force-open/activate, hover emulation, representative render widths. These do
    **not** touch shipped bindings. Low-risk, central.
  - **Shipped binding** (`manual-correspondence.json` example children / `axes` / `props`,
    `set-attrs.json`, `examples.json`, or the emitters): content, variant-mapping,
    state-wiring, mapping-bug fixes. **TDD these** and re-run `pnpm emit`/`check`/`test`.
- **Conflict rule (user):** if a gate fix would regress the *actual shipped binding* or
  its real-world usage, **stop and raise it** (see CONFLICTS section). Otherwise proceed.
- **Figma "variants" are settings.** A Figma variance (rounding, elevation, size, selected)
  maps to a component attribute *sometimes* — verify per component; don't assume 1:1.
- **Shared image asset** (Phase C): Figma reuses one placeholder image inside avatars/cards/
  list-leading/etc. Extract + store it once; reference from every image slot.

Binding facts (from `correspondence.json`) are inlined per row (setName[nodeId], fixedAttrs).

---

## Phase A — Render-harness fixes (central, low-risk, do FIRST)

These are shared mechanisms in `render-all.mjs`. Fixing them re-renders many components at
once and removes noise before per-component content work. **None touch shipped bindings.**

### A1. Whitespace trim (applies to ~all, esp. overlays)
Today overlays get a **full-page** screenshot (huge whitespace); inline get `#stage`.
**Action:** after render, screenshot the tight element bbox (or the top-layer dialog/popover
element), then trim transparent margins (sharp/pngjs bbox crop) before writing.
Explicitly named by user: **app-bar** (width, below), **timepicker dial/keyboard** ("random
white space"), **period-toggle vertical/horizontal** ("white space"), **tooltip/rich-tooltip**
(after hover), and generally all overlays.

### A2. Force-open / activate (components that render blank/closed)
`revealSrc` already fires popover/open/show, but these still look wrong — need real activation:
- **m3e-bottom-sheet** `Bottom sheet[51827:5859]` — code not opening; user expects the **top
  dimple/drag-handle**. Investigate open/`show()`/`open` attr + a settle tick.
- **m3e-drawer-container** `Side Sheet[53198:27851]` — only main content shows; the drawer/end
  panel isn't activated. Needs the drawer opened.
- **m3e-list-item** `List item[59106:13183]` — renders **totally blank**. Investigate (likely
  needs slotted content to have height; see B row too).
- **m3e-search-view (docked)** `Search docked layout[59178:4992]` fa=mode:docked — renders as a
  **gray block/nonsense**. Comprehensive investigation of docked open state.
- **m3e-shape** `Shape Set[58548:7248]` — **invisible** in code (Figma = purple circle).
  Investigate (shape needs a size/fill/token to be visible).
- **m3e-loading-indicator** `Loading indicator[58005:8555]` — renders a bare **square**.
  Investigate; may be a `LIMITATION` (animated), see below.
- **m3e-tooltip** `Plain Tooltip[54061:33881]` — **blank**; only shows on hover.
- **m3e-rich-tooltip** `Rich Tooltip[54061:33872]` — not working; hover-gated.
- **m3e-expandable-list-item** `List item - Accordion[59106:13316]` — code shows it **expanded**;
  Figma shows **collapsed** single item. Render should be collapsed (don't force-expand).

### A3. Hover emulation (tooltips)
**Action:** for `m3e-tooltip` / `m3e-rich-tooltip`, dispatch hover / focus on the anchor (or call
the component's show API), wait, screenshot, then trim. Named: both tooltips.

### A4. Representative render width (size way-off)
User: "In components where we notice a large width difference … identify what width we should
set in the code." Set a sensible stage width (or component width) for:
- **m3e-app-bar** `App bar[58114:20565]` — "looks good, just wrong width."
- **m3e-linear-progress-indicator** `…determinate[58005:7997]` — code has **zero width**, Figma
  substantial. Needs an explicit width (container or `--` width) so the bar shows.
- **m3e-menu-item** `Menu item/Standard[58966:4100]` — "width is wrong" (also CONTENT: no
  trailing chevron → B).

### A5. Blank-render investigations (root-cause, may cross into B)
Group for a focused debugging batch: **list-item, shape, loading-indicator, search-view docked,
bottom-sheet, drawer** — determine per-item whether it's a harness activation issue (A) or a
binding/content issue (B).

---

## Phase B — Binding / example fixes (per-component, TDD, parallelizable)

Priority: **content-match**. For each, pull the real Figma content via the plugin, update the
shipped example (`manual-correspondence.json` inline `example.children`, or `examples.json`, or
`set-attrs.json`), re-emit, verify both labels, re-render the gate. Batches are independent.

### Batch B1 — Buttons & button-group (shared "missing content" bug)
User: buttons are **missing all content** (icon + label) across filled/elevated/outlined/text.
The base `m3e-button` sets (`Button[57994:2227]` etc.) are **matcher-fused with axes but no
example children** → emit renders an empty `<m3e-button>`. Toggle sets DO have `+ex`.
- **m3e-button** — add example children (icon + label, e.g. star + "Label") to the base fused
  sets so filled/elevated/outlined/text render content. **CONTENT.** Verify it doesn't break
  the axis interpolation (`variant`/`size`/`shape`).  ⚠ conflict-check: base fused sets feed
  many variants — one example must read well across all.
- **m3e-button (toggle-elevated)** `Toggle button - elevated[58653:13968]` — **INVESTIGATE**:
  rounding + color don't line up. `VARIANT`/possible `MAPPING-BUG`. See CONFLICTS.
- **m3e-button-group** `Connected[57998:47111]` / `Standard[58424:8117]` — content doesn't align;
  **first button should be selected** (Figma) but isn't (code); Figma shows **icon-only**, code
  shows **label-only** → need star icon to match. **CONTENT + STATE.** Update `examples.json`
  `m3e-button-group` children: icon buttons, first `selected`.

### Batch B2 — Chips (missing label content)
All chips render without the interior label.
- **m3e-assist-chip** `Assistive chip[53923:28089]` — missing label. **CONTENT** (add label text).
- **m3e-filter-chip** `Filter chip[53923:28270]` — missing label. **CONTENT.**
- **m3e-suggestion-chip** `Suggestion chip[53923:28679]` — missing label. **CONTENT.**
- **m3e-chip-set** `Chip groups[57376:5501]` — content different from Figma. **CONTENT** (match
  chip contents to Figma).
- Note: these are matcher `set` entries with axes/props but no example children → the emitter
  renders empty. Likely a **shared fix**: add representative label content. Check whether a
  `props` text-binding should carry it vs an example child.

### Batch B3 — Icon buttons (missing icon; one wrong icon; one color)
- **m3e-icon-button** (all base + togglable sets) — **missing the icon** in code. **CONTENT**
  (add `<m3e-icon>` child). Same root cause as buttons/chips (fused, no example children).
- **m3e-icon-button (toggle-filled)** `Icon button togglable[57994:10368]` — uses a **heart**;
  Figma uses a **star**. **CONTENT** (swap to star to match).
- **m3e-icon-button (toggle-tonal)** `…tonal[58668:48104]` — slightly different **color** in code.
  **INVESTIGATE** (`VARIANT`/token). Low priority.

### Batch B4 — Avatar / badge / icon-bearing (missing inner content)
- **m3e-avatar** `Generic avatar[50731:13725]` fa=Style:Monogram — **missing the icon/monogram**.
  **CONTENT** (add the `"A"`/icon inner content; Figma monogram).
- **m3e-badge** `Badges[51592:4768]` — **missing the number**. **CONTENT** (add badge value/label).

### Batch B5 — Card (avatar + slots + trailing image)
- **m3e-card (horizontal)** `Horizontal card[52350:27876]` — missing avatar, **not using slots**;
  Figma uses an **image in the trailing slot** (not an action). **CONTENT + slots**; use the
  shared placeholder image (Phase C).
- **m3e-card (vertical)** `Stacked card[52346:27573]` — content "totally different." **CONTENT**
  (rebuild example to match Figma stacked card).

### Batch B6 — State wiring (selected/checked not reflected)
Figma shows the selected/checked state; code shows unselected. Wire the state so it reflects.
- **m3e-checkbox** `Checkboxes[51859:5628]` — selected in Figma, unselected in code. **STATE**
  (checked). Has `axes=2` — verify a `checked` axis/example pins it.
- **m3e-switch** `Switch[54446:25289]` — same (selected in Figma). **STATE.**
- **m3e-radio** `Radio buttons[51739:4608]` — not selected in code, selected in Figma. **STATE**
  (+ minor whitespace, otherwise fine).
- **m3e-segmented-button** `Segmented button[53923:36615]` — Figma = **2 buttons, first selected**;
  code = 3 buttons, none selected. **CONTENT + STATE** (update `examples.json` to 2 segments,
  first selected).
- **m3e-tabs** `Tabs[54563:40023]` — content doesn't line up (align content; first tab selected).
  **CONTENT (+STATE).**

### Batch B7 — Progress indicators (variant states)
- **m3e-circular-progress-indicator** — user wants **empty** first (determinate value=0) and
  **partially filled** second. Currently `set-attrs`: determinate=70, indeterminate=true. Figma
  has an empty one + a partial one. **VARIANT/CONTENT**: adjust `set-attrs.json` so det=0 (empty)
  and the second shows a partial fill; confirm the indeterminate set is what Figma's "partial"
  maps to (else `MAPPING-BUG`). Investigate the second circle "doesn't look quite right."
- **m3e-linear-progress-indicator** — see A4 (width) + confirm determinate value shows.

### Batch B8 — Menu / list / list-item content
- **m3e-menu** `Menu[58966:3975]` — content different. **CONTENT** (match Figma menu items).
- **m3e-menu-item** `Menu item/Standard[58966:4100]` — no trailing chevron; width wrong (A4).
  **CONTENT** (add trailing chevron icon).
- **m3e-list** `List[59106:13028]` — content substantially less than Figma. **CONTENT.**
- **m3e-list-item** `List item[59106:13183]` — blank (A2/A5) + content. **CONTENT** (leading +
  headline + supporting + trailing to match Figma).

### Batch B9 — Dialog / drawer / dividers
- **m3e-dialog (Basic)** `Basic dialog[50723:10929]` — content doesn't match Figma. **CONTENT**
  (align `examples.json` m3e-dialog to Figma basic dialog).
- **m3e-dialog (list)** `List dialog[52112:28937]` — **good**, just **missing dividers** between
  list items. **CONTENT** (add dividers if the component/list supports them).
- **m3e-dialog (scrollable-list)** `[52112:29186]` — same family; verify after list fix.
- **m3e-drawer-container** — content match (after A2 activation).

### Batch B10 — FAB family
- **m3e-fab** `FAB[57998:43426]` / `Extended FAB[57998:43095]` — missing **icon**; second (extended)
  example is **larger** for unclear reason. **CONTENT** (add icon) + **INVESTIGATE** size (see
  CONFLICTS — fab sizing may not map 1:1).
- **m3e-fab-menu** `FAB menu[57998:42986]` — decent; user wants an **adjacent FAB** co-associated.
  **CONTENT/composition** — but see CONFLICTS (co-association may not reflect real usage).
- **m3e-fab-menu-item** `.Building Blocks/FAB Menu/Primary/Segment[57998:42953]` — **no background**,
  **different icon**. **INVESTIGATE + CONTENT** (why no surface? wrong icon).

### Batch B11 — Form field variant
- **m3e-form-field** `Text field[52798:24373]` fa=variant:outlined — Figma = **underline (filled)**
  pattern; code = **full outline**. **VARIANT / CONFLICT** — see CONFLICTS.

### Batch B12 — Search
- **m3e-search-bar** `Search bar[52977:33813]` — solid; missing **hinted search text**
  (placeholder). **CONTENT** (add placeholder to match Figma "Hinted search text").
- **m3e-search-view (docked)** — A2 (render) + **CONTENT** match.
- **m3e-search-view (fullscreen)** `[59178:4963]` — right component, content close; align content;
  uses the **placeholder image** (Phase C).

### Batch B13 — Split button, tabs, tab items
- **m3e-split-button** `Split button[57994:15751]` — missing **icon** (Figma has one). **CONTENT.**
- **m3e-tab (icon-only)** `Primary tabs/Icon only[54563:40209]` — different icon (use star to
  match). **CONTENT.**
- **m3e-tab (primary label-only / icon-and-label)** — code says "Favorites", Figma says "Tab";
  align. **CONTENT.** (secondary-icon-label + secondary-label-only already fine.)

### Batch B14 — Toolbar (variant settings)
- **m3e-toolbar** `Toolbar[58467:8206]` — Figma is **rounded + elevated**; code is neither. These
  are **Figma settings** → map to code attrs if they exist. **VARIANT / INVESTIGATE** (see
  CONFLICTS — confirm toolbar exposes shape/elevation attrs).

### Rows the user judged FINE (no action beyond content-alignment noted above)
- **m3e-datepicker (modal)** — "mostly correct, fine."
- **m3e-snackbar** — "looks great."
- **m3e-slider** — differences fine, same component.
- **m3e-tab (secondary-icon-label / secondary-label-only)** — fine.
- **m3e-timepicker (dial/keyboard)** — good (whitespace only → A1).
- **m3e-timepicker-input-period-toggle (v/h)** — good (whitespace only → A1).

---

## Phase C — Shared placeholder image asset
User: Figma reuses one placeholder image (avatars/cards/search-view/list-leading). **Action:**
extract that image via the Figma plugin (`download_assets`/`get_design_context`) once, store it
under `profiles/m3-kit/assets/` (or `research/`), and reference it (as a data-URI or path) from
every image slot needed: **m3e-card (trailing image), m3e-search-view (fullscreen), avatar/list
leading** where Figma uses an image. Do this before B5/B12 so those batches can consume it.

---

## CONFLICTS / INVESTIGATE — raise to user, case-by-case, before shipping the fix
Each below could be a genuine binding change or a gate-vs-real-usage tradeoff. Resolve the
stated question with the Figma plugin + CEM `.d.ts`, then confirm with the user if it would
alter the shipped binding's real-world correctness.

1. **m3e-datepicker (docked)** `Input date picker[51954:18540]` fa=variant:docked — Figma appears
   to use an **HTML date-input**; code renders a **calendar**. Q: is "docked" the wrong variant,
   or is the Figma "Input date picker" a different pattern (text-field date input) than
   `m3e-datepicker`? Possible `MAPPING-BUG`. Don't "fix" to a calendar if the real binding should
   be a date input field.
2. **m3e-form-field (outlined vs underline)** — Q: does Figma "Text field" default to the
   **filled/underline** variant? If so the shipped `fa=variant:outlined` may be wrong for the
   default representative — but outlined is a legit real variant. Confirm which variant the
   binding should represent (changing it alters the shipped example).
3. **m3e-toolbar rounded+elevated** — Q: does `m3e-toolbar` expose `shape`/rounding + `elevation`/
   `variant` attrs that produce Figma's look? If yes → map (VARIANT). If elevation isn't an
   attribute (m3e uses tonal-surface tokens, not an `elevation` attr — per repo guidance), the
   code may be correct and Figma is just showing a floating variant. Don't fabricate an attr.
4. **nav-bar / nav-item / nav-menu "totally different components"** — likely `MAPPING-BUG`s:
   - **m3e-nav-bar** `Navigation Bar: Horizontal items[58016:37236]`
   - **m3e-nav-item** `Building Blocks / Nav item[51593:5254]`
   - **m3e-nav-menu** `Navigation Rail: Expanded[58016:36670]`
   Q per each: is the bound Figma set the right counterpart, or are we comparing against the wrong
   Figma element? User unsure. Investigate the Figma set contents vs the CEM component; the code
   may be correct and the Figma node wrong (or vice-versa). Reconcile before changing anything.
5. **m3e-button (toggle-elevated)** — rounding + color mismatch. Q: is the toggle-elevated
   `fixedAttrs` (`variant:elevated`, `selected:true`) producing the wrong shape/color, or is it a
   render artifact? Investigate before altering fixedAttrs.
6. **m3e-fab second-example (Extended) sizing** — user explicitly flags fab sizing as a known
   "doesn't line up" case. Q: is Extended-FAB size a Figma setting with no code attr, or a real
   difference? May be acceptable-as-is.
7. **m3e-fab-menu adjacent FAB** — co-associating a FAB with the fab-menu in the example may not
   reflect how the component is actually used. Q: should the shipped example include an adjacent
   FAB, or is that gate-only dressing? Raise before adding.
8. **m3e-loading-indicator** — may be a genuine `LIMITATION` (animated; offline render is a frozen
   frame / bare square). Q: is there a static representative state, or do we accept it's
   un-gate-able (mark example-verified, note it)?

---

## Suggested execution (orchestrated)
1. **Phase A first** (one focused effort on `render-all.mjs`): A1 trim + A2 activation + A3 hover
   + A4 widths, then re-render everything. Many "issues" are pure render and vanish here.
2. **Resolve CONFLICTS** (investigation batch) → user check on the flagged items.
3. **Phase C** (placeholder image).
4. **Phase B in parallel batches** (B1–B14), each TDD: update example/attrs → `pnpm emit` →
   `pnpm check` → `pnpm test` → re-render its components → eyeball. Keep byte-stability + the
   709/710-test baseline green per batch; commit per batch.
5. Re-run the full "everything" gate for a second review pass.

**Verification gate for every shipped change:** `pnpm emit --profile m3-kit` clean, `pnpm check`
= 0 drift/0 orphan/byte-stable, `pnpm test` green, re-match byte-stable. Render-harness-only
changes skip emit/check but must re-render cleanly.
