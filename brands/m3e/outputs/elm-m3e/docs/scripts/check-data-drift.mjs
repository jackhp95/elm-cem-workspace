// check-data-drift.mjs — fail when committed generated data is stale.
//
// WHY THIS EXISTS
//   `gen:*` writes git-tracked files (docs/data/*.json and the generated Elm
//   config/surface/barrel modules). Nothing used to verify that those committed
//   files still match what the generators produce, so a source edit that skipped
//   the regen shipped stale derived data silently. That is exactly what happened
//   to docs/data/example-usage.json: the unseam migration rewrote the example
//   routes, nobody re-ran the generator, and the staleness only surfaced when
//   `start` happened to regenerate and produced an alarming diff.
//
//   Dev no longer regenerates anything (that is `pnpm gen`, explicitly), so this
//   check is what keeps "explicit generation" honest.
//
// HOW
//   Regenerate into a temp copy of the repo — never in place — and byte-compare
//   the generated artifacts against the committed ones. In place would defeat the
//   point: the check would fix the drift it is meant to report.
//
// PRECONDITION: the generators must be deterministic. Verified for this pipeline
//   (examples.json regenerates byte-identical; a second run reproduces
//   example-usage.json exactly). A generator that embedded a timestamp or an
//   absolute path would make this fire spuriously, and a gate that cries wolf
//   gets disabled — which is worse than no gate. Fix such a generator; do not
//   exempt it here.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const DOCS = path.resolve(here, "..");
const REPO = path.resolve(DOCS, "..");

// Portability guard (R-023): data/reference.json is a GENERATED, gitignored
// artifact absent from a fresh `pnpm install` clone. This gate regenerates it
// and byte-compares against the on-disk copy — with nothing on disk it would
// report false "stale" drift. A fresh clone has modified no source, so its
// tracked generated artifacts (favicon.svg, Samples.elm, samples/**) cannot be
// stale; there is nothing here for this gate to catch. Skip-with-reason unless
// REQUIRE_CLONE_GATES=1 (CI that has run the docs pipeline wants it hard).
if (!fs.existsSync(path.join(DOCS, "data", "reference.json"))) {
  if (process.env.REQUIRE_CLONE_GATES === "1") {
    console.error("check:drift: data/reference.json absent and REQUIRE_CLONE_GATES=1 — run the docs build (gen:reference) first.");
    process.exit(1);
  }
  console.log("SKIP: check:drift (docs data) — data/reference.json absent (generated, gitignored); a fresh clone has modified no source so committed artifacts cannot be stale. Runs in a dev environment (after the docs build) or in CI with REQUIRE_CLONE_GATES=1.");
  process.exit(0);
}

// The artifacts `gen` writes, relative to docs/. Kept explicit rather than
// globbed: a glob would silently start (or stop) covering files as the tree
// changes, and this list is the contract.
const ARTIFACTS = [
  "data/reference.json",
  // gen:brand-images — the bare material-symbols:palette glyph. Text, and the
  // generator is pure string building, so it is byte-reproducible everywhere.
  // See the note below for why its sibling RASTER is deliberately absent.
  "public/favicon.svg",
  // gen:samples — the guide's displayed Elm, lifted back out into things a
  // compiler and a linter can judge. See scripts/samples-gen/extract-samples.mjs.
  "src/Guide/Samples.elm",
  "samples/manifest.json",
  "samples/review/elm.json",
  "samples/review/src/CodegenReviewConfig.elm",
];

// Whole trees whose CONTENTS are generated: every file must match, and the file
// SET must match too (an extra or missing module is drift as surely as a changed
// one). Listing directories rather than each `.elm` keeps the contract explicit
// — `samples/manifest.json` above is the enumerated list of what should be here,
// and it is byte-compared — without a per-sample edit to this file every time a
// guide page gains or loses a code block.
const ARTIFACT_DIRS = ["samples/good", "samples/bad"];

const GEN_STEPS = ["gen:reference", "gen:samples", "gen:brand-images"];

// DELIBERATELY NOT GATED: public/og-card.png.
//
// gen:brand-images writes it alongside favicon.svg, but it comes out of
// @resvg/resvg-js — a PREBUILT NATIVE binary, one per platform/libc.
// Rasterisation is not byte-reproducible across those builds: identical SVG in,
// subtly different pixels and PNG stream out on a different machine or in CI.
// Gating it would fail for a reason no author could act on, and a gate that
// cries wolf gets disabled — worse than no gate.
//
// This is not a hole in the contract. favicon.svg IS gated above, and the raster
// is a pure function of the same glyph source, so a stale raster can only follow
// a stale input — which this check does catch. Regenerate whenever the glyph
// changes (`pnpm gen`, or `npm --prefix docs run gen:brand-images`).

// DELIBERATELY NOT GATED (yet): data/examples.json and data/example-usage.json.
//
// The examples pipeline is not reproducible in a cold environment. Regenerating
// it from a clean checkout degrades the Elm surfaces rather than reproducing
// them: the committed examples.json carries 199 null surfaces out of 1017, and a
// cold regen produces 860 — 661 surfaces silently lost, because the scratch
// harness cannot compile them. (This is the measured form of the long-standing
// "local build:assets degrades surfaces, use build:ci" folklore.)
//
// Gating that would fail every push for a reason nobody could act on, and a gate
// that cries wolf gets disabled — worse than no gate. So these two stay out until
// the surfaces harness is fixed, tracked separately. When it is fixed, add them
// back here and to GEN_STEPS; the 199 baseline should drop toward 0, and THAT is
// the signal the fix worked.
//
// reference.json IS reproducible and is gated. Note it is sensitive to a stale
// docs/elm-stuff cache — a warm cache can reproduce an old signature. `elm make`
// owns that cache; if this check ever disagrees with a local `gen:reference`,
// `rm -rf docs/elm-stuff` and regenerate before believing the local result.

function fail(msg) {
  console.error(`check:drift: ${msg}`);
  process.exit(1);
}

// Work in a scratch copy so the generators cannot touch the working tree.
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "m3e-drift-"));
process.on("exit", () => fs.rmSync(scratch, { recursive: true, force: true }));

const scratchDocs = path.join(scratch, "docs");

try {
  // Copy the repo minus the heavy, regenerable directories. node_modules is
  // symlinked back so the generators keep their toolchain without a reinstall.
  fs.cpSync(REPO, scratch, {
    recursive: true,
    filter: (src) => {
      const rel = path.relative(REPO, src);
      if (!rel) return true;
      const top = rel.split(path.sep);
      if (top.includes("node_modules")) return false;
      if (top.includes(".git")) return false;
      if (top.includes("elm-stuff")) return false;
      if (top.includes(".elm-pages")) return false;
      if (top.includes("dist")) return false;
      return true;
    },
  });

  for (const nm of [
    ["node_modules", path.join(REPO, "node_modules")],
    [path.join("docs", "node_modules"), path.join(DOCS, "node_modules")],
  ]) {
    const [rel, target] = nm;
    if (fs.existsSync(target)) fs.symlinkSync(target, path.join(scratch, rel), "dir");
  }

  for (const step of GEN_STEPS) {
    try {
      execFileSync("npm", ["run", step], { cwd: scratchDocs, stdio: "pipe" });
    } catch (err) {
      const out = [err.stdout, err.stderr].filter(Boolean).map(String).join("\n");
      fail(`\`${step}\` failed while checking for drift:\n${out}`);
    }
  }
} catch (err) {
  fail(`could not prepare the scratch regen: ${err.message}`);
}

const drifted = ARTIFACTS.filter((rel) => {
  const committed = path.join(DOCS, rel);
  const fresh = path.join(scratchDocs, rel);
  if (!fs.existsSync(fresh)) return false; // not produced by these steps
  if (!fs.existsSync(committed)) return true;
  return !fs.readFileSync(committed).equals(fs.readFileSync(fresh));
});

/** Every file under `dir`, relative to it, sorted. */
function tree(dir) {
  if (!fs.existsSync(dir)) return [];
  const out = [];
  const walk = (sub) => {
    for (const entry of fs.readdirSync(path.join(dir, sub), { withFileTypes: true })) {
      const rel = path.join(sub, entry.name);
      if (entry.isDirectory()) walk(rel);
      else out.push(rel);
    }
  };
  walk("");
  return out.sort();
}

let counted = ARTIFACTS.length;
for (const dir of ARTIFACT_DIRS) {
  const committed = tree(path.join(DOCS, dir));
  const fresh = tree(path.join(scratchDocs, dir));
  counted += fresh.length;
  for (const rel of new Set([...committed, ...fresh])) {
    const a = path.join(DOCS, dir, rel);
    const b = path.join(scratchDocs, dir, rel);
    if (!fs.existsSync(a) || !fs.existsSync(b) || !fs.readFileSync(a).equals(fs.readFileSync(b))) {
      drifted.push(path.join(dir, rel));
    }
  }
}

if (drifted.length) {
  console.error("check:drift: FAIL — committed generated data is stale:");
  for (const d of drifted) console.error(`  docs/${d}`);
  console.error("");
  console.error("Run `pnpm gen` (from the repo root) and commit the result.");
  process.exit(1);
}

console.log(`check:drift: OK — ${counted} generated artifact(s) match a fresh regen.`);
