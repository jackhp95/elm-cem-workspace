# SP1 — Comprehensive Figma Capture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Capture every Figma variant's render + bounds + baked-content tree once into a committed "dump v2", so the visual gate compares against captured renders **offline** (no live bridge per gate) and fill-container / sizing are handled by construction.

**Architecture:** A read-mostly plugin command `capture_set` (hybrid render: placed instance → temp-frame fallback) returns per-variant render+bounds+contentTree. A Node runner loops the 171 sets, writes PNGs + a resumable JSON sidecar. The gate resolves a driven state's variant-node-id to a captured render (offline) and sizes the code element from captured bounds; the live export stays as a fallback.

**Tech Stack:** ES2019 Figma plugin (`extract/plugin/code.js`, no bundler, no `??`/`?.`), Node ESM (`extract/`, `src/`), the existing WS bridge (`extract/lib/ws-query.mjs`), `node:test`, `pngjs`, `pixelmatch`.

**Spec:** `plans/2026-07-15-comprehensive-figma-capture-design.md`

---

## File Structure

- **Create `src/capture/captures.mjs`** — pure sidecar helpers: `emptyCaptures`, `loadCaptures`, `saveCaptures`, `upsertSetCaptures`, `capturedSetIds`, `resolveCaptureByVariant`. Node, no `figma.*`, fully unit-tested. One responsibility: the dump-v2 data structure + lookups.
- **Create `extract/capture.mjs`** — the runner: iterate the 171 sets from the existing dump, call `capture_set` over the bridge, write PNGs + incrementally persist the sidecar. Resumable. Depends on `captures.mjs` + `ws-query.mjs`.
- **Modify `src/cli.mjs`** — add the `capture` subcommand (mirrors `match`/`emit`).
- **Modify `extract/plugin/code.js`** — add `capture_set(setNodeId, scale)` + `serializeContentTree` + temp-frame helpers (reuses shipped `pngDimensions`/`findRenderableInstance`). ES2019.
- **Modify `src/visual/gate.mjs`** — prefer a captured render (offline) over `exportFigmaNode`; thread captured `boundsPx` into the state.
- **Modify `src/visual/drive.mjs`** — attach captured `boundsPx` to `harnessParams` when a capture exists (bounds-driven sizing).
- **Modify `src/visual/harness/page.mjs`** — size the element from `boundsPx` params (replaces per-tag hand-tuned sizes as the primary path; keep the per-tag blocks as fallback).
- **Tests:** `test/captures.test.mjs`, `test/capture-runner.test.mjs`, `test/gate-offline.test.mjs`.

**Testing philosophy:** all `figma.*`-bound code (`capture_set`, the content walk, temp-frame) is verified **live** (Task 4/7) — Node can't run the Plugin API. Everything testable in Node (sidecar, runner orchestration, gate resolution, sizing) is TDD'd with mocks/fixtures.

---

## Task 1: Captures sidecar module (pure)

**Files:**
- Create: `src/capture/captures.mjs`
- Test: `test/captures.test.mjs`

- [ ] **Step 1: Write the failing test**

```javascript
// test/captures.test.mjs
import { test } from "node:test";
import assert from "node:assert/strict";
import {
  emptyCaptures, upsertSetCaptures, capturedSetIds, resolveCaptureByVariant,
} from "../src/capture/captures.mjs";

const SET = {
  setNodeId: "53977:33575",
  setName: "Snackbar",
  variants: [
    { variantNodeId: "53977:33611", props: { Configuration: "Text only" }, boundsPx: { w: 688, h: 96 }, renderVia: "temp-frame", contentTree: { type: "COMPONENT" }, renderPath: "captures/53977-33575/53977-33611.png", degenerate: false },
  ],
};

test("emptyCaptures has the versioned shape", () => {
  const c = emptyCaptures("m3-kit", 2);
  assert.deepEqual(c, { meta: { profile: "m3-kit", scale: 2 }, captures: {} });
});

test("upsertSetCaptures adds a set, capturedSetIds lists it, re-upsert replaces (idempotent)", () => {
  let c = emptyCaptures("m3-kit", 2);
  c = upsertSetCaptures(c, SET);
  assert.deepEqual(capturedSetIds(c), ["53977:33575"]);
  const again = upsertSetCaptures(c, SET);
  assert.deepEqual(again, c, "same set re-upserted is byte-identical");
});

test("resolveCaptureByVariant finds a variant across sets by node id; null when absent", () => {
  const c = upsertSetCaptures(emptyCaptures("m3-kit", 2), SET);
  assert.deepEqual(resolveCaptureByVariant(c, "53977:33611"), {
    renderPath: "captures/53977-33575/53977-33611.png", boundsPx: { w: 688, h: 96 }, degenerate: false,
  });
  assert.equal(resolveCaptureByVariant(c, "9:9"), null);
});

test("a degenerate variant resolves with degenerate:true (gate treats it as no-capture)", () => {
  const c = upsertSetCaptures(emptyCaptures("m3-kit", 2),
    { setNodeId: "1:1", setName: "X", variants: [{ variantNodeId: "1:2", props: {}, boundsPx: { w: 1, h: 1 }, renderVia: "definition", contentTree: {}, renderPath: "captures/1-1/1-2.png", degenerate: true }] });
  assert.equal(resolveCaptureByVariant(c, "1:2").degenerate, true);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `node --test test/captures.test.mjs`
Expected: FAIL — `Cannot find module '../src/capture/captures.mjs'`.

- [ ] **Step 3: Write the implementation**

```javascript
// src/capture/captures.mjs
// The "dump v2" sidecar: per-variant captured render + bounds + baked content tree,
// keyed set -> variants. Pure data helpers; no figma.*, no I/O beyond load/save.
import fs from "node:fs";

export function emptyCaptures(profile, scale) {
  return { meta: { profile, scale }, captures: {} };
}

// Replace (or add) a whole set's captures. Deterministic (sorted variant order in,
// sorted keys out) so re-running is byte-stable.
export function upsertSetCaptures(c, setCapture) {
  const captures = { ...c.captures, [setCapture.setNodeId]: setCapture };
  const ordered = {};
  for (const id of Object.keys(captures).sort()) ordered[id] = captures[id];
  return { meta: c.meta, captures: ordered };
}

export function capturedSetIds(c) {
  return Object.keys(c.captures);
}

// Find a variant's captured render by its node id, across every set. Returns the
// gate-facing shape { renderPath, boundsPx, degenerate }, or null.
export function resolveCaptureByVariant(c, variantNodeId) {
  for (const setId of Object.keys(c.captures)) {
    for (const v of c.captures[setId].variants) {
      if (v.variantNodeId === variantNodeId) {
        return { renderPath: v.renderPath, boundsPx: v.boundsPx, degenerate: !!v.degenerate };
      }
    }
  }
  return null;
}

export function loadCaptures(path) {
  if (!fs.existsSync(path)) return null;
  return JSON.parse(fs.readFileSync(path, "utf8"));
}

// Deterministic serialization (2-space, trailing newline) — same discipline as
// correspondence.json, so git diffs stay minimal.
export function saveCaptures(path, c) {
  fs.writeFileSync(path, JSON.stringify(c, null, 2) + "\n");
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `node --test test/captures.test.mjs`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add src/capture/captures.mjs test/captures.test.mjs
git commit -m "feat(capture): dump-v2 sidecar module (load/save/upsert/resolve-by-variant)"
```

---

## Task 2: Capture runner (orchestration, resumable)

**Files:**
- Create: `extract/capture.mjs`
- Test: `test/capture-runner.test.mjs`

The runner is testable by injecting a fake `captureSet` (no live bridge) and a temp output dir.

- [ ] **Step 1: Write the failing test**

```javascript
// test/capture-runner.test.mjs
import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { runCapture } from "../extract/capture.mjs";

function tmpDir() { return fs.mkdtempSync(path.join(os.tmpdir(), "cap-")); }

// A fake capture_set: one variant per set, a 1x1 PNG payload (base64).
const PNG_1x1 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=";
async function fakeCaptureSet(setNodeId) {
  return {
    setNodeId, setName: "Set-" + setNodeId,
    variants: [{ variantNodeId: setNodeId + ":v1", props: { A: "x" }, boundsPx: { w: 10, h: 10 }, renderVia: "definition", contentTree: { type: "COMPONENT" }, imageData: PNG_1x1, degenerate: false }],
  };
}

test("runCapture writes one PNG + a sidecar per set; renderPath is relative + correct", async () => {
  const dir = tmpDir();
  const sidecarPath = path.join(dir, "figma-captures.json");
  const rendersRoot = path.join(dir, "captures");
  await runCapture({ setNodeIds: ["1:1", "2:2"], profile: "m3-kit", scale: 2, sidecarPath, rendersRoot, captureSet: fakeCaptureSet });

  const c = JSON.parse(fs.readFileSync(sidecarPath, "utf8"));
  assert.deepEqual(Object.keys(c.captures).sort(), ["1:1", "2:2"]);
  const v = c.captures["1:1"].variants[0];
  assert.equal(v.renderPath, "captures/1-1/1-1-v1.png");     // ":" -> "-" in path segments
  assert.ok(!("imageData" in v), "imageData is stripped from the sidecar (it's on disk)");
  assert.ok(fs.existsSync(path.join(dir, v.renderPath)), "PNG written to disk");
});

test("runCapture is resumable: a second run skips already-captured sets", async () => {
  const dir = tmpDir();
  const sidecarPath = path.join(dir, "figma-captures.json");
  const rendersRoot = path.join(dir, "captures");
  const seen = [];
  const spy = async (id) => { seen.push(id); return fakeCaptureSet(id); };

  await runCapture({ setNodeIds: ["1:1"], profile: "m3-kit", scale: 2, sidecarPath, rendersRoot, captureSet: spy });
  await runCapture({ setNodeIds: ["1:1", "2:2"], profile: "m3-kit", scale: 2, sidecarPath, rendersRoot, captureSet: spy });
  assert.deepEqual(seen, ["1:1", "2:2"], "1:1 captured once, only 2:2 on the resume");

  // --force re-captures everything.
  await runCapture({ setNodeIds: ["1:1"], profile: "m3-kit", scale: 2, sidecarPath, rendersRoot, captureSet: spy, force: true });
  assert.deepEqual(seen, ["1:1", "2:2", "1:1"]);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `node --test test/capture-runner.test.mjs`
Expected: FAIL — `Cannot find module '../extract/capture.mjs'`.

- [ ] **Step 3: Write the implementation**

```javascript
// extract/capture.mjs
// Runner: iterate the target set node ids, capture each set over the bridge,
// write PNGs to <rendersRoot>/<setId>/<variantId>.png and persist the sidecar
// incrementally (flush after each set) so the pass resumes on crash/interrupt.
import fs from "node:fs";
import path from "node:path";
import { wsQuery } from "./lib/ws-query.mjs";
import { emptyCaptures, loadCaptures, saveCaptures, upsertSetCaptures, capturedSetIds } from "../src/capture/captures.mjs";

const seg = (id) => id.replace(/:/g, "-");   // ":" is invalid in Windows paths; normalize for filenames

// Live capture_set over the bridge. Injectable so tests pass a fake.
function bridgeCaptureSet(channel, scale) {
  return async (setNodeId) => {
    const res = await wsQuery("capture_set", { setNodeId, scale }, { channel, timeoutMs: 120000 });
    if (!res || res.error) throw new Error(`capture_set(${setNodeId}): ${res && res.error}`);
    return res;
  };
}

export async function runCapture({ setNodeIds, profile, scale = 2, sidecarPath, rendersRoot, captureSet, force = false }) {
  let c = loadCaptures(sidecarPath) || emptyCaptures(profile, scale);
  const done = new Set(force ? [] : capturedSetIds(c));
  const outDir = path.dirname(sidecarPath);

  for (const setNodeId of setNodeIds) {
    if (done.has(setNodeId)) continue;
    const result = await captureSet(setNodeId);
    const variants = result.variants.map((v) => {
      const renderPath = path.join(path.basename(rendersRoot), seg(setNodeId), `${seg(v.variantNodeId)}.png`);
      const absDir = path.join(outDir, path.dirname(renderPath));
      fs.mkdirSync(absDir, { recursive: true });
      fs.writeFileSync(path.join(outDir, renderPath), Buffer.from(v.imageData, "base64"));
      const { imageData, ...meta } = v;   // strip the base64 from the sidecar; it lives on disk
      return { ...meta, renderPath: renderPath.split(path.sep).join("/") };
    });
    c = upsertSetCaptures(c, { setNodeId, setName: result.setName, variants });
    saveCaptures(sidecarPath, c);         // incremental flush = resumable
  }
  return c;
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `node --test test/capture-runner.test.mjs`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add extract/capture.mjs test/capture-runner.test.mjs
git commit -m "feat(capture): resumable per-set runner (writes PNGs + incremental sidecar)"
```

---

## Task 3: `capture` CLI subcommand

**Files:**
- Modify: `src/cli.mjs`
- Test: `test/smoke.test.mjs` (the CLI-dispatch suite)

- [ ] **Step 1: Write the failing test** (append to `test/smoke.test.mjs`)

```javascript
test("cli: capture requires --profile and --channel", () => {
  const noProfile = runCli(["capture"]);
  assert.equal(noProfile.status, 2);
  assert.match(noProfile.stderr, /requires --profile/);
  const noChannel = runCli(["capture", "--profile", "m3-kit"]);
  assert.equal(noChannel.status, 2);
  assert.match(noChannel.stderr, /requires --channel/);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `node --test test/smoke.test.mjs`
Expected: FAIL — capture dispatches to the stub / wrong error.

- [ ] **Step 3: Wire the subcommand** in `src/cli.mjs`

Find how `match`/`emit` are dispatched (they resolve `--profile` to `profiles/<name>` and call into their module). Add a `capture` case that:
- requires `--profile` (reuse the existing `requires --profile` guard),
- requires `--channel` (new guard: `if (!args.channel) { fail("capture requires --channel=<cem-xxxx>"); }`),
- resolves the profile's dump path + the 171 set node ids from it, then calls `runCapture`:

```javascript
// in the command switch, alongside match/emit:
case "capture": {
  const profileDir = requireProfile(args);          // existing helper used by match/emit
  if (!args.channel) { process.stderr.write("capture requires --channel=<cem-xxxx>\n"); process.exit(2); }
  const { runCapture } = await import("../extract/capture.mjs");
  const { bridgeCaptureSet } = await import("../extract/capture.mjs"); // export it in Task 2 if not already
  const profile = JSON.parse(fs.readFileSync(path.join(profileDir, "profile.json"), "utf8"));
  const dump = JSON.parse(fs.readFileSync(path.join(repoRoot, profile.figmaExportPath), "utf8"));
  const dd = dump.data || dump;
  const allSetIds = Object.keys(dd.setProperties || {});
  const only = args.only ? String(args.only).split(",") : null;
  const setNodeIds = only ? allSetIds.filter((id) => only.includes(id)) : allSetIds;
  await runCapture({
    setNodeIds, profile: path.basename(profileDir), scale: Number(args.scale || 2),
    sidecarPath: path.join(profileDir, "figma-captures.json"),
    rendersRoot: path.join(profileDir, "captures"),
    captureSet: bridgeCaptureSet(args.channel, Number(args.scale || 2)),
    force: !!args.force,
  });
  process.stdout.write(`capture: done (${setNodeIds.length} sets)\n`);
  break;
}
```

(Export `bridgeCaptureSet` from `extract/capture.mjs`.)

- [ ] **Step 4: Run the tests**

Run: `rm -rf render-cache/results && pnpm test 2>&1 | grep -E '^# (pass|fail)'`
Expected: green (the capture-guard test passes; no regressions).

- [ ] **Step 5: Commit**

```bash
git add src/cli.mjs extract/capture.mjs test/smoke.test.mjs
git commit -m "feat(cli): capture subcommand (--profile --channel [--only --force --scale])"
```

---

## Task 4: Plugin `capture_set` (live-verified)

**Files:**
- Modify: `extract/plugin/code.js`

No unit test — `figma.*` only runs inside Figma. Verified live (Task 7 is the real regression). Reuses the shipped `pngDimensions` + `findRenderableInstance`.

- [ ] **Step 1: Add the content-tree walker** (top-level helper, near `findRenderableInstance`)

```javascript
// Shallow baked-content tree for SP2. Records TEXT (characters), INSTANCE
// (mainComponent id/name), and container structure, depth-bounded. Read-only;
// ES2019 (no ??/?.). `getMC` is passed in because mainComponent is async in
// dynamic-page mode (resolved by the caller before walking is not possible; we
// walk sync and record the id lazily).
function serializeContentTree(node, depth) {
  if (!node || depth < 0) return null;
  var out = { type: node.type, name: node.name };
  if (node.type === "TEXT") { try { out.characters = node.characters; } catch (e) { /* ignore */ } }
  if (node.type === "INSTANCE") {
    try { if (node.mainComponent) out.mainComponent = { id: node.mainComponent.id, name: node.mainComponent.name }; } catch (e) { /* detached */ }
  }
  if (node.children && depth > 0) {
    var kids = [];
    for (var i = 0; i < node.children.length; i++) {
      var k = serializeContentTree(node.children[i], depth - 1);
      if (k) kids.push(k);
    }
    if (kids.length) out.children = kids;
  }
  return out;
}
```

- [ ] **Step 2: Add the temp-frame render helper** (returns { bytes, renderVia, exportedNode })

```javascript
// Render a variant with real bounds. instance -> definition -> temp-frame. The
// temp-frame branch is the plugin's ONLY write path: create off-canvas, populate,
// export, remove (guaranteed via finally). Read-only otherwise.
async function renderVariant(variant, settings) {
  // 1. placed instance
  var inst = await findRenderableInstance(variant);
  if (inst) return { bytes: await inst.exportAsync(settings), renderVia: "instance", node: inst };
  // 2. definition (non-degenerate)
  var direct = await variant.exportAsync(settings);
  var d = pngDimensions(direct);
  if (d.w > 4 && d.h > 4) return { bytes: direct, renderVia: "definition", node: variant };
  // 3. temp-frame fallback (write)
  var frame = figma.createFrame();
  frame.name = "__cem-capture-temp__";
  frame.x = -100000; frame.y = -100000;
  frame.layoutMode = "HORIZONTAL"; frame.primaryAxisSizingMode = "AUTO"; frame.counterAxisSizingMode = "AUTO";
  frame.clipsContent = false;
  try {
    var placed = variant.createInstance();
    frame.appendChild(placed);
    // fill-container children need a concrete width; the harness matches captured
    // bounds regardless, so this only affects content wrapping.
    try { placed.layoutSizingHorizontal = "FIXED"; placed.resize(360, placed.height); } catch (e) { /* not resizable */ }
    var bytes = await placed.exportAsync(settings);
    return { bytes: bytes, renderVia: "temp-frame", node: placed };
  } finally {
    frame.remove();   // GUARANTEED cleanup, even on export throw
  }
}
```

- [ ] **Step 3: Add the `capture_set` command** (inside `BRIDGE_COMMANDS`, after `export_node_as_image`)

```javascript
  // { setNodeId, scale? } -> every variant's render + bounds + content tree.
  // See plans/2026-07-15-comprehensive-figma-capture-design.md.
  "capture_set": async function (p, nodeId, scale) {
    if (!nodeId) return { error: "nodeId required" };
    // Pre-sweep: remove leftover temp frames from any crashed prior run.
    try {
      var junk = figma.currentPage.findAll(function (n) { return n.name === "__cem-capture-temp__"; });
      for (var s = 0; s < junk.length; s++) junk[s].remove();
    } catch (e) { /* best-effort */ }

    var set = await figma.getNodeByIdAsync(nodeId);
    if (!set) return { error: "node not found: " + nodeId };
    var variantNodes = (set.type === "COMPONENT_SET") ? set.children.filter(function (n) { return n.type === "COMPONENT"; }) : [set];
    var settings = { format: "PNG", constraint: { type: "SCALE", value: scale } };
    var variants = [];
    for (var i = 0; i < variantNodes.length; i++) {
      var vn = variantNodes[i];
      try {
        var r = await renderVariant(vn, settings);
        var dims = pngDimensions(r.bytes);
        var bin = "";
        for (var b = 0; b < r.bytes.byteLength; b++) bin += String.fromCharCode(r.bytes[b]);
        variants.push({
          variantNodeId: vn.id,
          props: parseVariantProps(vn.name),
          boundsPx: { w: dims.w, h: dims.h },
          renderVia: r.renderVia,
          contentTree: serializeContentTree(r.node, 4),
          imageData: btoa(bin),
          degenerate: dims.w <= 4 || dims.h <= 4,
        });
      } catch (e) {
        variants.push({ variantNodeId: vn.id, props: parseVariantProps(vn.name), error: (e && e.message) ? e.message : String(e) });
      }
    }
    return { setNodeId: set.id, setName: set.name, variants: variants };
  },
```

- [ ] **Step 4: Add `parseVariantProps`** (top-level helper)

```javascript
// Figma variant node name -> { Axis: Value } (names are "Axis=Value, Axis2=Value2").
function parseVariantProps(name) {
  var out = {};
  var parts = String(name).split(",");
  for (var i = 0; i < parts.length; i++) {
    var kv = parts[i].split("=");
    if (kv.length === 2) out[kv[0].trim()] = kv[1].trim();
  }
  return out;
}
```

- [ ] **Step 5: Bump the build id + verify ES2019/NUL**

Change `PLUGIN_BUILD` to `"a3-generalized-extract.3-capture-set"`.

Run:
```bash
grep -an '??\|?\.' extract/plugin/code.js            # must be empty
node --check extract/plugin/code.js                   # syntax OK
python3 -c "print('NUL' if b'\x00' in open('extract/plugin/code.js','rb').read() else 'clean')"  # clean
```
Expected: empty / syntax OK / clean.

- [ ] **Step 6: Commit**

```bash
git add extract/plugin/code.js
git commit -m "feat(plugin): capture_set — hybrid render + bounds + contentTree per variant (build .3)"
```

- [ ] **Step 7: Live smoke (needs a plugin reload)**

Reload the plugin in Figma (Plugins → Development → re-run; banner shows build `.3-capture-set`, new channel). Then, against the new channel:
```bash
node src/cli.mjs capture --profile m3-kit --channel=cem-<new> --only=53977:33575   # snackbar set only
```
Expected: `profiles/m3-kit/figma-captures.json` gains the snackbar set; `profiles/m3-kit/captures/53977-33575/*.png` are **non-1×1** (temp-frame fallback worked). Eyeball one PNG.

---

## Task 5: Gate offline-read (captured render, live fallback)

**Files:**
- Modify: `src/visual/gate.mjs`
- Test: `test/gate-offline.test.mjs`

- [ ] **Step 1: Write the failing test**

```javascript
// test/gate-offline.test.mjs
import { test } from "node:test";
import assert from "node:assert/strict";
import { resolveFigmaRender } from "../src/visual/gate.mjs";

test("resolveFigmaRender returns a captured render path when present + non-degenerate", () => {
  const captures = { meta: {}, captures: { "1:1": { setName: "X", variants: [
    { variantNodeId: "1:2", boundsPx: { w: 100, h: 40 }, renderPath: "captures/1-1/1-2.png", degenerate: false },
  ] } } };
  assert.deepEqual(resolveFigmaRender(captures, "1:2"), { renderPath: "captures/1-1/1-2.png", boundsPx: { w: 100, h: 40 } });
});

test("resolveFigmaRender returns null for a missing OR degenerate capture (=> caller falls back to live)", () => {
  const captures = { meta: {}, captures: { "1:1": { setName: "X", variants: [
    { variantNodeId: "1:2", boundsPx: { w: 1, h: 1 }, renderPath: "captures/1-1/1-2.png", degenerate: true },
  ] } } };
  assert.equal(resolveFigmaRender(captures, "1:2"), null);
  assert.equal(resolveFigmaRender(captures, "9:9"), null);
  assert.equal(resolveFigmaRender(null, "1:2"), null);
});
```

- [ ] **Step 2: Run to verify it fails**

Run: `node --test test/gate-offline.test.mjs`
Expected: FAIL — `resolveFigmaRender` not exported.

- [ ] **Step 3: Implement `resolveFigmaRender` + wire it into `runGate`**

Add to `src/visual/gate.mjs`:
```javascript
import { loadCaptures, resolveCaptureByVariant } from "../capture/captures.mjs";

// Captured render for a variant, or null when absent/degenerate (caller then
// falls back to the live bridge export).
export function resolveFigmaRender(captures, variantNodeId) {
  const hit = resolveCaptureByVariant(captures, variantNodeId);
  if (!hit || hit.degenerate) return null;
  return { renderPath: hit.renderPath, boundsPx: hit.boundsPx };
}
```

In `runGate`, load the sidecar once (`const captures = loadCaptures(path.join(profileDir, "figma-captures.json"))`), and in the per-state loop replace the unconditional `exportFigmaNode` with:
```javascript
const cap = resolveFigmaRender(captures, figmaNodeQuery.nodeId);
let figmaPath;
if (cap) {
  figmaPath = path.join(repoRoot, "profiles", profileName, cap.renderPath);  // captured PNG on disk
} else {
  const figmaBuf = await exportFigmaNode(figmaNodeQuery.nodeId, { channel, scale });  // live fallback (unchanged)
  figmaPath = path.join(figmaDir, `${stateId}.png`);
  fs.writeFileSync(figmaPath, figmaBuf);
}
// ...comparePngFiles({ ..., figmaPath, ... }) as today
```
(When a capture is used, no bridge/channel is needed for that state — the offline path.)

- [ ] **Step 4: Run the tests**

Run: `node --test test/gate-offline.test.mjs` → PASS.
Run: `rm -rf render-cache/results && pnpm test 2>&1 | grep -E '^# (pass|fail)'` → green.

- [ ] **Step 5: Commit**

```bash
git add src/visual/gate.mjs test/gate-offline.test.mjs
git commit -m "feat(gate): read captured render offline by variant node id; live export = fallback"
```

---

## Task 6: Bounds-driven code sizing

**Files:**
- Modify: `src/visual/drive.mjs`, `src/visual/harness/page.mjs`
- Test: `test/drive.test.mjs` (append)

- [ ] **Step 1: Write the failing test** (append to `test/drive.test.mjs`)

```javascript
test("driveState attaches boundsPx to harnessParams when a capture bound is supplied", () => {
  const entry = { cemTag: "m3e-shape", matcherKind: "standalone", figmaSets: [{ nodeId: "1:1", setName: "S" }], axes: [], props: [] };
  const { harnessParams } = driveState(entry, { data: { meta: {} } }, { setNodeId: "1:1", axisValues: {}, propValues: {}, boundsPx: { w: 640, h: 640 } });
  assert.deepEqual(harnessParams.boundsPx, { w: 640, h: 640 });
});
```

- [ ] **Step 2: Run to verify it fails**

Run: `node --test test/drive.test.mjs`
Expected: FAIL — `harnessParams.boundsPx` undefined.

- [ ] **Step 3: Thread boundsPx through drive + apply in the harness**

In `src/visual/drive.mjs` `driveState`, when `state.boundsPx` is present, add it to the returned `harnessParams` (both the standalone fast-path and the main path):
```javascript
const harnessParams = { tag: entry.cemTag, attrs, text, slots };
if (state.boundsPx) harnessParams.boundsPx = state.boundsPx;
```
The gate (Task 5) passes the captured `boundsPx` into the state it builds for a captured variant.

In `src/visual/harness/page.mjs`, after mounting `el`, before/with the per-tag blocks, apply captured bounds as the PRIMARY sizing (per-tag hand-tuned blocks become the fallback when no boundsPx):
```javascript
const boundsW = params.get("boundsPx.w");
const boundsH = params.get("boundsPx.h");
if (boundsW && boundsH) {
  // Captured Figma render is at deviceScaleFactor 2 -> logical = px / 2.
  el.style.width = `${Number(boundsW) / 2}px`;
  el.style.height = `${Number(boundsH) / 2}px`;
}
```
(The gate/harness URL builder must serialize `boundsPx.w`/`boundsPx.h` from `harnessParams.boundsPx` — mirror how `attr.*`/`slot.*` are serialized in `toHarnessUrlParams`.)

- [ ] **Step 4: Run the tests**

Run: `node --test test/drive.test.mjs` → PASS.
Run: `rm -rf render-cache/results && pnpm test 2>&1 | grep -E '^# (pass|fail)'` → green.

- [ ] **Step 5: Commit**

```bash
git add src/visual/drive.mjs src/visual/harness/page.mjs test/drive.test.mjs
git commit -m "feat(gate): size the code element from captured boundsPx (primary; per-tag = fallback)"
```

---

## Task 7: Full capture + regression (live acceptance)

**Files:** none (operational). Needs the plugin build `.3` reloaded + a live channel.

- [ ] **Step 1: Full capture**

```bash
node src/cli.mjs capture --profile m3-kit --channel=cem-<live>
```
Expected: `figma-captures.json` has all 171 sets; `profiles/m3-kit/captures/**` populated. Note any `error`/`degenerate` variants (a capture report).

- [ ] **Step 2: Measure size (feeds the D3 storage decision)**

```bash
du -sh profiles/m3-kit/captures
find profiles/m3-kit/captures -name '*.png' | wc -l
```
Report the numbers — decide commit-everything vs gitignore/LFS/artifact here (spec §10).

- [ ] **Step 3: Regression — re-gate the 12 banked OFFLINE**

For each of the 12 confirmed tags, run the gate WITHOUT a channel dependency for captured states and confirm it still passes (the captured render must match what the live export produced):
```bash
for t in m3e-button m3e-icon-button m3e-badge m3e-switch m3e-filter-chip m3e-input-chip m3e-suggestion-chip m3e-assist-chip m3e-checkbox m3e-search-bar m3e-list-item m3e-shape; do
  node src/visual/gate.mjs --tag=$t --channel=cem-<live>   # channel still passed, but captured states read offline
done
```
Expected: all 12 still `approved`/`pass`. Any regression = the captured render diverges from the live export → investigate that variant's capture (bounds/instance choice).

- [ ] **Step 4: Full suite + commit the capture**

```bash
rm -rf render-cache/results && pnpm test 2>&1 | grep -E '^# (pass|fail)'   # green
git add profiles/m3-kit/figma-captures.json profiles/m3-kit/captures    # (or per the D3 decision)
git commit -m "chore(capture): full m3-kit capture (dump v2 + renders)"
```

---

## Self-Review

**Spec coverage:** D1 hybrid render → Task 4 `renderVariant`. D2 all-171-every-variant → Task 3 (`allSetIds`) + Task 4 (`variantNodes`). D3 commit + revisit size → Task 7 Step 2/4. D4 contentTree recorded → Task 4 `serializeContentTree` (not reproduced — SP2). D5 per-set orchestration → Task 2. Temp-frame safety (§5) → Task 4 Step 2 (pre-sweep + `finally`). Gate offline-read by variant id (§7) → Task 5. Bounds-driven sizing (§7) → Task 6. Error handling (§8) → Task 4 (per-variant try/catch, `degenerate`), Task 2 (resumable). Testing (§9) → Tasks 1/2/5/6 unit; Task 7 live regression. Rollout/fallback (§10) → Task 5 (live fallback). No gaps.

**Placeholder scan:** no TBD/TODO; every code step has real code; the only judgement-call left is the temp-frame fill-container width (360px, documented as harness-matched).

**Type consistency:** `capture_set` result `{setNodeId,setName,variants:[{variantNodeId,props,boundsPx,renderVia,contentTree,imageData,degenerate|error}]}` is produced in Task 4 and consumed in Task 2 (`runCapture`) — matched fields. `resolveCaptureByVariant` / `resolveFigmaRender` return `{renderPath,boundsPx[,degenerate]}` consistently (Task 1 → Task 5). `harnessParams.boundsPx` set in Task 6 drive + read as `boundsPx.w/.h` in page.mjs (serialization noted).

**Open (carry to execution):** confirm the exact `src/cli.mjs` helper names (`requireProfile`, `repoRoot`) when wiring Task 3 — mirror `match`/`emit`. Confirm `toHarnessUrlParams` serialization point for `boundsPx` in Task 6.

---

## Execution outcome (2026-07-15) — ACCEPTANCE MET

Tasks 1–6 landed as specified (566 tests green). Task 7 (live) surfaced three things the plan/spec did not anticipate; see `plans/AUTONOMOUS-SESSION-FRICTIONS.md` AF-09/10/11:

- **Render priority was inverted.** The spec's D1 hybrid render was **instance-first**; the first live re-gate showed it mis-captures normal components (icon-button default came back a 240×104 aspect-2.31 outlier via a non-representative placed instance → 0.705). Corrected to **definition-first** (`renderNodeControlled`: definition → controlled temp-frame only when degenerate), and the whole doc-instance search was dropped (removed `findRenderableInstance` + the instance index). Plugin `.3`→`.5-definition-first`. After this, **all 12 banked re-gate PASS offline** (icon-button 0.0008, search-bar 0.0068, list-item 0.0777, badge 0.0547, button 0.095, rest already clean).
- **Wire seam + robustness.** Runner sent `{setNodeId}`; plugin expects `{nodeId}`. Runner also crashed on error-variants and aborted the sweep on one stuck set — now tolerates both (`{captures, skipped}`).
- **Scale + freshness.** Full sweep = **144/171 sets, 3,575 renders**. 27 skipped = 3 mega-sets (480/480/120 — one-WS-response-per-set exceeds the timeout, needs chunking) + 24 stale set-nodes; 674 error variants = dump staleness. None banked.

**D3 storage = gitignore** (captures kept local; gate falls back to live on a fresh clone). **Deferred follow-up (not blocking):** fresh dump export + `capture_set` chunking for true 100% coverage.

---

## 100%-coverage attempt (2026-07-17) — vendor-limited, PARKED

Chased the 27 uncaptured sets. The "deferred follow-up" framing above (fresh dump + chunking) turned out to be built on a **misdiagnosis** — see `AUTONOMOUS-SESSION-FRICTIONS.md` **AF-13** (corrects AF-11). What actually happened:

- **Dump was never stale.** A fresh re-extraction produced an **identical 171-set list**; every set exists live. `capture` reads the *set list* from the dump but renders variants *live*, so a same-structure refresh cannot change coverage. Dump refresh reverted.
- **Not a payload-size limit.** Shipped `capture_set` pagination (`.6-capture-chunked`, offset/limit/total + client-side merge) — but a paginated `limit=1` still doesn't return in 90s on an idle, build-verified plugin.
- **Real cause:** a per-variant **`exportAsync` stall** on **asset-heavy scaffolding sets** (List-item density baselines, Text field showcase — image/video/avatar fills). A Figma-export limitation on non-component sets. **None are banked.** All 12 real banked components capture fast + re-gate green.

**Shipped regardless (all committed):** pagination (`.6`); `ping` echoes `build` so a reload is verified, not assumed (`.6`→ verified; AF-12); a per-variant timeout guard (`raceTimeout`, `.7-per-variant-timeout`) so a stall becomes a recorded error + the sweep completes; `export.mjs` gains a 180s variables/styles timeout + `--reuse-tokens-on-failure` (the team-library variable service hangs on this kit).

**Closed (2026-07-18 — Jack: accept):** the `.7` reload happened (ping-build verified) and snackbar was tried. It **wedged the plugin** — a clean `limit=1` didn't return in 30s **and the 15s guard never fired**, proving the stall is a **synchronous thread block** (a `setTimeout` race can't fire while the JS thread is blocked). So the `.7` guard is non-functional for this class, and snackbar — despite not being asset-heavy — stalls too: the common factor is the fill-container **temp-frame render path**, not asset weight (the 144 captured sets all took the fast *definition* path). See `AUTONOMOUS-SESSION-FRICTIONS.md` **AF-14**. Decision: fill-container components (snackbar + the ~27 scaffolding holdouts) use the gate's **live-export fallback**, not offline capture; snackbar stays unbanked-via-capture. The ineffective guard was removed (`.7-per-variant-timeout` → **`.8-drop-guard`**). **Kept:** pagination (`.6`), ping-build reload verification, `export.mjs` token-timeout/reuse. Final coverage: **144/171 sets, all 12 real banks captured + green.** Hard operational lesson: `ping` to confirm idle BEFORE every live capture probe and never fire a second probe until the first returns — one synchronous stall wedges the whole plugin.
