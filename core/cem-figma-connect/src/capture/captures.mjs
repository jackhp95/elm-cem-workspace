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
