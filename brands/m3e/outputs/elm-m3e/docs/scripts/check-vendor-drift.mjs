#!/usr/bin/env node
// check-vendor-drift.mjs — fail when a committed vendor copy no longer matches
// its source.
//
// WHY THIS EXISTS
//   docs/vendor/elm-foundation/ is a committed COPY of HtmlIr.* and TypedHtml.*
//   pulled from the unpublished sibling repos by `gen:vendor-foundation`
//   (scripts/vendor-foundation.mjs) — see that file for the full rationale.
//   docs/vendor/tailwind-m3e-web/ is a committed COPY of the co-located
//   tailwind-m3e-web package's CSS @import graph, pulled by
//   `gen:vendor-tailwind` (scripts/vendor-tailwind-m3e-web.mjs) — vendored so
//   the standalone published mirror repo (which lacks that sibling package)
//   can still build. `check:drift` (check-data-drift.mjs) only compares
//   elm-m3e's OWN generated artifacts against a fresh regen; it says nothing
//   about whether either vendored COPY still matches the sibling SOURCE it
//   was copied from.
//
//   That gap let a real bug through: an uncommitted config edit in elm-typed-html
//   was lost, while elm-m3e's vendored copy had already been refreshed from it.
//   elm-m3e kept compiling against TypedHtml.Aria.hidden — a setter its own
//   (reverted) source no longer produced — and the next `gen:vendor` would have
//   broken the build. Nothing caught the mismatch beforehand.
//
// HOW
//   For each vendor dir, re-run the same copy its vendor-*.mjs script performs
//   — via its exported `copy*Into` fn, not a reimplementation of the file list
//   — into a scratch temp dir, never in place (same reasoning as
//   check-data-drift.mjs: in place would defeat the point), then byte-compare
//   + set-compare against the committed copy. Hand-authored markers a copy fn
//   never writes (e.g. elm-foundation's VENDORED_FROM.txt) are excluded.
//
// PRECONDITION: the sibling repos/packages (elm-html-intermediate-representation,
//   elm-typed-html, tailwind-m3e-web) must be checked out next to elm-m3e, or
//   the matching *_SRC env var set — the same precondition `gen:vendor` has. A
//   missing sibling fails loud rather than silently reporting "no drift".

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { copyFoundationInto, PRESERVED_MARKER } from "./vendor-foundation.mjs";
import { copyTailwindM3eWebInto } from "./vendor-tailwind-m3e-web.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const DOCS = path.resolve(here, "..");

function fail(msg) {
  console.error(`check:vendor: ${msg}`);
  process.exit(1);
}

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

/**
 * Re-run `copyInto` into a scratch temp dir (never in place), then compare
 * against the committed `vendorDir`. Entries in `preserved` are hand-authored
 * markers the copy fn never writes, so they're excluded from the comparison.
 */
function checkVendor(label, vendorDir, copyInto, preserved = []) {
  const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "m3e-vendor-drift-"));
  try {
    copyInto(scratch);
  } catch (err) {
    fail(`could not re-vendor ${label} into a scratch dir for comparison:\n${err.message}`);
  }

  const committed = tree(vendorDir).filter((rel) => !preserved.includes(rel));
  const fresh = tree(scratch);

  const drifted = [];
  for (const rel of new Set([...committed, ...fresh])) {
    const a = path.join(vendorDir, rel);
    const b = path.join(scratch, rel);
    if (!fs.existsSync(a) || !fs.existsSync(b) || !fs.readFileSync(a).equals(fs.readFileSync(b))) {
      drifted.push(rel);
    }
  }

  fs.rmSync(scratch, { recursive: true, force: true });

  if (drifted.length) {
    const relVendorDir = path.relative(DOCS, vendorDir);
    console.error(`check:vendor: FAIL — docs/${relVendorDir}/ no longer matches its source:`);
    for (const d of drifted) console.error(`  docs/${relVendorDir}/${d}`);
    console.error("");
    console.error("Run `npm run gen:vendor` (from the repo root) and commit the result.");
    process.exit(1);
  }

  console.log(`check:vendor: OK — ${label}: ${fresh.length} vendored file(s) match a fresh copy from source.`);
}

checkVendor("elm-foundation", path.join(DOCS, "vendor", "elm-foundation"), copyFoundationInto, [
  PRESERVED_MARKER,
]);
checkVendor("tailwind-m3e-web", path.join(DOCS, "vendor", "tailwind-m3e-web"), copyTailwindM3eWebInto);
