// Task C4: the pixel-diff pipeline — the PERCEPTUAL HEART of the visual gate
// (Plan C). Compares a code-side render PNG (C1's
// src/visual/harness/capture.mjs, a Playwright ELEMENT screenshot) against a
// Figma-side export PNG (bridge `export-png`, a NODE-bounds export) and
// decides pass/fail against a profile's threshold.
//
// Library: pixelmatch (+pngjs) — plain JS, ZERO native deps. Fits the
// "no native toolchain" constraint of a general npm tool (odiff is faster
// but ships platform binaries; do NOT use it — revisit only if E-scale
// wall-clock ever hurts). pixelmatch implements a YIQ perceptual-ish
// per-pixel color-distance threshold plus anti-aliasing-pixel detection, so
// AA'd edges (font hinting, corner rounding) don't get counted as diffs.
//
// Non-goal (plans/00-mission-and-decisions.md, Plan C non-goals): byte
// equality across machines is NOT the target — the perceptual threshold
// below is exactly what absorbs Linux-vs-macOS rasterization differences
// (evidence #14). This module's own determinism gate is narrower: the same
// PNG bytes in, the same diffRatio/pass out, every time (no randomness, no
// wall-clock-sensitive branches).
//
// -- Alignment policy (MEASURED, not guessed) --------------------------------
//
// The two capture paths use DIFFERENT box conventions and do not agree even
// on their own terms:
//
//   - Code side (src/visual/harness/capture.mjs): a Playwright ELEMENT
//     screenshot — bounds-TIGHT to the custom element's own box. No
//     manually-added padding (the harness's `#stage` div padding, 8px, is
//     there so shadows/focus rings aren't clipped by the STAGE, but the
//     screenshot itself locks to the element's bounding box, not the stage).
//   - Figma side (bridge `export-png`): NODE bounds. A component's node
//     bounds can include baked-in visual extent beyond its "logical" box —
//     e.g. a drop shadow on an elevated variant widens the node bounds.
//
// Measured 2026-07-10 (this task), all at deviceScaleFactor 2 (both capture
// paths pin 2x, so these are directly comparable pixel counts):
//
//   research/spikes/07-render-harness/btn-57994-2322.png            120x56   Figma export, Button (filled) set, "Type=Round, Size=Medium, State=Enabled"
//   research/spikes/07-render-harness/shots/button-filled-run1.png  134x80   Code render, m3e-button variant=filled (no explicit size attr)
//
// These two are NOT a same-state pair (the code shot never pinned `size`,
// so it isn't provably "Medium") — the point measured here is the BOX
// CONVENTION gap itself (code render taller/wider than the nominal Figma
// node for a broadly comparable button), not a same-state size delta. A
// production caller of this module (a future C-series runner driving both
// sides from the SAME correspondence state, task C2's driveState) would
// still hit this same gap even with size pinned identically, because the
// convention difference is structural, not a missing attribute.
//
// Confirming the gap is structural, not just code-vs-Figma: even
// Figma-export-vs-Figma-export sizes disagree with each other for the exact
// same state (Type=Round, Size=Medium, State=Enabled), across the five
// fused Button sibling sets (measured via `research/spikes/07-render-harness/btn-57994-*.png`):
//
//   btn-57994-2322.png  (Button, filled)            120x56
//   btn-57994-2262.png  (Button - text)              120x56
//   btn-57994-2282.png  (Button - outline)           120x56
//   btn-57994-2302.png  (Button - tonal)             120x56
//   btn-57994-2242.png  (Button - elevated)          136x72   <- elevation shadow widens node bounds
//
// Normalization chosen: pad BOTH images to the UNION box
// (max(widthA,widthB) x max(heightA,heightB)), CENTER each original image
// within that box, transparent fill (alpha 0) for the padding. Both capture
// paths already omit background (capture.mjs's `omitBackground: true`; the
// Figma bridge export is also alpha), so padding with alpha:0 never invents
// a visible edge or a false background-color mismatch. Padding (not
// scaling) is deliberate: scaling one image to match the other's dimensions
// would silently absorb a genuine size-only regression (e.g. a component
// that's rendering at the wrong scale) into "no diff" — exactly the failure
// mode this gate exists to catch.
//
// -- Threshold calibration ---------------------------------------------------
//
// profiles/m3-kit/visual.json: { "maxDiffRatio": 0.02, "pixelThreshold": 0.1 }
//
// *** CAVEAT — READ BEFORE TRUSTING THIS GATE IN PRODUCTION ***
// Every row in the calibration evidence (full table:
// profiles/m3-kit/README.md) is a PROXY, not the real comparison this gate
// performs:
//   - "same-pair" rows are code-vs-CODE (byte-identical Playwright renders
//     of the same element, re-captured).
//   - "cross-variant" rows are Figma-vs-FIGMA (different variant exports of
//     the same nominal state).
// NONE of the fixtures available at this task's time is a genuine
// code-vs-Figma pair for the SAME state — there is no "render m3e-button
// filled/Medium via Playwright" shot paired with "export that exact same
// state from Figma" in this fixture set yet. So `maxDiffRatio: 0.02` is
// validated only against these proxies; it has NOT been validated against
// the actual code-vs-Figma comparison the gate exists to make. Treat it as
// a PROVISIONAL starting value. Task C8 (live render + export, driving both
// sides from the same correspondence state) MUST re-verify maxDiffRatio
// against at least one genuine matched code-vs-Figma pair before this gate
// is trusted to fail a real CI build. See task-C8-brief.md Step 1/2.
//
// pixelThreshold is pixelmatch's own per-pixel YIQ color-distance threshold
// (0..1, smaller = more sensitive); maxDiffRatio is THIS module's ratio gate
// on (mismatched pixels / union-box pixel count).
//
// Summary of the (proxy-only) calibration evidence — full table, dims, and
// the pixelThreshold sensitivity sweep now live in profiles/m3-kit/README.md
// (the canonical record; do not re-duplicate it here). Measured
// 2026-07-10, all pairs union-box-aligned, pixelThreshold=0.1: the
// byte-identical code-vs-code "same-pair" rows scored diffRatio 0.0000
// (PASS); every Figma-vs-Figma cross-variant row scored diffRatio >= 0.0788
// (FAIL), a ~4x margin over maxDiffRatio=0.02 even on the closest pair
// (tonal vs elevated). See src/visual/diff.test.mjs for the executable
// version of the decisive rows.
//
// -- Result record ------------------------------------------------------------
//
// One JSON object per comparison, shape:
//   { entryId, stateId, pass, diffRatio, threshold, pixelThreshold,
//     artifacts: { code, figma, diff } }
// appended as one line to render-cache/results/<runId>.jsonl (gitignored);
// the diff PNG itself is written alongside under the same run's diffs/ dir.
// `threshold` is maxDiffRatio (the same unit as diffRatio, so the two are
// directly comparable at a glance); `pixelThreshold` is carried through too
// since it's the other calibration knob and cheap to keep for debugging.
import fs from "node:fs/promises";
import path from "node:path";
import { PNG } from "pngjs";
import pixelmatch from "pixelmatch";

// -- PNG I/O ------------------------------------------------------------------

// readPng(filePath) -> pngjs PNG (parsed: {width, height, data (RGBA Buffer)})
export async function readPng(filePath) {
  const buffer = await fs.readFile(filePath);
  return PNG.sync.read(buffer);
}

// -- Step 2: union-box alignment ----------------------------------------------
//
// unionAlign(pngA, pngB) -> { width, height, dataA, dataB }
//
// Pads both parsed PNGs to the union box (max width, max height of the
// pair), centering each original image within it (integer-floor offset —
// off-by-one on odd deltas always favors the top/left, which is
// deterministic and irrelevant at the sub-pixel level pixelmatch already
// operates at). Padding is transparent (RGBA all-zero, which is exactly
// what `Buffer.alloc` already produces — no explicit fill loop needed).
// Returns two same-size RGBA Buffers ready for pixelmatch; does not mutate
// pngA/pngB.
export function unionAlign(pngA, pngB) {
  const width = Math.max(pngA.width, pngB.width);
  const height = Math.max(pngA.height, pngB.height);

  const dataA = Buffer.alloc(width * height * 4);
  const dataB = Buffer.alloc(width * height * 4);

  center(pngA, dataA, width);
  center(pngB, dataB, width);

  return { width, height, dataA, dataB };
}

function center(png, dest, unionWidth) {
  const unionHeight = dest.length / (unionWidth * 4);
  const offsetX = Math.floor((unionWidth - png.width) / 2);
  const offsetY = Math.floor((unionHeight - png.height) / 2);
  for (let y = 0; y < png.height; y++) {
    const srcStart = y * png.width * 4;
    const dstStart = ((y + offsetY) * unionWidth + offsetX) * 4;
    png.data.copy(dest, dstStart, srcStart, srcStart + png.width * 4);
  }
}

// -- Step 1: the pixelmatch call -----------------------------------------------
//
// diffAligned(dataA, dataB, width, height, { pixelThreshold }) ->
//   { diffRatio, mismatchedPixels, totalPixels, diffPng }
//
// includeAA is deliberately left at pixelmatch's own default (false, i.e.
// anti-aliasing detection IS active — AA'd edge pixels are found and
// excluded from the mismatch count) since that's the exact "perceptual-ish"
// behavior this task's brief calls for.
export function diffAligned(dataA, dataB, width, height, { pixelThreshold = 0.1 } = {}) {
  const outData = Buffer.alloc(width * height * 4);
  const mismatchedPixels = pixelmatch(dataA, dataB, outData, width, height, {
    threshold: pixelThreshold,
  });
  const totalPixels = width * height;
  const diffPng = new PNG({ width, height });
  outData.copy(diffPng.data);
  return { diffRatio: mismatchedPixels / totalPixels, mismatchedPixels, totalPixels, diffPng };
}

// -- Step 1.5: scale normalization --------------------------------------------
//
// The code side renders at Playwright deviceScaleFactor 2 (a tight element box);
// the Figma export comes out at its own scale (in practice ~1x). A genuine
// matched button then diffs at ~0.70 purely because a 2x-resolution image is
// union-aligned onto a 1x one. normalizeScale downscales the LARGER image to the
// smaller's WIDTH, preserving its own aspect ratio (area-average / box filter),
// so pixels-per-logical-unit match before alignment. No-op when widths already
// match (never upscales — avoids inventing detail), so already-matched pairs are
// untouched and pure-scale differences collapse to ~0.
//
// Aspect differences survive on purpose: e.g. a Figma variant whose node bounds
// include a 48px touch-target frame the code tight-box lacks still shows a real
// residual diff after width-matching — that's a genuine node-bounds discrepancy,
// not a scale artifact.
export function resizeAreaAverage(png, targetW, targetH) {
  const { data: src, width: sw, height: sh } = png;
  const out = Buffer.alloc(targetW * targetH * 4);
  const xr = sw / targetW;
  const yr = sh / targetH;
  for (let dy = 0; dy < targetH; dy++) {
    const sy0 = dy * yr;
    const sy1 = (dy + 1) * yr;
    for (let dx = 0; dx < targetW; dx++) {
      const sx0 = dx * xr;
      const sx1 = (dx + 1) * xr;
      let r = 0;
      let g = 0;
      let b = 0;
      let aAcc = 0; // sum of (srcAlpha * areaWeight)
      let wsum = 0; // sum of areaWeight
      for (let sy = Math.floor(sy0); sy < Math.min(sh, Math.ceil(sy1)); sy++) {
        const wy = Math.min(sy1, sy + 1) - Math.max(sy0, sy);
        for (let sx = Math.floor(sx0); sx < Math.min(sw, Math.ceil(sx1)); sx++) {
          const wx = Math.min(sx1, sx + 1) - Math.max(sx0, sx);
          const w = wx * wy;
          const i = (sy * sw + sx) * 4;
          const pa = src[i + 3];
          const af = (pa / 255) * w; // premultiplied-alpha weight for color
          r += src[i] * af;
          g += src[i + 1] * af;
          b += src[i + 2] * af;
          aAcc += pa * w;
          wsum += w;
        }
      }
      const o = (dy * targetW + dx) * 4;
      const afsum = aAcc / 255; // sum of premultiplied-alpha weights
      if (afsum > 0) {
        out[o] = Math.round(r / afsum); // un-premultiply -> straight color
        out[o + 1] = Math.round(g / afsum);
        out[o + 2] = Math.round(b / afsum);
      }
      out[o + 3] = wsum > 0 ? Math.round(aAcc / wsum) : 0; // coverage-weighted alpha
    }
  }
  return { width: targetW, height: targetH, data: out };
}

// Only rescale for a GROSS scale factor (a deviceScaleFactor / export-scale
// mismatch — e.g. code at DPR 2 vs a 1x Figma export = ratio ~2.0). A small
// width ratio is a genuine proportion difference (e.g. the code renders an
// xsmall button ~5% wider than the Figma variant), and resampling it would
// distort the other axis and MANUFACTURE a mismatch — so leave sub-threshold
// pairs untouched and let unionAlign + the diff judge them honestly. With a
// correctly-scaled export (native 2x) this never fires; it's a safety net.
//
// SOUNDNESS CAP (2026-07-14): normalizeScale only fires within [MIN, MAX].
// Ratios above MAX (e.g. 8.75× list-item, 96× shape vs 1×1 Figma blank) are
// NOT a scale factor — they are a genuine bounds discrepancy (or a degenerate
// export). Downscaling them would collapse the comparison to a ~1px canvas
// and produce ~0 diff (FALSE PASS). Leave them unchanged; the raw size mismatch
// causes a large diff and the degenerate guard below catches the blank-export
// case explicitly.
export const SCALE_NORMALIZE_MIN_RATIO = 1.5;
export const SCALE_NORMALIZE_MAX_RATIO = 2.5;

export function normalizeScale(pngA, pngB) {
  const ratio = Math.max(pngA.width, pngB.width) / Math.min(pngA.width, pngB.width);
  if (ratio < SCALE_NORMALIZE_MIN_RATIO) return [pngA, pngB];
  if (ratio > SCALE_NORMALIZE_MAX_RATIO) return [pngA, pngB]; // gross mismatch — diff honestly
  const targetW = Math.min(pngA.width, pngB.width);
  const scaleOne = (png) => {
    if (png.width === targetW) return png;
    const targetH = Math.max(1, Math.round((png.height * targetW) / png.width));
    return resizeAreaAverage(png, targetW, targetH);
  };
  return [scaleOne(pngA), scaleOne(pngB)];
}

// -- Degenerate-comparison guard ----------------------------------------------
//
// A comparison is DEGENERATE when either trimmed side is blank (fully
// transparent — a failed render or a bad Figma export that produced no pixels)
// OR when either dimension is below a sanity minimum (catches 1×1 Figma
// exports: real components are always at least 8px on a side at any DPR).
//
// pixelmatch on a degenerate pair silently scores ~0 diff (FALSE PASS) because
// two transparent or near-empty canvases trivially match. The guard prevents
// the comparison from reaching pixelmatch at all and forces pass:false so the
// gate correctly flags the problem.
//
// Evidence (live gate runs, 2026-07-14):
//   shape:     code 96×96 vs figma 1×1   -> diffRatio 0.000, pass (FALSE)
//   snackbar:  code 688×96 vs figma 1×1  -> diffRatio 0.000, pass (FALSE)
//   list-item: code 64×112 vs figma 560×160 (ratio 8.75) -> 0.006, pass (FALSE)
export const DEGENERATE_MIN_DIMENSION = 8;

// isFullyTransparent(png) -> boolean. True iff every pixel has alpha === 0.
export function isFullyTransparent(png) {
  for (let i = 3; i < png.data.length; i += 4) {
    if (png.data[i] !== 0) return false;
  }
  return true;
}

// degenerateReason(trimA, trimB, labelA, labelB) -> string | null.
// Returns a human-readable reason string when the pair is degenerate; null when
// the pair is healthy and comparison should proceed.
export function degenerateReason(trimA, trimB, labelA = "A", labelB = "B") {
  const checks = [
    [trimA, labelA],
    [trimB, labelB],
  ];
  for (const [png, label] of checks) {
    if (isFullyTransparent(png)) {
      return `degenerate: ${label} ${png.width}x${png.height} is fully transparent (blank render or export)`;
    }
    if (png.width < DEGENERATE_MIN_DIMENSION || png.height < DEGENERATE_MIN_DIMENSION) {
      return `degenerate: ${label} ${png.width}x${png.height} is below minimum dimension ${DEGENERATE_MIN_DIMENSION}px`;
    }
  }
  return null;
}

// -- Step 1.4: transparent-margin trim ----------------------------------------
//
// Crop each PNG to the bounding box of its non-transparent pixels. Both sides
// omit background (transparent), but a Figma variant node's export bounds can
// include asymmetric transparent padding the code tight-box lacks — e.g. the
// xsmall/small button nodes carry a 48px min-touch-target frame around a shorter
// visible button. That padding is pure noise in a pixel diff; trimming it first
// aligns the two on actual content. alphaThreshold 0 = trim only fully
// transparent margins, so anti-aliased shadow fringes (alpha > 0) are preserved
// on BOTH sides. No-op (returns the input) when there's nothing to trim.
export function trimTransparent(png, alphaThreshold = 0) {
  const { data, width, height } = png;
  let minX = width;
  let minY = height;
  let maxX = -1;
  let maxY = -1;
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      if (data[(y * width + x) * 4 + 3] > alphaThreshold) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX < 0) return png; // fully transparent — nothing to trim
  const w = maxX - minX + 1;
  const h = maxY - minY + 1;
  if (w === width && h === height) return png;
  const out = Buffer.alloc(w * h * 4);
  for (let y = 0; y < h; y++) {
    const srcStart = ((y + minY) * width + minX) * 4;
    data.copy(out, y * w * 4, srcStart, srcStart + w * 4);
  }
  return { width: w, height: h, data: out };
}

// diffPngPair(pngA, pngB, opts) -> same shape as diffAligned, with an optional
// { degenerate: true, reason: string } extension when the pair fails the
// soundness guard. Pre-steps, in order:
//   1. trim transparent margins (content bbox)
//   2. degenerate guard (blank or sub-minimum side -> pass:false immediately,
//      ALWAYS fires first — scaleInvariant does NOT bypass this check)
//   3a. if scaleInvariant (opts.scaleInvariant === true): resize BOTH trimmed
//      images to a common normalized box (max(wA,wB) x max(hA,hB) via
//      resizeAreaAverage) so pure-scale differences (e.g. m3e-shape variant
//      whitespace padding) collapse to ~0 while shape-type mismatches
//      (circle vs square at the same normalized size) still diff high.
//   3b. otherwise: scale-normalize (match pixels-per-unit within [MIN,MAX] ratio band)
//   4. union-box align -> pixelmatch
// The one-call convenience used by comparePngFiles below and directly by unit
// tests that already hold parsed PNGs.
export function diffPngPair(pngA, pngB, opts) {
  const scaleInvariant = opts != null && opts.scaleInvariant === true;

  const trimA = trimTransparent(pngA);
  const trimB = trimTransparent(pngB);

  // Degenerate guard ALWAYS fires before any scale logic — scaleInvariant does
  // NOT bypass it. A blank/1x1 figma export must still fail even for
  // scale-invariant tags.
  const reason = degenerateReason(
    trimA, trimB,
    `code ${pngA.width}x${pngA.height}`,
    `figma ${pngB.width}x${pngB.height}`
  );
  if (reason !== null) {
    // Produce a 1x1 blank diffPng so callers that always write a diff artifact
    // can still do so without special-casing.
    const diffPng = new PNG({ width: 1, height: 1 });
    return {
      diffRatio: 1,
      mismatchedPixels: 1,
      totalPixels: 1,
      diffPng,
      degenerate: true,
      reason,
    };
  }

  if (scaleInvariant) {
    // Scale-invariant path: resize BOTH trimmed images to the same normalized
    // box (max(wA,wB) x max(hA,hB)). This collapses pure-scale differences
    // (m3e-shape whitespace padding differs per variant) while still catching
    // shape-type mismatches (a circle vs a clover at the same normalized size
    // still diffs high because their pixel interiors differ).
    const normW = Math.max(trimA.width, trimB.width);
    const normH = Math.max(trimA.height, trimB.height);
    const normA = resizeAreaAverage(trimA, normW, normH);
    const normB = resizeAreaAverage(trimB, normW, normH);
    // After resize both images are the same size, so unionAlign is a no-op pad.
    const { width, height, dataA, dataB } = unionAlign(normA, normB);
    return diffAligned(dataA, dataB, width, height, opts);
  }

  const [a, b] = normalizeScale(trimA, trimB);
  const { width, height, dataA, dataB } = unionAlign(a, b);
  return diffAligned(dataA, dataB, width, height, opts);
}

// -- Tiered thresholds --------------------------------------------------------
//
// Two named, tunable tolerance tiers for the pixel-diff pass/fail decision
// (2026-07-14). Both values come from visual.json (maxDiffRatio /
// maxDiffRatioText); these module-level consts are the DEFAULT fallback
// values used if the profile JSON ever lacks the key, and are exported so
// callers / tests can reference them symbolically rather than hard-coding 0.02
// or 0.10.
//
//   PIXEL_EXACT  (0.02) — icon- and shape-only components where the two sides
//                         must be nearly identical. The original calibrated
//                         value; cross-renderer AA on icon glyphs stays well
//                         under this.
//
//   TEXT_TIER    (0.10) — text-bearing components (badge, filter-chip,
//                         snackbar, …). Cross-renderer font antialiasing
//                         benignly pushes diffRatio to 0.05–0.09 even when
//                         renders are visually identical (measured 2026-07-14:
//                         filter-chip 0.058, badge 0.055). The relaxed tier
//                         absorbs this without loosening the icon/shape gate.
export const PIXEL_EXACT = 0.02;
export const TEXT_TIER = 0.10;

// isTextBearing(entry) -> boolean
//
// DETERMINISTIC tier classifier: a component is text-bearing when its
// correspondence entry has at least one prop with kind:"text". This is the
// exact signal that text content (badge label, chip label, snackbar message,
// …) is bound and rendered as real glyphs — the same signal drive.mjs uses
// to set `harnessParams.text` or a text slot (Step 2). No hardcoded list;
// no regex on tag names; the schema field itself decides.
//
// Tier resolution for the six reference components:
//   m3e-badge        props has "Badge label" kind:"text"          -> TEXT_TIER
//   m3e-filter-chip  props has "Label text"  kind:"text"          -> TEXT_TIER
//   m3e-snackbar     props has "Supporting text" kind:"text"      -> TEXT_TIER
//   m3e-switch       no kind:"text" prop (boolean icon axes only) -> PIXEL_EXACT
//   m3e-shape        no kind:"text" prop (geometry only)          -> PIXEL_EXACT
//   m3e-icon-button  no kind:"text" prop (icon slot, not text)    -> PIXEL_EXACT
export function isTextBearing(entry) {
  return Array.isArray(entry.props) && entry.props.some((p) => p.kind === "text");
}

// thresholdFor(entry, thresholds) -> number
//
// Returns the maxDiffRatio appropriate for this entry's tier:
//   text-bearing (kind:text prop OR cemTag in textTierTags)
//               -> thresholds.maxDiffRatioText (TEXT_TIER default)
//   pixel-exact -> thresholds.maxDiffRatio     (PIXEL_EXACT default)
//
// textTierTags (from visual.json) covers components that render real text via
// harness-injected slot content but have no kind:text prop (e.g. m3e-list-item).
// benignAaTags covers non-text components whose only cross-renderer delta is
// benign antialiasing — curved-shape edges and icon-FONT glyphs (e.g. m3e-fab:
// a filled rounded FAB whose Material Symbols glyph antialiases differently
// between Chromium and Figma, pushing diffRatio to ~0.09 with no structural
// mismatch). Same phenomenon and same 0.10 tier as textTierTags, just not
// literal text. isTextBearing (kind:text prop) is kept alongside both; any of
// the three promotes the entry to TEXT_TIER.
export function thresholdFor(entry, thresholds) {
  const textTierTags = Array.isArray(thresholds.textTierTags) ? thresholds.textTierTags : [];
  const benignAaTags = Array.isArray(thresholds.benignAaTags) ? thresholds.benignAaTags : [];
  const tag = entry != null && typeof entry.cemTag === "string" ? entry.cemTag : null;
  const promoted = isTextBearing(entry) || (tag != null && (textTierTags.includes(tag) || benignAaTags.includes(tag)));
  return promoted ? thresholds.maxDiffRatioText : thresholds.maxDiffRatio;
}

// -- Step 4: profile thresholds ------------------------------------------------
//
// loadThresholds(profileVisualJsonPath) ->
//   { maxDiffRatio, maxDiffRatioText, pixelThreshold,
//     scaleInvariantTags, textTierTags }
//
// maxDiffRatioText defaults to TEXT_TIER (0.10) when the profile JSON omits
// it, so profiles that haven't been updated yet are still valid.
// scaleInvariantTags defaults to [] when omitted (backward-compat).
// textTierTags defaults to [] when omitted (backward-compat).
export async function loadThresholds(profileVisualJsonPath) {
  const raw = await fs.readFile(profileVisualJsonPath, "utf8");
  const config = JSON.parse(raw);
  if (typeof config.maxDiffRatio !== "number" || typeof config.pixelThreshold !== "number") {
    throw new Error(
      `diff: ${profileVisualJsonPath} must have numeric "maxDiffRatio" and "pixelThreshold" fields, got ${raw}`
    );
  }
  const maxDiffRatioText =
    typeof config.maxDiffRatioText === "number" ? config.maxDiffRatioText : TEXT_TIER;
  const scaleInvariantTags = Array.isArray(config.scaleInvariantTags) ? config.scaleInvariantTags : [];
  const textTierTags = Array.isArray(config.textTierTags) ? config.textTierTags : [];
  const benignAaTags = Array.isArray(config.benignAaTags) ? config.benignAaTags : [];
  return {
    maxDiffRatio: config.maxDiffRatio,
    maxDiffRatioText,
    pixelThreshold: config.pixelThreshold,
    scaleInvariantTags,
    textTierTags,
    benignAaTags,
  };
}

// -- Step 3: the result record --------------------------------------------------
//
// comparePngFiles({ entryId, stateId, codePath, figmaPath, thresholds, entry? }) ->
//   { entryId, stateId, pass, diffRatio, threshold, pixelThreshold,
//     artifacts: { code, figma, diff: null }, diffPng }
//
// `entry` is the correspondence entry object; when supplied, the effective
// maxDiffRatio is chosen via thresholdFor (text-bearing or pixel-exact tier,
// including the textTierTags config override). The cemTag is also checked
// against thresholds.scaleInvariantTags to activate the scale-invariant
// comparison path in diffPngPair.
// When entry is omitted, thresholds.maxDiffRatio is used as-is (backward-compatible).
//
// Reads both files, aligns, diffs, and judges pass/fail against the resolved
// threshold. Does NOT write anything to disk itself — `artifacts.diff` is
// left null and `diffPng` (the in-memory pngjs PNG, not yet packed to a
// file) is returned alongside so a caller can decide WHERE to persist it
// (see writeResultRecord below, which is the one that actually writes
// render-cache/results/<run>.jsonl + the diff PNG file and fills in
// `artifacts.diff`). Keeping this function fs-write-free makes it trivially
// unit-testable without a run/cache-dir concept.
export async function comparePngFiles({ entryId, stateId, codePath, figmaPath, thresholds, entry }) {
  const [pngA, pngB] = await Promise.all([readPng(codePath), readPng(figmaPath)]);
  const scaleInvariantTags = Array.isArray(thresholds.scaleInvariantTags) ? thresholds.scaleInvariantTags : [];
  const scaleInvariant =
    entry != null &&
    typeof entry.cemTag === "string" &&
    scaleInvariantTags.includes(entry.cemTag);
  const pairResult = diffPngPair(pngA, pngB, {
    pixelThreshold: thresholds.pixelThreshold,
    scaleInvariant,
  });
  const { diffRatio, diffPng, degenerate, reason } = pairResult;
  const effectiveThreshold = entry != null ? thresholdFor(entry, thresholds) : thresholds.maxDiffRatio;
  const pass = diffRatio <= effectiveThreshold;

  return {
    entryId,
    stateId,
    pass,
    diffRatio,
    threshold: effectiveThreshold,
    pixelThreshold: thresholds.pixelThreshold,
    ...(degenerate != null ? { degenerate, reason } : {}),
    artifacts: { code: codePath, figma: figmaPath, diff: null },
    diffPng,
  };
}

// writeResultRecord(record, { cacheDir = "render-cache", runId }) ->
//   the same record, with artifacts.diff filled in and diffPng stripped,
//   after: (a) writing the diff PNG to
//   <cacheDir>/results/<runId>/diffs/<entryId>__<stateId>.png, and
//   (b) appending the JSON line (without the in-memory diffPng field — that
//   never belongs in the jsonl) to <cacheDir>/results/<runId>.jsonl.
// render-cache/ is already gitignored (see .gitignore) — no run output from
// this ever lands in git.
export async function writeResultRecord(record, { cacheDir = "render-cache", runId }) {
  if (!runId) throw new Error("writeResultRecord: runId is required");

  const resultsDir = path.join(cacheDir, "results");
  const diffsDir = path.join(resultsDir, runId, "diffs");
  await fs.mkdir(diffsDir, { recursive: true });

  const safeName = `${record.entryId}__${record.stateId}`.replace(/[^a-zA-Z0-9_.-]/g, "_");
  const diffPath = path.join(diffsDir, `${safeName}.png`);
  await fs.writeFile(diffPath, PNG.sync.write(record.diffPng));

  const { diffPng, ...withoutPng } = record;
  const finalRecord = { ...withoutPng, artifacts: { ...withoutPng.artifacts, diff: diffPath } };

  const jsonlPath = path.join(resultsDir, `${runId}.jsonl`);
  await fs.appendFile(jsonlPath, `${JSON.stringify(finalRecord)}\n`);

  return finalRecord;
}

// -- CLI mode -------------------------------------------------------------
// One comparison per process invocation, mirroring capture.mjs's own CLI
// convention:
//   node diff.mjs --code=<path> --figma=<path> --profile=m3-kit \
//     --entryId=m3e-button --stateId=filled-medium [--runId=<run>]
function parseCliArgs(argv) {
  const args = { profile: "m3-kit" };
  for (const arg of argv) {
    const eq = arg.indexOf("=");
    if (!arg.startsWith("--") || eq === -1) continue;
    args[arg.slice(2, eq)] = arg.slice(eq + 1);
  }
  for (const required of ["code", "figma", "entryId", "stateId"]) {
    if (!args[required]) throw new Error(`diff.mjs CLI: --${required}=<value> is required`);
  }
  return args;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const { code, figma, profile, entryId, stateId, runId } = parseCliArgs(process.argv.slice(2));
  const thresholds = await loadThresholds(path.join("profiles", profile, "visual.json"));
  const record = await comparePngFiles({ entryId, stateId, codePath: code, figmaPath: figma, thresholds });
  if (runId) {
    const written = await writeResultRecord(record, { runId });
    console.log(JSON.stringify(written, null, 2));
  } else {
    const { diffPng, ...withoutPng } = record;
    console.log(JSON.stringify(withoutPng, null, 2));
  }
  if (!record.pass) process.exitCode = 1;
}
