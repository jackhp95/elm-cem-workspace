# SP1 — Comprehensive Figma Capture — Design Spec (2026-07-15)

**Status:** design agreed (brainstormed 2026-07-15). Pre-implementation. This is
**sub-project 1 (SP1)** of a two-part effort; **SP2 — Content Reproduction** is a
separate later spec that *consumes* SP1's output and is out of scope here.

## 1. Motivation

The visual gate compares a code render (Playwright + @m3e/web) against a Figma
render of the matched variant. Today the Figma render is produced **live, per
variant, per gate run** via the plugin bridge's `export_node_as_image`, which
exports the component **definition** node. Three problems follow:

1. **Fill-container collapse.** A component whose width is meant to stretch to a
   parent frame (e.g. Snackbar) has no intrinsic width rendered standalone, so
   `exportAsync` collapses it to a **1×1** PNG — nothing real to diff against.
   (Partly mitigated by the 2026-07-14 read-only instance-fallback in
   `export_node_as_image`, but that only helps when a placed instance already
   exists.)
2. **No bounds.** The dump (`research/figma-dumps/figma-export.m3-kit.json`)
   carries variant *definitions* (axes/options/defaults) but **no node bounds**,
   so the harness can't size the code element to match Figma — I hand-tuned
   widths/sizes per component (shape 320px, search-bar 360px, fab small, …).
3. **Live bridge dependency.** Every gate run needs the plugin running in Figma.
   No offline gating, no CI gating.

**SP1 goal:** a **one-time comprehensive capture** — for every variant of every
Figma set, capture a real-bounds **render**, its **bounds**, and its baked
**content tree** — committed as a durable "dump v2". The gate then reads it
**offline** (no live bridge per gate), and fill-container + sizing are handled by
construction.

## 2. Decisions (brainstorm, 2026-07-15)

| # | Decision | Rationale |
|---|---|---|
| D1 | **Hybrid render**: placed instance first (read-only), temp-frame fallback (write) for un-placed variants | Coverage-complete without re-rendering variants that already have good instances; minimal, authorized, self-cleaning writes |
| D2 | **Scope: all 171 sets × every variant node** | Correspondence-independent, future-proof; capture once, gate any state forever |
| D3 | **Commit everything** (metadata + render PNGs) | Strongest offline guarantee (clone → gate). **Revisit after the real capture** — if the image set is too large, switch renders to gitignored/LFS/artifact (§10) |
| D4 | **Record baked content as data now; reproduce it in SP2** | SP1 ships the offline+bounds win fast; SP2 (declarative slot-mapping) consumes the recorded `contentTree` to gate the shells |
| D5 | **Per-set, runner-driven orchestration** | Balance: ~171 bridge round-trips (not thousands, not one), bounded per-call response, resumable per-set, temp-frame lifecycle contained per call |

## 3. Architecture (three units)

```
extract/plugin/code.js   capture_set(setNodeId, scale)  — Figma side (hybrid render + bounds + content)
        │  (WS bridge, per set)
extract/capture.mjs      runner — loops the 171 sets, writes PNGs + sidecar, resumable
        │
profiles/m3-kit/
  figma-captures.json    sidecar metadata (committed)      — "dump v2"
  captures/<setId>/<variantId>.png   render images (committed; §10 revisit)
        │
src/visual/{gate,drive}.mjs   gate reads captured render + bounds OFFLINE; live export = fallback
```

Each unit has one job and a narrow interface:
- **Plugin `capture_set`**: given a set node, return every variant's render+bounds+content. Knows nothing about storage or the gate.
- **Runner `capture.mjs`**: orchestrate the loop + persist. Knows nothing about `figma.*`.
- **Gate**: resolve a driven state to a captured render. Knows nothing about how the capture was produced.

## 4. Plugin — `capture_set(setNodeId, scale)`

New command in `extract/plugin/code.js` (ES2019, no `??`/`?.` — enforced by the
existing verify gate; §8).

**Signature (result):**
```jsonc
{
  "setNodeId": "53977:33575",
  "setName": "Snackbar",
  "variants": [
    {
      "variantNodeId": "53977:33611",
      "props": { "Configuration": "Text only", "# of lines": "One line", "Show close affordance": "False" },
      "boundsPx": { "w": 688, "h": 96 },      // rendered box at `scale`, from the exported PNG (IHDR) — the source of truth
      "renderVia": "instance" | "temp-frame" | "definition",
      "exportedNodeId": "58211:9042",          // the instance actually rendered (when fallback fired)
      "contentTree": { … },                     // §4.3
      "imageData": "<base64 PNG>",
      "degenerate": false                        // true iff still ≤4px after fallback (rare)
    }
  ]
}
```

### 4.1 Variant enumeration
A `COMPONENT_SET`'s variant children are its direct `COMPONENT` children. `props`
comes from parsing the variant node's `name` (Figma encodes variants as
`"Axis=Value, Axis2=Value2"`) — the same encoding `get_component_properties`
exposes via `variantOptions`. A non-set target (standalone `COMPONENT`) is treated
as a single "variant".

### 4.2 Hybrid render (per variant) — D1
1. **Instance-first (read-only):** find the largest placed `INSTANCE` whose main
   component is this variant (reuse `findRenderableInstance`, already shipped),
   with non-degenerate bounds → `exportAsync` it. `renderVia:"instance"`.
2. **Definition:** if no instance, export the variant node directly. If the PNG is
   non-degenerate (`pngDimensions` > 4px, already shipped), keep it.
   `renderVia:"definition"`.
3. **Temp-frame fallback (write):** if still degenerate (fill-container), §5.
   `renderVia:"temp-frame"`.
`boundsPx` is always read from the **exported PNG's IHDR** (the true rendered box),
never from a layout property.

### 4.3 `contentTree` (recorded for SP2, not reproduced in SP1) — D4
A shallow serialization of the variant's baked visual content, from the rendered
node (the instance when the fallback fired, else the definition):
```jsonc
{ "type": "FRAME", "name": "Snackbar",
  "children": [
    { "type": "TEXT", "name": "Supporting text", "characters": "Single-line snackbar" },
    { "type": "INSTANCE", "name": "Close", "mainComponent": { "id": "…", "name": "icon-button" } }
  ] }
```
Captured node types: `TEXT` (record `characters`), `INSTANCE` (record
`mainComponent {id,name}`), and containers (`FRAME`/`GROUP`/`COMPONENT`) for
structure. Depth-bounded (e.g. ≤4) to stay small. **SP1 only records it**; SP2
maps it to @m3e/web slots.

## 5. Temp-frame lifecycle (the key risk) — D1

The plugin is otherwise strictly read-only; these are its ONLY writes, authorized
for the capture pass, and made bulletproof:

1. **Pre-sweep:** at the start of `capture_set`, `findAll` any node named
   `__cem-capture-temp__` and `.remove()` it (cleans leftovers from a crashed run).
2. **Create:** a `FRAME` named `__cem-capture-temp__` at far off-canvas coords
   (e.g. `x=-100000, y=-100000`) on the current page, auto-layout HUG so it fits
   its child, with a fixed capture **width** for fill-container children (default
   360px, overridable; the harness matches the captured `boundsPx` regardless, so
   the exact value only affects content wrapping — §7).
3. **Populate:** `variant.createInstance()`, append to the temp frame.
4. **Export → then cleanup:**
   ```js
   var frame = figma.createFrame(); frame.name = "__cem-capture-temp__"; …
   try {
     var inst = variant.createInstance(); frame.appendChild(inst); …
     bytes = await inst.exportAsync(settings);
   } finally {
     frame.remove();   // GUARANTEED even on export throw
   }
   ```
5. The temp frame never enters the user's viewport and is gone before the command
   returns. A leaked frame (impossible under `finally`, but defense-in-depth) is
   named for the next run's pre-sweep to remove.

**Non-goal:** no other write primitives (set_fill, etc.). Just create-temp /
create-instance / remove.

## 6. Runner — `extract/capture.mjs` — D5

- Reads the existing dump for the 171 set node ids + names.
- For each set **not already in the sidecar** (resumable): `wsQuery("capture_set",
  {setNodeId, scale:2}, {channel})` → for each returned variant, write
  `profiles/m3-kit/captures/<setId>/<variantId>.png` from `imageData`, and append
  `{variantNodeId, props, boundsPx, renderVia, contentTree, renderPath}` under
  `captures[setId]` in `figma-captures.json`.
- Writes **incrementally** (flush the sidecar after each set) so a crash resumes.
- Flags: `--channel=<cem-xxxx>` (required), `--profile=m3-kit`, `--force` (re-capture
  all), `--only=<setId,…>` (subset), `--scale=2`.
- CLI subcommand wiring in `src/cli.mjs` (`capture`), mirroring `match`/`emit`.

## 7. Gate integration — `src/visual/{gate,drive}.mjs`

- **Resolve render by variant node id:** `driveState`'s `figmaNodeQuery` already
  yields the resolved **variant node id** (via `findVariantNode`, which pins unmapped
  axes to their Figma default). Add a resolver: given the profile's
  `figma-captures.json`, look up the captured `{renderPath, boundsPx}` by that
  **`variantNodeId`** (the primary key; `props` is a secondary human-readable index).
  This makes the captured render *exactly* the variant the live export produces today
  — no behavior change, just offline.
- **Offline compare:** `gate.mjs` loads `renderPath` from disk instead of calling
  `exportFigmaNode` — **when a capture exists**. Otherwise it falls back to the
  live `export_node_as_image` exactly as today (so the gate works before/without a
  capture, and during rollout).
- **Bounds-driven sizing:** the harness sizes the code element to the captured
  `boundsPx` (logical = px / deviceScaleFactor). This **replaces the per-component
  hand-tuned widths/sizes** (shape 320, search-bar 360, list-item 239, fab small) —
  those become "size to captured bounds", derived not guessed. Keep them as a
  fallback for components without a capture.

## 8. Error handling, resumability, constraints

- Per-variant capture failure (export throw, missing instance + temp-frame error) →
  record `{variantNodeId, props, error}` in the sidecar, **continue** the set.
- Still-degenerate after fallback → `degenerate:true` in the sidecar; the gate
  treats a degenerate capture as "no capture" (live fallback) and it surfaces in a
  capture report.
- Resumable per-set (`--force` overrides); the runner never loses completed sets.
- **ES2019:** `code.js` must stay free of `??`/`?.` (README verify gate:
  `grep -an '??\|?\.' extract/plugin/code.js` empty) and NUL bytes.
- Plugin reload: new commands require re-running the plugin in Figma (new channel).

## 9. Testing

- **Pure helpers** (unit): `pngDimensions` (shipped), `contentTree` serialization
  (extract to a pure fn over a plain node shape so it's testable without `figma.*`),
  the runner's props→render resolver.
- **Runner** (unit): orchestration + incremental/resumable sidecar writes against a
  **mocked `capture_set`** (deterministic fixture) — no live bridge.
- **Gate offline-read** (unit): a fixture `figma-captures.json` + fixture PNGs →
  assert the gate resolves + diffs offline, and falls back to live when a capture
  is absent.
- **Regression (live, once):** after a real capture, **re-gate the current 12
  banked components against the captured renders — all must still pass** (the
  captured render must match the live export within tolerance). This is the
  acceptance test that the capture is faithful.
- **Plugin** (live): `figma.*` can't be unit-tested; verify by capturing a few
  representative sets (snackbar = fill-container temp-frame; button = instance;
  shape = many variants) and eyeballing renders/bounds/content.

## 10. Rollout, migration, open items

- **Additive/non-breaking:** the live-export path stays; the gate prefers a capture
  when present. So we can capture incrementally and the gate keeps working
  throughout.
- **Storage size (D3, revisit):** commit everything for the first real capture, then
  measure. If the render set is large (est. thousands of PNGs), switch renders to a
  gitignored cache + committed metadata, or git-LFS, or a release artifact — decide
  **after** the real numbers.
- **SP2 handoff:** `contentTree` is the interface SP2 consumes to reproduce baked
  content in code (app-bar/toolbar/rich-tooltip/composites). No SP2 work here.
- **fab tier** (unrelated, still open from 2026-07-14): bank fab at the benign-AA
  0.10 tier, or chase the last ~1px — a separate decision.

## 11. Non-goals (SP1)

- Reproducing baked content in the code render (that is SP2).
- Any write primitive beyond the temp-frame create/instance/remove.
- Capturing the code-render side (unchanged — Playwright as today).
- Publishing / org-PAT publish (unchanged, still gated on Jack's org token).
