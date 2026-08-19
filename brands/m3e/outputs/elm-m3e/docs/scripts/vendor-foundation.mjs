#!/usr/bin/env node
// Re-vendor the unpublished foundation Elm source (HtmlIr.* + TypedHtml.*) into
// docs/vendor/elm-foundation, which is a committed source-directory in docs/elm.json.
//
// WHY THIS EXISTS
//   The docs app imports M3e.* (from ../src), which depends on HtmlIr.*, and the
//   Examples/Guide routes also import TypedHtml.Attributes / TypedHtml.Aria. Both
//   HtmlIr and TypedHtml are UNPUBLISHED sibling repos, so they can't be package
//   deps yet. Netlify clones only elm-m3e, so the old `../../elm-*/src` source-dirs
//   didn't exist on CI. We vendor a committed copy instead; CI compiles against it.
//
// WHEN TO RUN
//   After changing HtmlIr or TypedHtml in the sibling repos, run:
//     pnpm run build:vendor
//   then commit the refreshed docs/vendor/elm-foundation. The COMMITTED copy is
//   what CI uses — this script is a local-dev sync convenience, never run on CI.
//
// The sibling repos are expected next to elm-m3e (../../ from docs/):
//   ../../elm-html-intermediate-representation
//   ../../elm-typed-html
// Override with env vars HTMLIR_SRC / TYPEDHTML_SRC if they live elsewhere.
//
// The copy logic below (`copyFoundationInto`) is exported so `check:vendor`
// (scripts/check-vendor-drift.mjs) can re-run the exact same copy into a scratch
// dir and diff it against the committed one, instead of reimplementing the file
// list. Importing this module never copies anything by itself — only running it
// as a script (`node vendor-foundation.mjs`) does.

import { cpSync, rmSync, mkdirSync, existsSync, readdirSync, statSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url)); // docs/scripts
const docsDir = resolve(here, "..");
const vendorDir = join(docsDir, "vendor", "elm-foundation");

export const htmlIrSrc =
  process.env.HTMLIR_SRC ??
  resolve(docsDir, "..", "..", "..", "..", "..", "core", "elm-html-intermediate-representation", "src");
export const typedHtmlSrc =
  process.env.TYPEDHTML_SRC ?? resolve(docsDir, "..", "..", "..", "..", "..", "core", "elm-typed-html", "src");

// The entries this script owns inside a vendor dir: deleted and recopied fresh
// on every run so upstream deletions propagate. Anything else in the vendor dir
// (namely the hand-authored VENDORED_FROM.txt marker) is left untouched.
export const MANAGED_ENTRIES = ["HtmlIr", "TypedHtml", "TypedHtml.elm"];

// Hand-authored marker committed alongside the copy; never written by
// `copyFoundationInto`, so drift-checking against a fresh copy must exclude it.
export const PRESERVED_MARKER = "VENDORED_FROM.txt";

/**
 * Copy HtmlIr.* + TypedHtml.* from the sibling sources into `targetDir`, exactly
 * as the CLI below does for docs/vendor/elm-foundation. Throws (does not
 * process.exit) on a missing source, so callers — the check:vendor scratch-dir
 * comparison included — can handle the failure themselves.
 */
export function copyFoundationInto(
  targetDir,
  { htmlIrSrc: hi = htmlIrSrc, typedHtmlSrc: th = typedHtmlSrc } = {},
) {
  for (const [label, dir] of [
    ["HtmlIr", hi],
    ["TypedHtml", th],
  ]) {
    if (!existsSync(dir)) {
      throw new Error(
        `${label} source not found at ${dir}\n` +
          `  Clone the sibling repo next to elm-m3e, or set ${label === "HtmlIr" ? "HTMLIR_SRC" : "TYPEDHTML_SRC"}.`,
      );
    }
  }

  // Fresh module trees every run so deletions upstream propagate, but keep the
  // hand-authored VENDORED_FROM.txt marker that also lives in this dir.
  mkdirSync(targetDir, { recursive: true });
  for (const stale of MANAGED_ENTRIES) {
    rmSync(join(targetDir, stale), { recursive: true, force: true });
  }

  // HtmlIr: whole HtmlIr/ package tree.
  cpSync(join(hi, "HtmlIr"), join(targetDir, "HtmlIr"), { recursive: true });

  // TypedHtml: the top-level module + the TypedHtml/ tree, but EXCLUDE
  // TypedHtml/Review/* — those are elm-review rule facts that import Cem.Facts
  // (an elm-review-only module the docs don't depend on) and are unexposed +
  // unimported, so vendoring them would add an unresolvable import to a compiled
  // source-directory.
  cpSync(join(th, "TypedHtml.elm"), join(targetDir, "TypedHtml.elm"));
  cpSync(join(th, "TypedHtml"), join(targetDir, "TypedHtml"), {
    recursive: true,
    filter: (src) => {
      const rel = src.slice(join(th, "TypedHtml").length);
      return !rel.startsWith("/Review");
    },
  });
}

function fail(msg) {
  console.error(`vendor-foundation: ${msg}`);
  process.exit(1);
}

function countElm(dir) {
  let n = 0;
  for (const entry of readdirSync(dir)) {
    const p = join(dir, entry);
    if (statSync(p).isDirectory()) n += countElm(p);
    else if (entry.endsWith(".elm")) n += 1;
  }
  return n;
}

function main() {
  try {
    copyFoundationInto(vendorDir);
  } catch (err) {
    fail(err.message);
  }

  console.log(
    `vendor-foundation: refreshed ${vendorDir}\n` +
      `  from HtmlIr:    ${htmlIrSrc}\n` +
      `  from TypedHtml: ${typedHtmlSrc}\n` +
      `  ${countElm(vendorDir)} .elm modules vendored.`,
  );
}

// Only run as a script — importing this module (e.g. from check-vendor-drift.mjs)
// must never mutate docs/vendor/elm-foundation as a side effect.
if (fileURLToPath(import.meta.url) === process.argv[1]) {
  main();
}
