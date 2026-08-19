// Task C4: the pixel-diff pipeline.
//
// Run with the file-arg form (bare `node --test` mis-discovers non-test
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test src/visual/diff.test.mjs
//
// Fixtures (src/visual/fixtures/, copied from research/spikes/07-render-harness/
// 2026-07-10 spike — see src/visual/diff.mjs's module docstring for the full
// measured-dimensions table this test exercises the decisive rows of):
//   btn-57994-2322.png            Figma export, Button (filled) set,   120x56
//   btn-57994-2262.png            Figma export, Button - text set,    120x56
//   btn-57994-2282.png            Figma export, Button - outline set, 120x56
//   btn-57994-2302.png            Figma export, Button - tonal set,   120x56
//   btn-57994-2242.png            Figma export, Button - elevated set,136x72
//   figma-button-filled-medium.png  a split/combo button (NOT a plain
//                                    Button variant), 178x56
//   shots/button-filled-run{1,2}.png  code renders, byte-identical,   134x80

import { test } from "node:test";
import assert from "node:assert/strict";
import path from "node:path";
import { fileURLToPath } from "node:url";
import fs from "node:fs/promises";
import os from "node:os";

import { PNG } from "pngjs";
import {
  readPng,
  unionAlign,
  diffAligned,
  diffPngPair,
  comparePngFiles,
  writeResultRecord,
  loadThresholds,
  trimTransparent,
  normalizeScale,
  resizeAreaAverage,
  PIXEL_EXACT,
  TEXT_TIER,
  SCALE_NORMALIZE_MAX_RATIO,
  DEGENERATE_MIN_DIMENSION,
  isFullyTransparent,
  degenerateReason,
  isTextBearing,
  thresholdFor,
} from "./diff.mjs";

// -- synthetic PNG helpers (for trim/scale normalization tests) ---------------
function solid(w, h, [r, g, b, a] = [255, 0, 0, 255]) {
  const png = new PNG({ width: w, height: h });
  for (let i = 0; i < w * h; i++) {
    png.data[i * 4] = r;
    png.data[i * 4 + 1] = g;
    png.data[i * 4 + 2] = b;
    png.data[i * 4 + 3] = a;
  }
  return png;
}
function padded(inner, padX, padY) {
  const w = inner.width + 2 * padX;
  const h = inner.height + 2 * padY;
  const png = new PNG({ width: w, height: h }); // all-zero = transparent
  for (let y = 0; y < inner.height; y++) {
    for (let x = 0; x < inner.width; x++) {
      const si = (y * inner.width + x) * 4;
      const di = ((y + padY) * w + (x + padX)) * 4;
      for (let k = 0; k < 4; k++) png.data[di + k] = inner.data[si + k];
    }
  }
  return png;
}

const here = path.dirname(fileURLToPath(import.meta.url));
const fixtures = path.join(here, "fixtures");
const repoRoot = path.join(here, "..", "..");

const CODE_RUN1 = path.join(fixtures, "shots", "button-filled-run1.png");
const CODE_RUN2 = path.join(fixtures, "shots", "button-filled-run2.png");
const FILLED = path.join(fixtures, "btn-57994-2322.png"); // Button (filled), 120x56
const TONAL = path.join(fixtures, "btn-57994-2302.png"); // Button - tonal, 120x56
const OUTLINE = path.join(fixtures, "btn-57994-2282.png"); // Button - outline, 120x56
const TEXT = path.join(fixtures, "btn-57994-2262.png"); // Button - text, 120x56
const ELEVATED = path.join(fixtures, "btn-57994-2242.png"); // Button - elevated, 136x72 (different size)
const SPLIT_COMBO = path.join(fixtures, "figma-button-filled-medium.png"); // 178x56

let thresholds;
test.before(async () => {
  thresholds = await loadThresholds(path.join(repoRoot, "profiles", "m3-kit", "visual.json"));
});

test("profile thresholds are the calibrated starting values", () => {
  assert.deepEqual(thresholds, {
    maxDiffRatio: 0.02,
    maxDiffRatioText: 0.10,
    pixelThreshold: 0.1,
    scaleInvariantTags: ["m3e-shape"],
    textTierTags: ["m3e-list-item"],
    benignAaTags: ["m3e-fab"],
  });
});

// -- measured dimensions (the "measure first" gate) --------------------------

test("measured: Figma export dimensions for the 5 button-variant fixtures", async () => {
  const dims = async (p) => {
    const png = await readPng(p);
    return `${png.width}x${png.height}`;
  };
  assert.equal(await dims(FILLED), "120x56");
  assert.equal(await dims(TONAL), "120x56");
  assert.equal(await dims(OUTLINE), "120x56");
  assert.equal(await dims(TEXT), "120x56");
  assert.equal(await dims(ELEVATED), "136x72"); // elevation shadow widens node bounds
  assert.equal(await dims(SPLIT_COMBO), "178x56"); // a different composition, not a plain Button
});

test("measured: code render (element screenshot) is a different box convention than the Figma export", async () => {
  const code = await readPng(CODE_RUN1);
  assert.equal(`${code.width}x${code.height}`, "134x80"); // tight to the element's own box
});

// -- alignment: union box + centering ----------------------------------------

test("unionAlign pads the smaller image, centered, and leaves the larger image's data untouched at its own size", async () => {
  const small = await readPng(FILLED); // 120x56
  const big = await readPng(ELEVATED); // 136x72
  const { width, height, dataA, dataB } = unionAlign(small, big);
  assert.equal(width, 136);
  assert.equal(height, 72);
  assert.equal(dataA.length, 136 * 72 * 4);
  assert.equal(dataB.length, 136 * 72 * 4);

  // The padded border of the smaller image's canvas must be fully
  // transparent (alpha 0) — union-box padding must never invent a visible
  // edge. Top-left corner pixel is padding for the 120x56 image centered in
  // a 136x72 box ((136-120)/2=8, (72-56)/2=8, so (0,0) is padding).
  assert.equal(dataA[3], 0, "top-left alpha of padded (smaller) image must be 0 (transparent)");

  // Bottom/right padding edges must also be fully transparent — a
  // transposition bug (e.g. width/height swapped when computing the
  // destination stride) could leave the top-left corner untouched (still
  // padding) while corrupting the far corners.
  const topRightIdx = (0 * width + (width - 1)) * 4;
  const bottomLeftIdx = ((height - 1) * width + 0) * 4;
  const bottomRightIdx = ((height - 1) * width + (width - 1)) * 4;
  assert.equal(dataA[topRightIdx + 3], 0, "top-right corner of padded (smaller) image must be transparent");
  assert.equal(dataA[bottomLeftIdx + 3], 0, "bottom-left corner of padded (smaller) image must be transparent");
  assert.equal(dataA[bottomRightIdx + 3], 0, "bottom-right corner of padded (smaller) image must be transparent");
});

test("unionAlign places the original image's pixels at the exact computed (offsetX, offsetY) — catches transposition/off-by-axis bugs", () => {
  // A real-fixture pixel spot-check is a weak guard here: FILLED vs ELEVATED
  // happen to need EQUAL offsetX/offsetY (both 8), so a bug that swapped
  // offsetX <-> offsetY in center()'s copy-loop math would be invisible.
  // Use a small synthetic image instead, sized so its two padding deltas are
  // UNEQUAL (offsetX=2, offsetY=1 below), with a single marker pixel placed
  // asymmetrically (not on the diagonal) so a swapped-offset bug lands the
  // marker at a demonstrably different, empty location instead of silently
  // matching.
  const width = 3;
  const height = 2;
  const data = Buffer.alloc(width * height * 4);
  const markerX = 2;
  const markerY = 1;
  const markerIdx = (markerY * width + markerX) * 4;
  data[markerIdx] = 10;
  data[markerIdx + 1] = 20;
  data[markerIdx + 2] = 30;
  data[markerIdx + 3] = 255;
  const pngA = { width, height, data };
  const pngB = { width: 7, height: 5, data: Buffer.alloc(7 * 5 * 4) }; // fully transparent, all zero

  const { width: unionWidth, height: unionHeight, dataA } = unionAlign(pngA, pngB);
  assert.equal(unionWidth, 7);
  assert.equal(unionHeight, 5);

  const offsetX = Math.floor((unionWidth - width) / 2); // 2
  const offsetY = Math.floor((unionHeight - height) / 2); // 1
  assert.equal(offsetX, 2);
  assert.equal(offsetY, 1);
  assert.notEqual(offsetX, offsetY, "precondition: offsets must differ, or a swap bug would be undetectable");

  // The marker must land at (markerX + offsetX, markerY + offsetY) —
  // the ORIGINAL image's pixel, unchanged, at the correctly-shifted position.
  const correctIdx = ((markerY + offsetY) * unionWidth + (markerX + offsetX)) * 4;
  assert.deepEqual(
    [dataA[correctIdx], dataA[correctIdx + 1], dataA[correctIdx + 2], dataA[correctIdx + 3]],
    [10, 20, 30, 255],
    "marker pixel must land at the computed (offsetX, offsetY) position"
  );

  // If center() instead applied a swapped/transposed offset (offsetY where
  // offsetX belongs and vice versa), the marker would land here instead —
  // confirm that spot is empty (still zero-filled padding), proving the
  // copy loop did NOT transpose the two offsets.
  const swappedX = markerX + offsetY;
  const swappedY = markerY + offsetX;
  assert.ok(swappedX !== markerX + offsetX || swappedY !== markerY + offsetY);
  const swappedIdx = (swappedY * unionWidth + swappedX) * 4;
  assert.deepEqual(
    [dataA[swappedIdx], dataA[swappedIdx + 1], dataA[swappedIdx + 2], dataA[swappedIdx + 3]],
    [0, 0, 0, 0],
    "the transposed-offset position must NOT hold the marker (proves offsetX/offsetY weren't swapped)"
  );
});

test("unionAlign is a no-op pad (offset 0) when both images are already the same size", async () => {
  const a = await readPng(FILLED);
  const b = await readPng(TONAL);
  const { width, height } = unionAlign(a, b);
  assert.equal(width, 120);
  assert.equal(height, 56);
});

// -- determinism gate: same bytes in -> same result out, every time ----------

test("determinism: diffPngPair on the same pair of files gives an identical diffRatio across repeated calls", async () => {
  const a1 = await readPng(FILLED);
  const b1 = await readPng(TONAL);
  const r1 = diffPngPair(a1, b1, { pixelThreshold: thresholds.pixelThreshold });

  const a2 = await readPng(FILLED);
  const b2 = await readPng(TONAL);
  const r2 = diffPngPair(a2, b2, { pixelThreshold: thresholds.pixelThreshold });

  assert.equal(r1.diffRatio, r2.diffRatio);
  assert.equal(r1.mismatchedPixels, r2.mismatchedPixels);
});

// -- the decisive calibration rows (module docstring's table) ----------------

test("same-pair (byte-identical code renders) PASSES: diffRatio is 0, well under maxDiffRatio", async () => {
  const record = await comparePngFiles({
    entryId: "m3e-button",
    stateId: "filled-run1-vs-run2",
    codePath: CODE_RUN1,
    figmaPath: CODE_RUN2,
    thresholds,
  });
  assert.equal(record.diffRatio, 0);
  assert.equal(record.pass, true);
});

test("cross-variant pair (filled vs tonal, same size) FAILS: diffRatio is far over maxDiffRatio", async () => {
  const record = await comparePngFiles({
    entryId: "m3e-button",
    stateId: "filled-vs-tonal",
    codePath: FILLED,
    figmaPath: TONAL,
    thresholds,
  });
  assert.ok(record.diffRatio > thresholds.maxDiffRatio);
  assert.equal(record.pass, false);
});

test("cross-variant pair (filled vs outline, same size) FAILS", async () => {
  const record = await comparePngFiles({
    entryId: "m3e-button",
    stateId: "filled-vs-outline",
    codePath: FILLED,
    figmaPath: OUTLINE,
    thresholds,
  });
  assert.ok(record.diffRatio > thresholds.maxDiffRatio);
  assert.equal(record.pass, false);
});

test("cross-variant pair (filled vs text, same size) FAILS", async () => {
  const record = await comparePngFiles({
    entryId: "m3e-button",
    stateId: "filled-vs-text",
    codePath: FILLED,
    figmaPath: TEXT,
    thresholds,
  });
  assert.ok(record.diffRatio > thresholds.maxDiffRatio);
  assert.equal(record.pass, false);
});

test("cross-variant pair with a DIFFERENT size (filled 120x56 vs elevated 136x72) still FAILS after union-box alignment", async () => {
  const record = await comparePngFiles({
    entryId: "m3e-button",
    stateId: "filled-vs-elevated",
    codePath: FILLED,
    figmaPath: ELEVATED,
    thresholds,
  });
  assert.ok(record.diffRatio > thresholds.maxDiffRatio);
  assert.equal(record.pass, false);
});

test("closest cross-variant pair (tonal vs elevated) still FAILS — smallest margin in the calibration table, ~4x over threshold", async () => {
  const record = await comparePngFiles({
    entryId: "m3e-button",
    stateId: "tonal-vs-elevated",
    codePath: TONAL,
    figmaPath: ELEVATED,
    thresholds,
  });
  assert.ok(
    record.diffRatio > thresholds.maxDiffRatio,
    `expected diffRatio (${record.diffRatio}) > maxDiffRatio (${thresholds.maxDiffRatio})`
  );
  assert.equal(record.pass, false);
});

test("a structurally different fixture (split/combo button, not a plain Button variant) FAILS against filled", async () => {
  const record = await comparePngFiles({
    entryId: "m3e-button",
    stateId: "split-combo-vs-filled",
    codePath: SPLIT_COMBO,
    figmaPath: FILLED,
    thresholds,
  });
  assert.ok(record.diffRatio > thresholds.maxDiffRatio);
  assert.equal(record.pass, false);
});

// -- result record shape + artifact writing ----------------------------------

test("comparePngFiles returns the {entryId, stateId, pass, diffRatio, threshold, artifacts} shape", async () => {
  const record = await comparePngFiles({
    entryId: "m3e-button",
    stateId: "filled-vs-tonal",
    codePath: FILLED,
    figmaPath: TONAL,
    thresholds,
  });
  assert.equal(record.entryId, "m3e-button");
  assert.equal(record.stateId, "filled-vs-tonal");
  assert.equal(typeof record.pass, "boolean");
  assert.equal(typeof record.diffRatio, "number");
  assert.equal(record.threshold, thresholds.maxDiffRatio);
  assert.equal(record.pixelThreshold, thresholds.pixelThreshold);
  assert.deepEqual(record.artifacts, { code: FILLED, figma: TONAL, diff: null });
  assert.ok(record.diffPng); // in-memory only, not yet written — writeResultRecord's job
});

test("writeResultRecord appends one JSON line to render-cache/results/<runId>.jsonl and writes the diff PNG alongside", async () => {
  const cacheDir = await fs.mkdtemp(path.join(os.tmpdir(), "cem-figma-connect-diff-test-"));
  try {
    const record = await comparePngFiles({
      entryId: "m3e-button",
      stateId: "filled-vs-tonal",
      codePath: FILLED,
      figmaPath: TONAL,
      thresholds,
    });
    const runId = "test-run";
    const written = await writeResultRecord(record, { cacheDir, runId });

    assert.equal(written.diffPng, undefined, "the written record must not carry the in-memory PNG");
    assert.ok(written.artifacts.diff, "artifacts.diff must be filled in with a real path");

    const diffStat = await fs.stat(written.artifacts.diff);
    assert.ok(diffStat.isFile());

    const jsonlPath = path.join(cacheDir, "results", `${runId}.jsonl`);
    const jsonlContent = await fs.readFile(jsonlPath, "utf8");
    const lines = jsonlContent.trim().split("\n");
    assert.equal(lines.length, 1);
    const parsed = JSON.parse(lines[0]);
    assert.equal(parsed.entryId, "m3e-button");
    assert.equal(parsed.artifacts.diff, written.artifacts.diff);
    assert.equal(parsed.diffPng, undefined);

    // Appending a second record appends a second line — never overwrites.
    const record2 = await comparePngFiles({
      entryId: "m3e-button",
      stateId: "filled-vs-outline",
      codePath: FILLED,
      figmaPath: OUTLINE,
      thresholds,
    });
    await writeResultRecord(record2, { cacheDir, runId });
    const jsonlContent2 = await fs.readFile(jsonlPath, "utf8");
    assert.equal(jsonlContent2.trim().split("\n").length, 2);
  } finally {
    await fs.rm(cacheDir, { recursive: true, force: true });
  }
});

test("writeResultRecord requires a runId", async () => {
  const record = await comparePngFiles({
    entryId: "m3e-button",
    stateId: "filled-vs-tonal",
    codePath: FILLED,
    figmaPath: TONAL,
    thresholds,
  });
  await assert.rejects(() => writeResultRecord(record, { cacheDir: "/tmp/whatever" }), /runId is required/);
});

// -- Tiered thresholds: isTextBearing / thresholdFor -------------------------

test("PIXEL_EXACT and TEXT_TIER are the documented named constants", () => {
  assert.equal(PIXEL_EXACT, 0.02);
  assert.equal(TEXT_TIER, 0.10);
});

test("isTextBearing: entry with a kind:'text' prop -> true", () => {
  const textEntry = {
    cemTag: "m3e-badge",
    props: [{ figmaProp: "Badge label", kind: "text", binding: "content" }],
  };
  assert.equal(isTextBearing(textEntry), true);
});

test("isTextBearing: entry with no kind:'text' props -> false (switch, icon-button, shape)", () => {
  const switchEntry = {
    cemTag: "m3e-switch",
    props: [{ figmaProp: "Show focus indicator", kind: "boolean", unmapped: "Figma-only" }],
  };
  assert.equal(isTextBearing(switchEntry), false);

  const iconButtonEntry = { cemTag: "m3e-icon-button", props: [] };
  assert.equal(isTextBearing(iconButtonEntry), false);

  const shapeEntry = { cemTag: "m3e-shape", props: [] };
  assert.equal(isTextBearing(shapeEntry), false);
});

test("isTextBearing: entry with only instanceSwap / boolean props -> false", () => {
  const entry = {
    cemTag: "m3e-fab",
    props: [{ figmaProp: "Icon", kind: "instanceSwap", binding: "slot:icon" }],
  };
  assert.equal(isTextBearing(entry), false);
});

test("isTextBearing: entry with mixed props including kind:'text' -> true (filter-chip, snackbar)", () => {
  const filterChip = {
    cemTag: "m3e-filter-chip",
    props: [
      { figmaProp: "Label text", kind: "text", binding: "content" },
      { figmaProp: "Leading icon", kind: "instanceSwap", binding: "slot:icon" },
    ],
  };
  assert.equal(isTextBearing(filterChip), true);

  const snackbar = {
    cemTag: "m3e-snackbar",
    props: [{ figmaProp: "Supporting text", kind: "text", binding: "content" }],
  };
  assert.equal(isTextBearing(snackbar), true);
});

test("thresholdFor returns TEXT_TIER for text-bearing entry, PIXEL_EXACT for pixel-exact entry", () => {
  const tiers = { maxDiffRatio: PIXEL_EXACT, maxDiffRatioText: TEXT_TIER, pixelThreshold: 0.1 };

  const badgeEntry = {
    cemTag: "m3e-badge",
    props: [{ figmaProp: "Badge label", kind: "text", binding: "content" }],
  };
  assert.equal(thresholdFor(badgeEntry, tiers), TEXT_TIER);

  const switchEntry = { cemTag: "m3e-switch", props: [] };
  assert.equal(thresholdFor(switchEntry, tiers), PIXEL_EXACT);
});

test("thresholdFor promotes a benignAaTags cemTag to TEXT_TIER (non-text icon/shape AA, e.g. m3e-fab)", () => {
  const tiers = { maxDiffRatio: PIXEL_EXACT, maxDiffRatioText: TEXT_TIER, pixelThreshold: 0.1, benignAaTags: ["m3e-fab"] };

  // m3e-fab has no kind:text prop, so isTextBearing is false — the benignAaTags
  // list is what promotes it (curved-shape + icon-glyph antialiasing).
  const fabEntry = { cemTag: "m3e-fab", props: [] };
  assert.equal(thresholdFor(fabEntry, tiers), TEXT_TIER);

  // A tag NOT in the list stays pixel-exact.
  const iconBtnEntry = { cemTag: "m3e-icon-button", props: [] };
  assert.equal(thresholdFor(iconBtnEntry, tiers), PIXEL_EXACT);
});

// -- Tiered threshold pass/fail matrix ----------------------------------------
//
// Builds two synthetic identical-pixel pairs and engineers a controlled
// diffRatio via a mismatched sub-region, then asserts the tier gate:
//
//   diffRatio ~0.08  (between PIXEL_EXACT=0.02 and TEXT_TIER=0.10):
//     text-bearing entry  -> PASS  (within TEXT_TIER)
//     pixel-exact entry   -> FAIL  (above PIXEL_EXACT)
//
//   diffRatio ~0.15  (above both tiers):
//     text-bearing entry  -> FAIL
//     pixel-exact entry   -> FAIL
//
//   diffRatio ~0.005 (below both tiers):
//     text-bearing entry  -> PASS
//     pixel-exact entry   -> PASS

// makePairWithRatio(targetRatio, size) -> [pngA, pngB] synthetic pair whose
// diffRatio (after alignment, no trim/scale because both are opaque and same
// size) is approximately targetRatio. Achieved by making a fraction of the
// pixels differ maximally (red vs blue — far enough apart that pixelmatch
// counts every one as mismatched at pixelThreshold=0.1). The exact ratio
// depends on pixelmatch's AA detection; we test with >, <, and known margins
// so that small float differences in AA detection do not break the assertions.
function makePairWithRatio(fraction, size = 100) {
  // solid red square
  const pngA = solid(size, size, [255, 0, 0, 255]);
  // solid blue square with the top `fraction` of rows replaced by red (matching)
  const pngB = solid(size, size, [0, 0, 255, 255]);
  const matchRows = Math.round((1 - fraction) * size); // rows that will match
  for (let y = 0; y < matchRows; y++) {
    for (let x = 0; x < size; x++) {
      const i = (y * size + x) * 4;
      pngB.data[i] = 255; // red
      pngB.data[i + 1] = 0;
      pngB.data[i + 2] = 0;
      pngB.data[i + 3] = 255;
    }
  }
  return [pngA, pngB];
}

test("tiered threshold: text-bearing PASSES at diffRatio ~0.08, pixel-exact FAILS", () => {
  const tiers = { maxDiffRatio: PIXEL_EXACT, maxDiffRatioText: TEXT_TIER, pixelThreshold: 0.1 };
  const textEntry = {
    cemTag: "m3e-filter-chip",
    props: [{ figmaProp: "Label text", kind: "text", binding: "content" }],
  };
  const pixelEntry = { cemTag: "m3e-switch", props: [] };

  const [a, b] = makePairWithRatio(0.08, 100);
  const { diffRatio } = diffPngPair(a, b, { pixelThreshold: tiers.pixelThreshold });

  // Verify our synthetic pair actually lands in the between-tiers window.
  assert.ok(
    diffRatio > PIXEL_EXACT && diffRatio < TEXT_TIER,
    `expected diffRatio (${diffRatio}) to be between PIXEL_EXACT (${PIXEL_EXACT}) and TEXT_TIER (${TEXT_TIER})`
  );

  const textPass = diffRatio <= thresholdFor(textEntry, tiers);
  const pixelPass = diffRatio <= thresholdFor(pixelEntry, tiers);
  assert.equal(textPass, true, "text-bearing entry must PASS at this diffRatio");
  assert.equal(pixelPass, false, "pixel-exact entry must FAIL at this diffRatio");
});

test("tiered threshold: both FAIL at diffRatio ~0.15 (above both tiers)", () => {
  const tiers = { maxDiffRatio: PIXEL_EXACT, maxDiffRatioText: TEXT_TIER, pixelThreshold: 0.1 };
  const textEntry = {
    cemTag: "m3e-badge",
    props: [{ figmaProp: "Badge label", kind: "text", binding: "content" }],
  };
  const pixelEntry = { cemTag: "m3e-icon-button", props: [] };

  const [a, b] = makePairWithRatio(0.15, 100);
  const { diffRatio } = diffPngPair(a, b, { pixelThreshold: tiers.pixelThreshold });

  assert.ok(diffRatio > TEXT_TIER, `expected diffRatio (${diffRatio}) > TEXT_TIER (${TEXT_TIER})`);

  assert.equal(diffRatio <= thresholdFor(textEntry, tiers), false, "text-bearing must FAIL above TEXT_TIER");
  assert.equal(diffRatio <= thresholdFor(pixelEntry, tiers), false, "pixel-exact must FAIL above TEXT_TIER");
});

test("tiered threshold: both PASS at diffRatio ~0.005 (below both tiers)", () => {
  const tiers = { maxDiffRatio: PIXEL_EXACT, maxDiffRatioText: TEXT_TIER, pixelThreshold: 0.1 };
  const textEntry = {
    cemTag: "m3e-snackbar",
    props: [{ figmaProp: "Supporting text", kind: "text", binding: "content" }],
  };
  const pixelEntry = { cemTag: "m3e-shape", props: [] };

  // Near-identical pair: same solid color, trivially 0 diff.
  const [a, b] = makePairWithRatio(0.005, 100);
  const { diffRatio } = diffPngPair(a, b, { pixelThreshold: tiers.pixelThreshold });

  assert.ok(diffRatio < PIXEL_EXACT, `expected diffRatio (${diffRatio}) < PIXEL_EXACT (${PIXEL_EXACT})`);

  assert.equal(diffRatio <= thresholdFor(textEntry, tiers), true, "text-bearing must PASS below PIXEL_EXACT");
  assert.equal(diffRatio <= thresholdFor(pixelEntry, tiers), true, "pixel-exact must PASS below PIXEL_EXACT");
});

test("comparePngFiles uses text tier when entry is provided and is text-bearing", async () => {
  // Use the filled vs code-run1 pair: code-vs-code is 0 diff, so inject a
  // text-bearing entry and assert it passes (zero diff passes any tier).
  const textEntry = {
    cemTag: "m3e-filter-chip",
    props: [{ figmaProp: "Label text", kind: "text", binding: "content" }],
  };
  const record = await comparePngFiles({
    entryId: "m3e-filter-chip",
    stateId: "same-pair",
    codePath: CODE_RUN1,
    figmaPath: CODE_RUN2,
    thresholds,
    entry: textEntry,
  });
  assert.equal(record.pass, true);
  assert.equal(record.threshold, TEXT_TIER, "threshold field in record must reflect the text tier");
});

test("comparePngFiles uses pixel-exact tier when entry is provided and is not text-bearing", async () => {
  const pixelEntry = { cemTag: "m3e-switch", props: [] };
  const record = await comparePngFiles({
    entryId: "m3e-switch",
    stateId: "same-pair",
    codePath: CODE_RUN1,
    figmaPath: CODE_RUN2,
    thresholds,
    entry: pixelEntry,
  });
  assert.equal(record.pass, true);
  assert.equal(record.threshold, PIXEL_EXACT, "threshold field in record must reflect pixel-exact tier");
});

test("comparePngFiles falls back to maxDiffRatio when entry is omitted (backward compat)", async () => {
  const record = await comparePngFiles({
    entryId: "m3e-button",
    stateId: "filled-vs-tonal",
    codePath: FILLED,
    figmaPath: TONAL,
    thresholds,
    // entry intentionally omitted
  });
  assert.equal(record.threshold, thresholds.maxDiffRatio, "no entry -> must use base maxDiffRatio");
});

// -- Step 1.4/1.5: transparent-margin trim + scale normalization --------------

test("trimTransparent crops to the non-transparent content bbox", () => {
  const t = trimTransparent(padded(solid(4, 4, [255, 0, 0, 255]), 3, 2));
  assert.equal(t.width, 4);
  assert.equal(t.height, 4);
  for (let i = 0; i < 4 * 4; i++) {
    assert.equal(t.data[i * 4], 255); // red
    assert.equal(t.data[i * 4 + 3], 255); // opaque
  }
});

test("trimTransparent returns the input unchanged when there is no transparent margin", () => {
  const s = solid(4, 4);
  assert.equal(trimTransparent(s), s);
});

test("normalizeScale downscales the larger image to the smaller's width, preserving aspect", () => {
  const [a, b] = normalizeScale(solid(10, 6), solid(20, 12));
  assert.equal(a.width, 10);
  assert.equal(b.width, 10);
  assert.equal(b.height, 6);
});

test("normalizeScale is a no-op (same references) when widths already match", () => {
  const a = solid(10, 6);
  const b = solid(10, 6);
  const [ra, rb] = normalizeScale(a, b);
  assert.equal(ra, a);
  assert.equal(rb, b);
});

test("diffPngPair: transparent padding alone is not a difference (trim collapses it)", () => {
  const s = solid(8, 8, [0, 80, 200, 255]);
  const { diffRatio } = diffPngPair(s, padded(s, 4, 6), { pixelThreshold: 0.1 });
  assert.ok(diffRatio < 0.01, `padding should trim to ~0 diff, got ${diffRatio}`);
});

test("diffPngPair: a 2x-scaled copy collapses to ~0 after scale normalization", () => {
  const { diffRatio } = diffPngPair(solid(8, 8), solid(16, 16), { pixelThreshold: 0.1 });
  assert.ok(diffRatio < 0.01, `pure-scale difference should normalize to ~0, got ${diffRatio}`);
});

test("normalizeScale leaves a small proportion difference untouched (below the gross-scale ratio)", () => {
  // 174 vs 166 wide (~1.05x) is a real proportion difference, not a DPR/scale
  // factor — rescaling would distort the other axis and manufacture a mismatch.
  const a = solid(174, 64);
  const b = solid(166, 64);
  const [ra, rb] = normalizeScale(a, b);
  assert.equal(ra, a);
  assert.equal(rb, b);
});

// -- Gate soundness: ratio cap + degenerate guard (2026-07-14) ---------------
//
// These tests cover the FALSE-PASS cases observed in live gate runs:
//   shape:     code 96×96 vs figma 1×1   -> diffRatio 0.000 (was FALSE PASS)
//   snackbar:  code 688×96 vs figma 1×1  -> diffRatio 0.000 (was FALSE PASS)
//   list-item: code 64×112 vs figma 560×160 (8.75×) -> 0.006 (was FALSE PASS)
//
// And two regression-safety cases proving the [1.5, 2.5] band still works:
//   legit DPR pair (200×100 @2x vs 100×50 @1x, same content) -> normalizes, ~0 diff
//   legit close pair (104×64 vs 120×96, matching content)   -> honest small diff
//
// And one completeness case:
//   both blank (fully-transparent vs fully-transparent)     -> degenerate FAIL

test("SCALE_NORMALIZE_MAX_RATIO and DEGENERATE_MIN_DIMENSION are the documented sentinel values", () => {
  assert.equal(SCALE_NORMALIZE_MAX_RATIO, 2.5);
  assert.equal(DEGENERATE_MIN_DIMENSION, 8);
});

test("isFullyTransparent: all-zero alpha -> true; any non-zero alpha -> false", () => {
  const blank = new PNG({ width: 2, height: 2 }); // all-zero by construction
  assert.equal(isFullyTransparent(blank), true);

  const s = solid(2, 2, [255, 0, 0, 255]); // fully opaque
  assert.equal(isFullyTransparent(s), false);

  // One opaque pixel is enough to make it non-transparent.
  const mixed = new PNG({ width: 2, height: 2 });
  mixed.data[7] = 128; // alpha of pixel 1
  assert.equal(isFullyTransparent(mixed), false);
});

test("degenerateReason: blank (fully-transparent) PNG on either side -> non-null reason", () => {
  const blank1x1 = new PNG({ width: 1, height: 1 });
  const opaque96x96 = solid(96, 96);

  assert.ok(degenerateReason(blank1x1, opaque96x96) !== null, "blank A should be degenerate");
  assert.ok(degenerateReason(opaque96x96, blank1x1) !== null, "blank B should be degenerate");
  assert.ok(degenerateReason(opaque96x96, opaque96x96) === null, "both opaque should be healthy");
});

test("degenerateReason: sub-minimum dimension (< 8px) on either side -> non-null reason", () => {
  const tiny = solid(1, 1);       // 1×1, opaque — not blank, but below DEGENERATE_MIN_DIMENSION
  const normal = solid(96, 96);

  assert.ok(degenerateReason(tiny, normal) !== null, "1×1 opaque A should be degenerate");
  assert.ok(degenerateReason(normal, tiny) !== null, "1×1 opaque B should be degenerate");
});

// Case 1: shape — code 96×96 (opaque) vs figma 1×1 (blank export).
// The 1×1 blank triggers the degenerate guard BEFORE reaching pixelmatch.
// Old behavior: diffRatio ~0.000, pass=true (FALSE PASS).
// New behavior: diffRatio=1, pass=false, degenerate=true.
test("soundness: code 96×96 vs figma 1×1 blank -> pass:false (degenerate, not ~0 collapse)", () => {
  const code = solid(96, 96, [100, 150, 200, 255]);
  const figma = new PNG({ width: 1, height: 1 }); // all-zero = fully transparent
  const result = diffPngPair(code, figma, { pixelThreshold: 0.1 });
  assert.equal(result.pass, undefined); // diffPngPair doesn't compute pass itself
  assert.equal(result.degenerate, true);
  assert.equal(result.diffRatio, 1);
  assert.ok(typeof result.reason === "string" && result.reason.includes("degenerate"));
});

// Case 2: snackbar — code 688×96 (opaque full render) vs figma 1×1 (blank).
// Old behavior: diffRatio ~0.000, pass=true (FALSE PASS).
// New behavior: diffRatio=1, pass=false, degenerate=true.
test("soundness: code 688×96 vs figma 1×1 blank -> pass:false (degenerate)", () => {
  const code = solid(688, 96, [50, 50, 50, 255]);
  const figma = new PNG({ width: 1, height: 1 });
  const result = diffPngPair(code, figma, { pixelThreshold: 0.1 });
  assert.equal(result.degenerate, true);
  assert.equal(result.diffRatio, 1);
});

// Case 3: list-item — code 64×112 vs figma 560×160 (ratio 8.75×, above MAX cap).
// Old behavior: normalizeScale collapsed the 8.75× gap to a ~1px canvas -> diffRatio ~0, pass=true.
// New behavior: ratio > SCALE_NORMALIZE_MAX_RATIO -> no rescale; both images are
// large enough to pass the degenerate guard; union-box diff of very different
// content -> diffRatio WELL above zero, NOT ~0.
test("soundness: code 64×112 vs figma 560×160 (ratio 8.75×) -> diffRatio NOT ~0 (no collapse)", () => {
  // Use maximally-different content (red vs blue) so the honest diff is large.
  const code = solid(64, 112, [255, 0, 0, 255]);
  const figma = solid(560, 160, [0, 0, 255, 255]);
  const result = diffPngPair(code, figma, { pixelThreshold: 0.1 });
  assert.equal(result.degenerate, undefined, "should not be flagged degenerate — both sides have real content");
  // The union box is 560×160 = 89600 pixels; the code side (64×112=7168 px) is
  // mostly padding in that union box; the figma side fills it entirely blue.
  // Almost no pixels will match -> diffRatio should be very high, not ~0.
  assert.ok(
    result.diffRatio > 0.5,
    `expected diffRatio > 0.5 for an 8.75× mismatch with different content, got ${result.diffRatio}`
  );
});

// Case 4 (regression safety): legit DPR pair — 200×100 @2x vs 100×50 @1x, SAME content.
// Ratio = 2.0, within [1.5, 2.5] -> normalization MUST still fire -> diffRatio ~0.
test("regression safety: legit DPR pair 200×100 @2x vs 100×50 @1x (ratio 2.0) still normalizes to ~0 diff", () => {
  // Both solid red — identical content at different scales.
  // After normalizeScale, both become 100×50 (or near-equivalent pixel grids).
  const hi = solid(200, 100, [200, 100, 50, 255]);
  const lo = solid(100, 50, [200, 100, 50, 255]);
  const result = diffPngPair(hi, lo, { pixelThreshold: 0.1 });
  assert.equal(result.degenerate, undefined, "legit DPR pair must not be flagged degenerate");
  assert.ok(
    result.diffRatio < 0.01,
    `DPR pair with same content must normalize to ~0 diff after scale normalization, got ${result.diffRatio}`
  );
});

// Case 5 (regression safety): a close pair with slightly different proportions.
// 104×64 vs 120×96 — ratio 120/104 ≈ 1.15, below SCALE_NORMALIZE_MIN_RATIO.
// normalizeScale is a no-op; union-box diff scores some diff from the size
// mismatch padding, but does NOT collapse to zero (honest diff).
test("regression safety: close pair 104×64 vs 120×96 (ratio ~1.15) diffs honestly — not collapsed", () => {
  const a = solid(104, 64, [255, 128, 0, 255]);
  const b = solid(120, 96, [255, 128, 0, 255]); // same color, but different size
  const result = diffPngPair(a, b, { pixelThreshold: 0.1 });
  assert.equal(result.degenerate, undefined);
  // The union box is 120×96; the 104×64 content is padded with transparent,
  // so all the extra pixels in the union box diff as mismatches.
  // Result is some honest non-zero diff (not collapsed to ~0).
  assert.ok(
    result.diffRatio > 0,
    `expected non-zero diff for different-sized same-color pair, got ${result.diffRatio}`
  );
});

// Case 6: both fully transparent (both blank) -> degenerate FAIL.
// Old behavior: two blank canvases -> all pixels match -> diffRatio 0, FALSE PASS.
// New behavior: degenerate guard catches blank-A first -> diffRatio=1, pass=false.
test("soundness: fully-transparent vs fully-transparent (both blank) -> pass:false (degenerate)", () => {
  const blankA = new PNG({ width: 96, height: 96 });
  const blankB = new PNG({ width: 96, height: 96 });
  const result = diffPngPair(blankA, blankB, { pixelThreshold: 0.1 });
  assert.equal(result.degenerate, true);
  assert.equal(result.diffRatio, 1);
});

// End-to-end: comparePngFiles propagates degenerate+reason onto the result record.
test("soundness: comparePngFiles with degenerate pair has pass:false, degenerate:true, reason in record", async () => {
  // Use a real fixture (CODE_RUN1, 134×80, opaque) as code side.
  // Synthetic 1×1 blank as figma side — written to a temp file for comparePngFiles.
  const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), "cem-figma-connect-degenerate-"));
  try {
    const blankPng = new PNG({ width: 1, height: 1 });
    const blankPath = path.join(tmpDir, "blank-1x1.png");
    await fs.writeFile(blankPath, PNG.sync.write(blankPng));

    const record = await comparePngFiles({
      entryId: "m3e-shape",
      stateId: "degenerate-test",
      codePath: CODE_RUN1,
      figmaPath: blankPath,
      thresholds,
    });

    assert.equal(record.pass, false, "degenerate pair must produce pass:false");
    assert.equal(record.diffRatio, 1, "degenerate pair must produce diffRatio:1");
    assert.equal(record.degenerate, true, "record must carry degenerate:true");
    assert.ok(typeof record.reason === "string", "record must carry a reason string");
    assert.ok(
      record.reason.includes("degenerate"),
      `reason must include 'degenerate', got: ${record.reason}`
    );
  } finally {
    await fs.rm(tmpDir, { recursive: true, force: true });
  }
});

// -- scaleInvariant path (m3e-shape, task refinement 2026-07-14) --------------
//
// The scale-invariant path (diffPngPair opts.scaleInvariant) normalizes BOTH
// trimmed images to a common box before diffing, collapsing pure-scale
// differences (m3e-shape variant whitespace padding: circle 640px content,
// clover 592px, etc.) while still catching shape-type mismatches.
//
// Three cases:
//   A. Same-shape at different sizes -> ~0 diff (pass)
//   B. Different shapes at different sizes -> high diff (fail)
//   C. One side blank/1x1 -> degenerate FAIL fires BEFORE scale logic (pass:false)

// Case A: same solid color at 80x80 vs 120x120 — same shape, different
// whitespace padding. scaleInvariant normalizes to 120x120; after resize both
// are identical solid red -> diffRatio ~0.
test("scaleInvariant: same shape at different sizes -> diffRatio ~0 (PASS)", () => {
  const a = solid(80, 80, [200, 80, 60, 255]);
  const b = solid(120, 120, [200, 80, 60, 255]);
  const result = diffPngPair(a, b, { pixelThreshold: 0.1, scaleInvariant: true });
  assert.equal(result.degenerate, undefined, "should not be degenerate");
  assert.ok(
    result.diffRatio < 0.01,
    `same shape at different sizes must produce ~0 diff, got ${result.diffRatio}`
  );
});

// Case B: two different shapes — red 80x80 vs blue 120x120. After
// scaleInvariant resize to 120x120 the content interiors still differ
// maximally (red vs blue) -> diffRatio high.
test("scaleInvariant: different shapes at different sizes -> diffRatio HIGH (FAIL)", () => {
  const circle = solid(80, 80, [255, 0, 0, 255]);   // red, smaller
  const square = solid(120, 120, [0, 0, 255, 255]); // blue, larger
  const result = diffPngPair(circle, square, { pixelThreshold: 0.1, scaleInvariant: true });
  assert.equal(result.degenerate, undefined, "should not be degenerate");
  assert.ok(
    result.diffRatio > 0.5,
    `different shapes must still produce high diff after scaleInvariant resize, got ${result.diffRatio}`
  );
});

// Case C: one side is blank/1x1 — degenerate guard fires BEFORE scale-invariant
// logic even when scaleInvariant is true. The guard is not bypassed.
test("scaleInvariant: blank 1x1 figma side -> degenerate FAIL (guard fires before scale logic)", () => {
  const code = solid(96, 96, [100, 150, 200, 255]);
  const blank = new PNG({ width: 1, height: 1 }); // fully transparent
  const result = diffPngPair(code, blank, { pixelThreshold: 0.1, scaleInvariant: true });
  assert.equal(result.degenerate, true, "blank side must trigger degenerate guard even with scaleInvariant");
  assert.equal(result.diffRatio, 1);
});

// -- textTierTags override (m3e-list-item, task refinement 2026-07-14) ---------
//
// An entry whose cemTag is in thresholds.textTierTags receives TEXT_TIER even
// when isTextBearing returns false (no kind:text prop). The existing
// isTextBearing (kind:text) signal continues to work alongside it.

test("thresholdFor: cemTag in textTierTags -> TEXT_TIER even without kind:text prop", () => {
  const tiers = {
    maxDiffRatio: PIXEL_EXACT,
    maxDiffRatioText: TEXT_TIER,
    pixelThreshold: 0.1,
    scaleInvariantTags: [],
    textTierTags: ["m3e-list-item"],
  };
  const listItemEntry = { cemTag: "m3e-list-item", props: [] }; // no kind:text prop
  assert.equal(isTextBearing(listItemEntry), false, "precondition: isTextBearing must be false");
  assert.equal(thresholdFor(listItemEntry, tiers), TEXT_TIER, "textTierTag override must select TEXT_TIER");
});

test("thresholdFor: cemTag NOT in textTierTags and no kind:text prop -> PIXEL_EXACT", () => {
  const tiers = {
    maxDiffRatio: PIXEL_EXACT,
    maxDiffRatioText: TEXT_TIER,
    pixelThreshold: 0.1,
    scaleInvariantTags: [],
    textTierTags: ["m3e-list-item"],
  };
  const shapeEntry = { cemTag: "m3e-shape", props: [] };
  assert.equal(thresholdFor(shapeEntry, tiers), PIXEL_EXACT);
});

test("thresholdFor: kind:text prop still triggers TEXT_TIER regardless of textTierTags", () => {
  const tiers = {
    maxDiffRatio: PIXEL_EXACT,
    maxDiffRatioText: TEXT_TIER,
    pixelThreshold: 0.1,
    scaleInvariantTags: [],
    textTierTags: [],
  };
  const filterChip = {
    cemTag: "m3e-filter-chip",
    props: [{ figmaProp: "Label text", kind: "text", binding: "content" }],
  };
  assert.equal(thresholdFor(filterChip, tiers), TEXT_TIER);
});

// loadThresholds propagates scaleInvariantTags and textTierTags from the profile.
test("loadThresholds: m3-kit visual.json includes scaleInvariantTags and textTierTags arrays", () => {
  // thresholds is loaded in test.before from the real profile JSON.
  assert.ok(Array.isArray(thresholds.scaleInvariantTags), "scaleInvariantTags must be an array");
  assert.ok(Array.isArray(thresholds.textTierTags), "textTierTags must be an array");
  assert.ok(thresholds.scaleInvariantTags.includes("m3e-shape"), "m3e-shape must be in scaleInvariantTags");
  assert.ok(thresholds.textTierTags.includes("m3e-list-item"), "m3e-list-item must be in textTierTags");
});
