# Gate remediation — round 2 (2026-07-30 user feedback)

Ground truth: `scratchpad/ground-truth.json` (deep re-capture of all 83 sets,
keeps type/name/characters/mainComponent). Figma renders: `render-cache/coverage-review-all/figma/*.png`.
Slot model: `elm-m3e/docs/composition.md`, CEM `slots` per component, `m3e-okf/skills`.

## Root causes (not ~50 independent bugs)

- **R1 Icons** — kit icons are unnamed placeholder vectors (`INSTANCE:Icon → VECTOR:icon`,
  no resolvable component name). Glyph identity is NOT in the data. Fix source =
  (a) user's explicit target, else (b) visual read of the Figma PNG. FLAG unsure ones.
- **R2 Structure/slots/text/counts** — fully recoverable from ground-truth. Authoritative.
- **R3 Render-harness state** — components not opened/revealed/hovered in the gate
  (bottom-sheet, drawer, tooltip, rich-tooltip, search-view-docked, loading-indicator,
  date-input). HARNESS bug — must NOT corrupt bindings.
- **R4 Variant/state** — toggle color/rounding/outlined/tonal need fixedAttrs
  (`selected`, `shape`, variant) and/or render-side state.

## Per-component tasks

### R3 — harness/state (gate-only; verify render height/content, no binding change)
- [ ] bottom-sheet: not opened → just a container. Verify open logic + height.
- [ ] drawer-container: broken (not opened).
- [ ] tooltip (plain): invisible — hover state not captured.
- [ ] rich-tooltip: not shown — hover/open not captured.
- [ ] search-view-docked: broken (not opened).
- [ ] date-input docked / date-input modal: broken for code (render).
- [ ] loading-indicator: still a square — animated shape not captured in still.

### R2 — structure / slots / content / counts (ground-truth-driven)
- [ ] app-bar: trailing = **Avatar** (gt: `INSTANCE:Avatar`), not more_vert. leading icon + title "Label".
- [ ] assist-chip: remove the calendar leading icon (normal assist chip has none; brand variant = "Colourful logo").
- [ ] card-horizontal: correct slots — text jumbled. gt: Header(Avatar+Text) / Media / Headline(Title/Subtitle) / Supporting / Actions.
- [ ] card-vertical: proper slots; actions buttons in a **row** not column. Same slot set as horizontal.
- [ ] dialog-basic: actions = Secondary + Primary buttons in a **row** (Actions slot); text "Basic dialog title" + supporting.
- [ ] input-chip: add inner `label-text:"Label"` + avatar + closing icon (gt confirms).
- [ ] list-item: leading icon + content; trailing text **"⌘C"** + icon (the mystery "C").
- [ ] list: correct item count + contents; trailing "⌘C".
- [ ] menu / menu-item: correct icons + trailing chevron; Groups=3.
- [ ] chip-set: correct chip count (gt).
- [ ] expandable-list-item: correct contents.
- [ ] tabs: text should be video/photos/audio (per user); "has icons it shouldn't" → label-only.
- [ ] tab primary icon-only: correct icon.
- [ ] filter-chip: REMOVE leading + trailing icons (should match Figma exactly).
- [ ] suggestion-chip: REMOVE icon (shouldn't have one).
- [ ] segmented-button / snackbar / split-button contents: minor.
- [ ] fab-menu: add the FAB; correct icons/text/size.
- [ ] fab-menu-item: icon + label; may need tonal background.

### R4 — variant / fixedAttrs / state
- [ ] button-group connected: circled-star + label text; full rounding.
- [ ] button-group standard: correct button count + icons; full rounding (looks like chips now).
- [ ] button toggle elevated/filled: correct color (selected?), text, icon.
- [ ] button toggle outlined: must render outlined; correct text + icon.
- [ ] icon-button toggle filled: correct color + rounding.
- [ ] icon-button toggle outlined: must render outlined + rounded.
- [ ] icon-button toggle tonal: must render tonal + fully rounded.
- [ ] fab (plain): correct size + icon.
- [ ] form-field: investigate underline (filled) vs outlined; add input value text + trailing close icon.

### R1 — icon glyphs (visual read of Figma PNG; FLAG unsure)
- [ ] button filled/elevated/tonal: star-in-circle (user), not plus.
- [ ] icon-button (all standard): correct glyph.
- [ ] fab extended / fab plain: correct (close) glyph.
- [ ] split-button, toolbar, search-bar, menu, list-item leading, tab: correct glyphs.

## Good (no action)
avatar, badge, checkbox, circular-progress (both), datepicker-modal, dialog-list,
linear-progress, search-view-fullscreen, segmented-button, switch, timepicker dial,
timepicker period-toggle, tab (secondary).

## Constraint (user, verbatim)
If a gate improvement would regress real usage, STOP and raise it. Keep userland
seams separate from CEM generation. Content-match is priority #1.
