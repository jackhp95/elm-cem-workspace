# m3e-icon Code Connect emission (141 per-icon bindings) — Design + Plan

**Status:** approved-to-proceed (Jack 2026-07-19: "one binding per icon"). Corrects the false "icon unbankable" claim — icon is a fully-mapped `iconTable` of 141 real Figma icon nodes; the emitter just never emitted it as its own binding.

**Goal:** Bank `m3e-icon` by emitting one Code Connect binding per icon node (141), each mapping the Figma icon node → `<m3e-icon name="<symbol>">` (+ `filled` when the row is a filled variant). Grows banked **30 → 31** (one cemTag, 141 files).

---

## Findings
- `m3e-icon`'s correspondence is `kind:"iconTable"` with `icons: [{figmaNodeId, figmaName, symbolName, filled}]` × 141 (`status:"proposed"`, `provenance:"auto-exact"`). Rationale: "icon page: 141 standalone components → one m3e-icon entry with a per-icon name value table".
- The emitter threads `iconTable` only as a LOOKUP for other components' icon slots (chip leading-icons, etc.). `emitEntry` (both html-label + elm) SKIPS `kind:"iconTable"` entries (`→ []`). So confirming m3e-icon currently emits nothing.
- Each icon node renders faithfully in code as `<m3e-icon name="X">` (already verified: the settings gear). So the 141 bindings are faithful by construction (names come from the real Figma symbol names).

## Design — an iconTable emit branch (html-label)
Add a branch in the html-label emitter: when an entry is `kind:"iconTable"` AND confirmed, emit **one file per icon row** instead of skipping:
- **binding:** `figma.connect(<node url for icon.figmaNodeId>, { example: () => html\`<m3e-icon name="<icon.symbolName>"<filled? " filled":"">></m3e-icon>\` })` — matching the existing `.figma.ts` shape (`example: figma.code\`...\``, `imports:["import \"@m3e/web/all\""]`, `id`, `metadata`). Use the existing `buildNodeUrl(config, icon.figmaNodeId)`.
- **name value:** `icon.symbolName` (e.g. "wifi", "stars"). `filled:true` rows add the boolean `filled` attr → `<m3e-icon name="stars" filled>`.
- **filename / id:** `m3e-icon-<kebab(symbolName)>[-filled].figma.ts`. **Collision-safe:** the table has duplicate symbolNames (settings×2, mail×2, check_box×2, …) and filled/unfilled pairs. Dedupe by (symbolName, filled); if two ROWS still collide (same symbol+filled, different node), suffix `-2`, `-3`… deterministically by node-id order. NEVER silently overwrite (a lost file = a lost binding).
- **elm:** m3e-icon is not in elm-facts → the elm emitter already `return []`s for it (quiet skip, like progress). Web-components only. Confirm elm emits 0 icon files.

## Verification + banking
1. Build the branch (TDD, synthetic + real iconTable fixtures). Prove the 30 existing banks stay BYTE-IDENTICAL (they're not iconTable).
2. Confirm m3e-icon in overrides (`gate:"example-verified"`, note: 141 per-icon bindings, name from Figma symbol). `confirm → gap → emit`.
3. **AF-07 (representative, not all 141):** render a handful of the emitted examples (e.g. settings, wifi, favorite, a `filled` one) → each a faithful glyph. The rest are faithful by construction (same template, real symbol names). `check` → 0 drift.
4. Tracers: the smoke test cannot list 141 filenames sanely — assert the icon file COUNT (+ manifest["m3e-icon"].length === 141) and spot-check a few representative filenames, rather than enumerating all. Confirmed count 30→31. Full `pnpm test` green.

## Scope / out
- **In:** the html-label iconTable emit branch + collision-safe filenames + bank m3e-icon.
- **Out:** elm icon bindings (not in elm-facts); the live-5; tab (separate). A single-file-with-141-connects format (the architecture is one-binding-per-file; 141 files matches it + Jack's pick). De-duping the icon library itself (emit every node the table lists — each is a real Figma node worth a binding; note duplicate symbols in the collision suffix).

## Tasks (TDD)
- **T1** — html-label iconTable branch: for a `kind:"iconTable"` confirmed entry, emit one binding per icon (name + filled), collision-safe filename. Unit tests (synthetic iconTable: 2 icons + a filled + a dup-symbol → 4 distinct files, right examples, dedup suffix). Byte-identical regression for non-iconTable entries.
- **T2** — bank m3e-icon: overrides + confirm/emit (expect 141 wc files, 0 elm) + AF-07 spot-render + tracers (count-based) + `check` 0-drift + full suite + commit.
