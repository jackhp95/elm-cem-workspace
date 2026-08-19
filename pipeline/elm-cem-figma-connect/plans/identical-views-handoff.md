# Handoff: make Code Connect bindings render IDENTICAL views to their Figma nodes

## The mandate (the thing that was being gotten wrong)
Figma Code Connect binds a code snippet to a Figma node so the two render the
**same view**. The visual gate's pixel-diff is a **trustworthy signal**: it
union-box-aligns + trims and deliberately does NOT scale, so a **low match means
the binding renders a different view — i.e. it's wrong.** Do NOT explain a low
score away as "the metric is unfair" or "Figma is a showcase, my code is a
minimal example." That defense is the bug: if the Figma node shows a full drawer,
the code must render a full drawer.

Worked example (already done, use as the template): `m3e-nav-menu` went from
**7% → 61%** match. Its bound node (Navigation Drawer, `51593:5827`) is a real
2-section menu — Mail (Inbox 24, Outbox/Favorites/Trash 100+) + Labels (Label
100+ ×3), with icons, badges, `m3e-heading` section labels. The old example was
3 generic "star + Label" items. Fixing it = rendering the node's ACTUAL content.
See `git show 2d1b539`.

## Method, per binding
1. Find the bound Figma node id in `profiles/m3-kit/correspondence.json`.
2. **Capture the node's real content** over the bridge:
   `wsQuery("capture_set", { nodeId, scale:1, offset:0, limit:1 }, { channel })`
   — walk `variants[0].contentTree` for section headers, item labels, badges,
   icons, counts, structure. (Nested icons are unnamed placeholders; use the
   kit's `stars_filled` or a semantic glyph that fits the label.)
3. **Get the verified m3e API from the `m3e` skill** (now installed): read
   `~/.claude/skills/m3e/components/<name>.md` for the exact tags/attrs/slots
   (e.g. nav-menu-item-group + `slot="badge"` + `slot="label"`). Do NOT guess.
4. Rebuild the example — `profiles/m3-kit/examples.json` (matcher tags) or the
   per-set inline `example` / `manual-correspondence.json` (manual/appendSets).
5. `pnpm emit --profile m3-kit` → `pnpm check` → re-render just this one:
   `node <scratch>/render-all.mjs --only=<tag>` → read the new diffRatio from
   `render-cache/coverage-review-all/items.json`. Compare before/after.
6. Commit per binding (or small batches). NO push/PR unless the user asks.

## Worklist (worst match first — from the narrowed rejected gate)
- **`m3e-shape` (0%) — BROKEN, not just wrong content.** It renders at full
  viewport (2000×1600) = no visible shape cropped. Investigate first: the shape
  likely needs a size/`name` or renders via a mechanism the harness misses.
- `m3e-list` (3%), `m3e-date-input` (4%), `m3e-list-item` (6%),
  `m3e-input-chip` (9%), `m3e-nav-rail-expanded` (10%), `m3e-chip-set` (11%),
  `m3e-form-field` (13%), `m3e-button-outlined`/`-text` (12–20%),
  `m3e-icon-button-outlined` (18%), `m3e-fab-menu`/`-item`, `m3e-drawer-container`,
  `m3e-bottom-sheet`, `m3e-dialog`, `m3e-card`, `m3e-menu(-item)`, `m3e-tab`,
  `m3e-button(-group)`, `m3e-icon-button`, `m3e-expandable-list-item`,
  `m3e-search-view`.
- Full current per-binding match numbers are in
  `render-cache/coverage-review-all/items.json` (narrowed to the 26 rejected).

## Honesty rule
Some low scores ARE genuinely just size/showcase framing with correct content —
prove it by aligning what you can, and if a residual gap is icon-glyph/spacing
only, say so explicitly. But default to "the diff is right, the binding is
wrong" until proven otherwise.

## Tooling / state
- Bridge: `bun extract/relay/socket.ts` on `:3055`; channel is per-session
  (check the plugin's "connecting channel" line — currently `cem-504138`).
  Update the `CHANNEL` const in the scratch `render-all.mjs`.
- Renderer: `<scratch>/render-all.mjs` (code vs cached Figma; `--only=tag1,tag2`).
- Gate UI: `<scratch>/review-launch.mjs` → http://127.0.0.1:4747 (narrowed to
  rejected via `items.json`; full set backed up in `items.all.json`).
- Diff: `src/visual/diff.mjs` — trustworthy; don't loosen it.
- Extraction methodology: `docs/figma-extraction.md`.
- Gate decisions (this session): `<scratch>/overrides-review-scratch.json`
  (25 approved / 26 rejected). retarget notes now persist (fixed in `f62f0aa`).
- After every change: emit 224/224, `pnpm check` byte-stable, `pnpm test` green (711).

## Optional orchestration
Independent in content, but all edits touch the 3 shared profile files + one
bridge + a serial emit/render. So: parallel READ-ONLY sub-agents may produce
per-binding proposed-example specs (capture + m3e API → JSON), but ONE driver
applies serially + verifies. Don't parallelize the writes.

---

## Session update 2026-07-31 (background-parity + first content fixes)

### Biggest finding — a systemic review-renderer bug (background parity)
The scratch renderer composited the CODE side onto WHITE while the Figma export keeps each
node's OWN backdrop — so every transparent-backdrop node (shapes, lists, chips, buttons) was
scored against a white bg it never had (`diff.mjs` lines 63-66 assume BOTH sides are
transparent-bg). Fix: match the code bg to the Figma node's backdrop per-component — sample the
export's top-left corner; transparent → keep alpha, opaque → composite onto that color. This is
a fairness/fidelity fix, NOT a threshold change (verified both ways: tabs have a real `#fef7ff`
surface → composite holds ~80%; shape/list transparent → keep alpha → ~100%). Effect: 61/83
improved (list 3→96, chips/buttons →100, icon-buttons 18→90/100, expandable 17→82, …).

### render-all.mjs (scratch) — the LIVE gate renderer, changes this session
Path (running bridge+gate procs reference it; channel still `cem-504138`):
`/private/tmp/claude-501/-Users-jhp-code-jackhp95/f5d44bc6-9714-4c53-b035-b101df8c7d13/scratchpad/render-all.mjs`
- `figmaBgColor(figmaPath)` + `trimToContent(buf,pad,bg)` bg param (null=keep alpha, [r,g,b]=composite onto backdrop); call site samples fbg per file. ← the parity fix.
- SELECTED now applies keys starting `--` via `style.setProperty`.
- `SELECTED["m3e-shape"] = { name:"circle", "--m3e-shape-size":"380px" }` (variant default + representative size; shape is scaleInvariant).
- `SELECTED["m3e-form-field"] = { "hide-subscript":"never" }` (show supporting text in the gate).
- `REVEAL["m3e-nav-menu"] = { style:{ width:"360px", background:"#f7f2fa", borderRadius:"16px" } }` (representative drawer surface; the component paints none).
NOTE: these are gate-render representative state, NOT binding changes. They are only in scratch —
persist/port to the real gate (`src/visual/capture.mjs`) as part of the visual-gate work.

### Committed content fixes (repo)
- **shape** — NO repo change; binding was correct, 0% was the stripped-variant-default + white-corner artifacts (now 100%). Gate status "rejected" is STALE.
- **nav-menu** (b88326b): real 3-section drawer, folder icons, Inbox-only badge/selected, no fabricated "100+". 1% → 97%.
- **menu + list** (19a0093): outline icons (were `filled`), node's real 6-item count. Content correct; residual = harness state (menu focus-ring) + AA.
- **form-field** (9d10bfd): filled variant (slug renamed outlined→filled), floating label + supporting text + cancel-in-circle icon. 39% → 81%.

### Remaining residual worklist (worst-first; the user's gate comments are the spec)
GENUINE CONTENT (tractable, do next):
- `m3e-fab-menu-item` 23% — missing primary color + background (icon/label fine). [manual]
- `m3e-card` 38/48% — slots and content wrong. [contains]
- `m3e-badge` 40% — example HAS "3" but it isn't rendering; investigate slot/attr (badge.md). [set]
- `m3e-fab-menu` 56% — missing the FAB button in the code. [set]
- `m3e-nav-rail` 57/78% — "completely wrong"; rebuild. [manual]
- `m3e-rich-tooltip` 76% — 2 actions correct but must be in a ROW, left-aligned. [standalone]
- minor: `m3e-list-item` 94% (hotkey/chevron slot + supporting-text truncation).

DEEP / AMBIGUOUS (need care or a user decision):
- `m3e-date-input` 2/16% — Figma node is a full text-entry date-picker MODAL; m3e has NO single
  element for it → needs a dialog+form-field+date-input+buttons composition, and modal vs docked
  need per-set examples. Architectural Q: should a date-input binding be a whole modal?
- `m3e-drawer-container` 16% — user wants a capable subagent + deep Figma/M3E/OKF dive; from scratch.
- `m3e-bottom-sheet` 46% — "isn't a bottom sheet at all"; rebuild.

HARNESS / GATE STATE (the "visual gate" session — NOT binding fixes):
- Residuals on now-high items are focus rings / hover / force-open / representative widths:
  menu (first-item focus-ring vs Figma hover-fill), icon-buttons ("border-radius" — now 80-100%),
  tabs, dialog (width), expandable/menu-item (width), the 2 timepicker period toggles (a cosmetic
  bg-parity regression: transparent margin + light interior the corner-sample can't read),
  search-view (open-state render). Address these in the harness with the user.

### Housekeeping
- `items.json` was un-narrowed to the full 83 (was narrowed to rejected). Re-narrow if wanted.
- The `overrides-review-scratch.json` gate decisions are the authoritative per-set spec; when no
  comment exists for a set, reuse the family's prior comment (per the user).
- Emit reads the MERGED `profiles/m3-kit/correspondence.json` (there is NO merge npm script) —
  edit variants there (mirror in `manual-correspondence.json` for forward-compat).

---

## Session update 2026-07-31b (deep compositions + render-harness pins)

Worked the 20 still-rejected components using the user's gate comments as the spec. Committed
content fixes (repo) + render-harness representative-state pins (scratch render-all.mjs only).

### Committed content fixes (examples.json / manual-correspondence)
- rich-tooltip 76→93 (actions in a `<div slot="actions">` row); chip-set 84→86 (6 chips) — `2cf1f36`
- nav-rail "completely wrong"→74/81 (toggle + FAB + items; expanded mode render-injected) — `9a57e91`
- drawer-container 16→83 (real side-sheet content: header Title+close, divider, Save/Cancel) — `2631e90`
- bottom-sheet 45→91 (emptied to the node template; harness opens it tall w/ handle) — `94f1581`
- menu+list outline icons + counts — `19a0093`; form-field filled+label+supporting+cancel — `9d10bfd`/`68dfcf3`; nav-menu — `b88326b`

### render-all.mjs (scratch) representative-state pins added this session (NOT repo)
- `figmaBgColor()` + `trimToContent(bg)` — the background-parity fix (session 1).
- SELECTED: `m3e-badge:{size:large}` (node is Large; small=dot, no number → 40→94);
  `m3e-form-field:{hide-subscript:never}`; `m3e-fab-menu-item:{--_fab-menu-item-container-color:#eaddff}`
  (23→91, the pill color the parent menu normally provides); `m3e-nav-rail-expanded:{mode:expanded}`;
  `m3e-bottom-sheet:{--m3e-bottom-sheet-max-width:434px}`; `m3e-dialog:{--m3e-dialog-max-width:312px}` (44-63→73-89);
  `m3e-shape` (session 1). REMOVED the invalid `m3e-icon-button:{shape:circular}` pin → default rounded IS
  circular → 6 icon-buttons 71-80→90-100.
- WIDTHS: `m3e-expandable-list-item:280` (82→85). REVEAL: `m3e-bottom-sheet` open+handle+detents=502px;
  `m3e-drawer-container` sized 400x700.

### GENUINELY STUCK (architectural — need a per-binding-format change, not a quick fix)
- `m3e-card` (38/47%): horizontal (avatar+text|media) and vertical (header+media+title+supporting+actions)
  are STRUCTURALLY different nodes; one shared `examples.json` entry can't match both (any change that
  helps one hurts the other — measured horiz 79 / vert 21). Needs PER-SET examples for a [contains] binding
  (the matcher mechanism that gives button-group its per-set example isn't sourced from any editable file).
- `m3e-date-input` (2%): the node is a full text-entry date-picker MODAL (dialog + header + field + Cancel/OK);
  `m3e-date-input` is only the segmented field, and the example format nests children INSIDE the cemTag root —
  can't wrap the field in a dialog. Binding↔node mismatch (field vs modal).
- `m3e-fab-menu` (55%): node is the open menu + a sibling FAB (with close icon) below it; the FAB is OUTSIDE
  the `m3e-fab-menu` root, and the example format can't add a sibling to the root.
- `m3e-nav-item` (95%): node is the EXPANDED (horizontal icon+label+badge) item; a standalone `m3e-nav-item`
  is compact (vertical) — horizontal layout comes from the parent rail's expanded mode, which can't be set
  standalone.

### Representative / minor
- `m3e-search-view` (3%): renders fine (search bar + results); its own note says it's a representative binding
  approved by eyeball — the example uses image-results where the node shows avatar+label+supporting, so the
  pixel gap is by design. Rebuild the fullscreen per-set example if a pixel-match is wanted.
- `m3e-menu-item` (52%): residual is row HEIGHT/density (code ~27px vs node ~48px), not width; needs a
  height/density knob, not a width change (width tweak regressed it — reverted).
