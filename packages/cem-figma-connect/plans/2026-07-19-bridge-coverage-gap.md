# Bridge the Coverage Gap — m3e ↔ Figma Code Connect

> **For agentic workers:** a PROGRAM plan (waves + methodology + a render-gated backlog), not a fixed TDD task list — per-component tasks emerge from the investigation phase (you can't pre-write steps for a render-gated bank). Waves 0–1 are concrete; 2–5 are process + backlog. Uses the mechanisms already built (manual-correspondence, examples.json, appendSets, set-attrs, render-batch force-open).

**Goal:** Maximize *faithful* Code Connect coverage of the m3e library — bank every remaining m3e component that (a) has a Figma node and (b) renders faithfully; honestly scope out the rest with evidence.

**The hard constraint (reframes everything):** Code Connect binds a Figma **node** to code (`figma.connect(node, …)`). A component with **no Figma node cannot be bound** — this is structural, not a "ceiling claim." So bridging is a two-gate filter per component: **(1) does a Figma node exist?** → **(2) does it render faithfully?** → then pick a mechanism.

**Current state:** 121 CEM tags → **43 banked · 4 matched-but-unbanked · 74 unbound.** The matcher is bimodal (36 auto-match ≥0.9; only `m3e-assist-chip` fuzzy @0.524; everything else gap @0.0). So bridging is inherently **manual** (manual-correspondence + representative-example + appendSets), *not* matcher-tuning.

---

## Strategic finding (read first)

**The gap is mostly structural.** Of the 74 unbound tags, **~40+ cannot be Code-Connected at all** — the M3 Figma kit simply doesn't draw them (select, autocomplete, tree, stepper, paginator, split-pane, toc, breadcrumb…), or they're **non-visual behavior wrappers** (every `-toggle`/`-trigger`/`-action`, `ripple`, `focus-trap`, `theme`, `textarea-autosize`) that render nothing standalone. The **genuinely bridgeable set is ~20–27**, and it skews **low dev-value**: sub-parts (already represented *inside* their banked parents' examples) and variant 2nd-sets. **The high-value standalone components are already banked.** So "bridge the gap" here means *coverage/completeness*, not unlocking new high-value bindings — plan the depth accordingly.

---

## Classification of the 74 (evidence-based; every verdict render-verified in-phase)

### Bucket A — Bankable now: whole component + real Figma node (manual-correspondence)
- **`m3e-divider`** ★ — Figma `Horizontal/{Full-width,Inset,Middle-inset,Divider with subhead}` + `Vertical/*` (4+ sets). Renders a line. **Clearest single win.**
- *Faithfulness-gated candidates* — `m3e-filter-chip-set` / `m3e-input-chip-set` (Figma `Chip groups` Filter/Input variants), `m3e-selection-list` / `m3e-action-list` (Figma `List` variants). Overlap with banked `m3e-chip-set`/`m3e-list` → may be better as 2nd-sets (Bucket C).

### Bucket B — Bankable: sub-part + Figma building-block (manual-correspondence + representative example; render-verify each)
`m3e-button-segment` (Segmented button/Button segment) · `m3e-slider-thumb` (Handle) · `m3e-menu-item-checkbox` / `-radio` (Menu list item) · `m3e-nav-menu-item` (Nav rail item) · `m3e-list-action` / `-option` / `-item-button` (List item building-blocks) · `m3e-expansion-header` (accordion header).
→ Lower standalone value (these already appear as example children inside banked parents), but each maps to a real Figma building-block a dev could select in Dev Mode.

### Bucket C — 2nd-sets of already-banked tags (appendSets — mechanism now complete)
secondary tabs ×2 · `nav-bar` vertical items · list dialogs → `m3e-dialog` · list-item density/swipe → `m3e-list-item` · menu baseline / menu-item vibrant → `m3e-menu`/`m3e-menu-item` · 2nd datepicker (Modal/Dial/Keyboard) & search (full-screen) modes · slider range/centered → `m3e-slider` · chip-set filter/input layouts → `m3e-chip-set` · accordion/expansion → `m3e-expandable-list-item`.
→ Each is a config edit + AF-07 + tracer update; the parking + sampler fixes from the appendSets bank already handle them.

### Bucket D — Render-blocked: matched or has-node but degenerate standalone (attempt force-open; bank if faithful, else honest skip w/ note)
- `m3e-bottom-sheet`, `m3e-snackbar`, `m3e-loading-indicator`, `m3e-fab-menu` — the 4 **matched-but-unbanked** (auto-exact, conf=1). Blocked on render, not matching. Try `open`/`.show()` force-open + representative example; loading-indicator likely "render frozen" (motion-disabled). **`fab-menu` is a known wall** (`.show()` no-op, code-side blank — memory).
- `m3e-calendar` — force-open like datepicker (`.show(document.body)` reveals the grid).
- `m3e-slide` / carousel — renders blank standalone (needs a host — known wall).

### Bucket E — Marginal internal primitives WITH a Figma building-block (LOW dev value — Jack's call)
`m3e-focus-ring` (Figma `Focus indicator`) · `m3e-state-layer` (Figma `state-layer/1–5`). Bindable + render (a ring / an overlay) but near-zero dev value.

### Bucket F — Structurally unbindable (NO Figma node OR non-visual; Code Connect cannot — verified per tag)
- **No Figma node** (kit doesn't draw them): `select, autocomplete, breadcrumb(-item/-item-button), paginator, split-pane, stepper/step/step-panel, tree(-item), toc(-item), collapsible, option(-panel)/optgroup, floating-panel, chip(base)`.
- **Non-visual behavior wrappers** (render nothing standalone): every `-toggle` / `-trigger` / `-action` (`drawer/datepicker/menu/dialog/bottom-sheet/fab-menu/rich-tooltip/stepper`), `focus-trap`, `textarea-autosize`, `ripple`, `theme`.
- **Internal / no node**: `elevation, skeleton, heading, content-pane, scroll-container, text-highlight, text-overflow, theme-icon, pseudo-checkbox/-radio, radio-group, *-group panels, tab-panel, slide-group`, datepicker internals (`month/year/multi-year-view` — covered by calendar/datepicker).
- **Covered implicitly:** the sub-parts here appear as example children inside their banked parents (e.g. `button-segment` inside the banked `m3e-segmented-button`) — they are represented, just not standalone.

---

## Methodology (per-component decision procedure)
1. **Figma node?** Search `research/figma-dumps/figma-export.m3-kit.json` by name + structure (semantic, not token — the matcher already proved token-matching fails here). None → **Bucket F**, done.
2. **Render faithful?** Build representative markup from the CEM's slots/attrs → `scripts/render-batch.mjs` → **AF-07 eyeball the PNG**. Blank → force-open (`js` hook) → still blank → **Bucket D** skip w/ honest note.
3. **Mechanism:** whole + matcher-unreachable → `manual-correspondence.json`; sub-part/composite → + inline `example`; 2nd-set of a bound tag → `appendSets`; hidden/overlay → force-open for verification only (emit omits the runtime open attr, like dialog).
4. **Bank:** `match` (byte-stable) → `emit` → AF-07 → **tracer-test surgery** → `check` 0-drift → commit.

## Mechanisms (all built — reuse, don't reinvent)
`manual-correspondence.json` (matcher-unreachable) · `examples.json` / inline `figmaSet.example` (representative content) · **`appendSets`** (2nd-sets of confirmed tags — completed this session) · `set-attrs.json` (per-set static attrs) · `scripts/render-batch.mjs` force-open (`js` hook, `.show()`).

## Waves (sequenced by ROI)
- **Wave 0 — de-risk (recommended first).** Frozen-fixture refactor: the canonical test fixtures (`buttonEntry` etc.) are loaded from the **live** `correspondence.json` in ~8 test files, so *every* bank ripples into all of them (the documented "trap" — friction `20260719T192029Z-cemfc-button-fixture-hardcoded-trap`). Load them from a checked-in snapshot instead + derive counts from the entry. One focused pass; pays back across every later wave.
- **Wave 1 — high-ROI whole (Bucket A):** `m3e-divider`; verify chip-set/list variants (fold into C if they're really 2nd-sets).
- **Wave 2 — 2nd-sets (Bucket C):** the appendSets goldmine remainder. Mechanism complete; highest coverage-per-effort.
- **Wave 3 — sub-parts (Bucket B):** render-verified representative examples.
- **Wave 4 — render-blocked (Bucket D):** force-open attempts; bank the faithful, honest-skip the walls (fab-menu, carousel).
- **Wave 5 — marginal primitives (Bucket E):** only if completeness is wanted.
- **OUT — Bucket F:** structural; document, don't chase.

## Execution model
**Controller-driven hybrid** (subagents truncate on the tracer step). Per wave: parallel **Explore** investigators classify/propose `{figma-node, render-markup, mechanism, verdict}` for their batch (read-only, semantic matching); the **controller** render-batches + **AF-07 eyeballs every PNG** + does the tracer-test surgery + commits. Byte-stable + `check` + full suite green each wave. Every subagent prompt carries the friction-logging instruction + the graphify-repo note. Read-only investigators need no worktree; if any wave mutates in parallel, isolate.

## Verification gates (per bank AND per wave)
1. **AF-07** — eyeball the EMITTED example PNG (never trust size). 2. **byte-stable** re-match (`match` twice diff-clean + the A8 tracer). 3. **`check`** 0-drift / 0-orphan. 4. **full `pnpm test`** green (modulo the AF-03 `publish-check` flake — passes 43/43 isolated).

## Honest yield estimate
`divider (1)` + `Bucket B (~8)` + `Bucket C 2nd-sets (~13)` + `Bucket D-faithful (~2–3)` + `Bucket E (~2)` ≈ **20–27 new bindings**; **~40+ structurally out**. Coverage would go from 43 components → ~48–52 components bound (many of the +20–27 are *sets on existing* components, not new components). **This is completeness, not new high-value coverage** — weight the depth decision against that.

## Publish (unchanged, human-gated)
The entire banked set (43 + anything added here) is blocked on an **org/enterprise Figma PAT** (personal = 403 Write). Bridging the gap does **not** unblock publish — that's a separate, human-only step.
