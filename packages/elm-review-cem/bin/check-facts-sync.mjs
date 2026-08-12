#!/usr/bin/env node
// Facts sync check (issue #42).
//
// The `Cem.Facts` module (the Fact/Facet types) is OWNED by elm-cem — its
// canonical source lives at `elm-cem/facts/src/Cem/Facts.elm`, the source dir of
// the zero-dep `jackhp95/elm-cem-facts` package. elm-review-cem is itself an Elm
// PACKAGE, so it cannot depend on that package until it is registry-published
// (the family-wide "packages depend only on published packages" wall). Until the
// Stage-F cutover (issue #48 stamps the published dependency and this repo drops
// its own `Cem.Facts` from src/ + exposed-modules), we keep a BYTE-SYNCED copy at
// `src/Cem/Facts.elm` so `npm test`, `elm-review`, and `elm make --docs` stay
// green.
//
// This check fails if that copy has drifted from the canonical source. It locates
// the canonical file at `../elm-cem/facts/src/Cem/Facts.elm` (the repos are
// checked out side-by-side), or at $CEM_FACTS_CANONICAL if set. If the canonical
// file cannot be found (e.g. an isolated CI clone with no sibling elm-cem), it
// SKIPS with a warning rather than failing — the drift guard only bites where the
// source of truth is actually reachable.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const copyPath = path.join(repoRoot, "src", "Cem", "Facts.elm");

const canonicalPath = process.env.CEM_FACTS_CANONICAL
  ? path.resolve(process.env.CEM_FACTS_CANONICAL)
  : path.resolve(repoRoot, "..", "elm-cem", "facts", "src", "Cem", "Facts.elm");

if (!fs.existsSync(copyPath)) {
  console.error(`facts-sync: FAIL — expected a local copy at ${copyPath}, but it is missing.`);
  process.exit(1);
}

if (!fs.existsSync(canonicalPath)) {
  console.warn(
    `facts-sync: SKIP — canonical source not found at ${canonicalPath}.\n` +
      `  Set CEM_FACTS_CANONICAL or check out jackhp95/elm-cem beside this repo to enable the drift guard.`,
  );
  process.exit(0);
}

const copy = fs.readFileSync(copyPath, "utf8");
const canonical = fs.readFileSync(canonicalPath, "utf8");

if (copy !== canonical) {
  console.error(
    `facts-sync: FAIL — src/Cem/Facts.elm has DRIFTED from the canonical source.\n` +
      `  canonical: ${canonicalPath}\n` +
      `  local:     ${copyPath}\n` +
      `  Re-sync with:  cp "${canonicalPath}" "${copyPath}"\n` +
      `  (elm-cem owns this type; edit it there, then re-sync here.)`,
  );
  process.exit(1);
}

console.log(`facts-sync: OK — src/Cem/Facts.elm is byte-identical to ${canonicalPath}`);
