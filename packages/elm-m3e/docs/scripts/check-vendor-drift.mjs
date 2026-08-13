#!/usr/bin/env node
// check-vendor-drift.mjs — fail when the committed vendor copy no longer matches
// its source.
//
// WHY THIS EXISTS
//   docs/vendor/elm-foundation/ is a committed COPY of HtmlIr.* and TypedHtml.*
//   pulled from the unpublished sibling repos by `gen:vendor`
//   (scripts/vendor-foundation.mjs) — see that file for the full rationale.
//   `check:drift` (check-data-drift.mjs) only compares elm-m3e's OWN generated
//   artifacts against a fresh regen; it says nothing about whether the vendored
//   COPY still matches the sibling SOURCE it was copied from.
//
//   That gap let a real bug through: an uncommitted config edit in elm-typed-html
//   was lost, while elm-m3e's vendored copy had already been refreshed from it.
//   elm-m3e kept compiling against TypedHtml.Aria.hidden — a setter its own
//   (reverted) source no longer produced — and the next `gen:vendor` would have
//   broken the build. Nothing caught the mismatch beforehand.
//
// HOW
//   Re-run the same copy vendor-foundation.mjs performs — via its exported
//   `copyFoundationInto`, not a reimplementation of the file list — into a
//   scratch temp dir, never in place (same reasoning as check-data-drift.mjs:
//   in place would defeat the point), then byte-compare + set-compare against
//   the committed docs/vendor/elm-foundation/. VENDORED_FROM.txt is
//   hand-authored and outside the copy (vendor-foundation.mjs never writes it),
//   so it is excluded from the comparison.
//
// PRECONDITION: the sibling repos (elm-html-intermediate-representation,
//   elm-typed-html) must be checked out next to elm-m3e, or HTMLIR_SRC /
//   TYPEDHTML_SRC set — the same precondition `gen:vendor` has. A missing
//   sibling fails loud rather than silently reporting "no drift".

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { copyFoundationInto, PRESERVED_MARKER } from "./vendor-foundation.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const DOCS = path.resolve(here, "..");
const VENDOR_DIR = path.join(DOCS, "vendor", "elm-foundation");

function fail(msg) {
  console.error(`check:vendor: ${msg}`);
  process.exit(1);
}

// Work in a scratch copy so this check can never mutate the committed vendor dir.
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "m3e-vendor-drift-"));
process.on("exit", () => fs.rmSync(scratch, { recursive: true, force: true }));

try {
  copyFoundationInto(scratch);
} catch (err) {
  fail(`could not re-vendor into a scratch dir for comparison:\n${err.message}`);
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

const committed = tree(VENDOR_DIR).filter((rel) => rel !== PRESERVED_MARKER);
const fresh = tree(scratch);

const drifted = [];
for (const rel of new Set([...committed, ...fresh])) {
  const a = path.join(VENDOR_DIR, rel);
  const b = path.join(scratch, rel);
  if (!fs.existsSync(a) || !fs.existsSync(b) || !fs.readFileSync(a).equals(fs.readFileSync(b))) {
    drifted.push(rel);
  }
}

if (drifted.length) {
  console.error("check:vendor: FAIL — docs/vendor/elm-foundation/ no longer matches its source:");
  for (const d of drifted) console.error(`  docs/vendor/elm-foundation/${d}`);
  console.error("");
  console.error("Run `npm run gen:vendor` (from the repo root) and commit the result.");
  process.exit(1);
}

console.log(`check:vendor: OK — ${fresh.length} vendored file(s) match a fresh copy from source.`);
