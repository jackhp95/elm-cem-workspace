#!/usr/bin/env node
// rename-namespaces.mjs — atomic single-pass consumer migration for the
// elm-cem module-namespace rename (reconciliation Task 7b / Step 7.5, D-R5).
//
// The rename shifts every family tier down one name:
//
//     OLD prefix            NEW prefix
//     ------------------    ------------------
//     M3e.Component.    ->  M3e.Element.
//     M3e.Family.       ->  M3e.Component.
//     TypedHtml.Component.  ->  TypedHtml.Element.
//
// THE ATOMICITY RULE (D-R5, non-negotiable):
//   The map MUST be applied in ONE traversal per file, computed from the SAME
//   original string. A naive sequential rename — first `M3e.Component.` ->
//   `M3e.Element.`, THEN `M3e.Family.` -> `M3e.Component.` — would re-capture
//   the `M3e.Component.` tokens FRESHLY WRITTEN by the second pass and wrongly
//   push them on to `M3e.Element.`, silently corrupting every family reference.
//   We defeat this by building a single alternation regex over ALL old prefixes
//   and replacing via a map lookup inside ONE String.prototype.replace call.
//   JS `replace` scans the ORIGINAL string left-to-right and never re-examines
//   text it has already emitted, so a match produced by the replacer can never
//   be re-matched. That is the whole correctness argument.
//
// Usage:
//   node rename-namespaces.mjs <target-dir> [<target-dir> ...]   # apply in place
//   node rename-namespaces.mjs --dry <target-dir> ...            # report only
//   node rename-namespaces.mjs --selftest                        # run unit tests
//
// Only `.elm` files are touched. External consumers of the published elm-m3e
// package can run this over their own source tree to migrate; see
// PACKAGES-MOVED.md / README.md.

import fs from "node:fs";
import path from "node:path";

// --- the map: the single source of truth for the rename -------------------
// Order in this object is irrelevant to correctness because we apply all
// alternatives in ONE pass; longer/overlapping prefixes are handled by regex
// alternation being greedy per-position, and these three prefixes do not
// prefix one another, so there is no ambiguity.
export const RENAME_MAP = {
  "M3e.Component.": "M3e.Element.",
  "M3e.Family.": "M3e.Component.",
  "TypedHtml.Component.": "TypedHtml.Element.",
};

// Build ONE alternation regex from the map keys. Escape regex metachars (the
// dots) so `M3e.Component.` only matches the literal dotted prefix, never
// `M3eXComponentY`. We sort keys longest-first so that if two keys ever shared
// a prefix the more specific one wins; harmless for the current map.
function buildReplacer(map) {
  const keys = Object.keys(map).sort((a, b) => b.length - a.length);
  const escaped = keys.map((k) => k.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
  const re = new RegExp(escaped.join("|"), "g");
  // ONE traversal: replace scans the ORIGINAL string; the returned value for a
  // match is emitted into the output and never re-scanned. No self-recapture.
  return (source) => source.replace(re, (matched) => map[matched]);
}

const applyRename = buildReplacer(RENAME_MAP);
export { applyRename };

// --- filesystem walk -------------------------------------------------------
function* walkElm(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      // skip build/output dirs that never hold hand-written consumers
      if (entry.name === "elm-stuff" || entry.name === "node_modules" || entry.name === "dist" || entry.name === "dist-packages") continue;
      yield* walkElm(full);
    } else if (entry.isFile() && entry.name.endsWith(".elm")) {
      yield full;
    }
  }
}

function migrateFile(file, { dry }) {
  const before = fs.readFileSync(file, "utf8");
  const after = applyRename(before);
  if (after === before) return { file, changed: false };
  if (!dry) fs.writeFileSync(file, after);
  return { file, changed: true };
}

function migrateDirs(dirs, { dry }) {
  let changed = 0;
  let scanned = 0;
  const changedFiles = [];
  for (const dir of dirs) {
    if (!fs.existsSync(dir)) {
      console.error(`rename-namespaces: skip (missing) ${dir}`);
      continue;
    }
    for (const file of walkElm(dir)) {
      scanned++;
      const r = migrateFile(file, { dry });
      if (r.changed) {
        changed++;
        changedFiles.push(file);
      }
    }
  }
  return { changed, scanned, changedFiles };
}

// --- unit tests: prove atomicity ------------------------------------------
// The decisive test is the "fast+slow interleaved" one: a single string that
// mixes `M3e.Component.` (would be written by the FIRST sequential pass) and
// `M3e.Family.` (would produce a fresh `M3e.Component.` in a SECOND sequential
// pass). Under a correct single pass, the ORIGINAL `M3e.Component.` becomes
// `M3e.Element.` and the ORIGINAL `M3e.Family.` becomes `M3e.Component.` — and
// crucially that new `M3e.Component.` is NOT pushed on to `M3e.Element.`.
function selftest() {
  const cases = [
    {
      name: "self-recapture hazard (Family adjacent to Component)",
      input:
        "import M3e.Component.Button as B\nimport M3e.Family.Chip as C\nfoo = M3e.Component.Chip.chip [] []",
      // Original Component.* -> Element.*; original Family.* -> Component.*;
      // and the produced Component.Chip must SURVIVE (not become Element.Chip).
      expected:
        "import M3e.Element.Button as B\nimport M3e.Component.Chip as C\nfoo = M3e.Element.Chip.chip [] []",
    },
    {
      name: "Family alone maps to Component and STOPS (no double-hop)",
      input: "import M3e.Family.Chip exposing (chip)",
      expected: "import M3e.Component.Chip exposing (chip)",
    },
    {
      name: "TypedHtml.Component -> TypedHtml.Element, unaffected by M3e keys",
      input: "import TypedHtml.Component.Div as D\nimport M3e.Family.NavMenu as N",
      expected: "import TypedHtml.Element.Div as D\nimport M3e.Component.NavMenu as N",
    },
    {
      name: "non-matching namespaces left untouched",
      input:
        "import M3e.Build.Button as Bld\nimport M3e.Element.Icon as I\nimport TypedHtml.Element.Span as S\nimport Html exposing (div)",
      expected:
        "import M3e.Build.Button as Bld\nimport M3e.Element.Icon as I\nimport TypedHtml.Element.Span as S\nimport Html exposing (div)",
    },
    {
      name: "no spurious match on M3e.ComponentX (must require trailing dot)",
      input: "type alias M3e = {}\nfoo = M3e.ComponentName",
      expected: "type alias M3e = {}\nfoo = M3e.ComponentName",
    },
    {
      name: "repeated / dense mixed occurrences in one line",
      input:
        "[ M3e.Component.Card.component, M3e.Family.Chip.chip, M3e.Component.Button.component, M3e.Family.NavMenu.navMenu ]",
      expected:
        "[ M3e.Element.Card.component, M3e.Component.Chip.chip, M3e.Element.Button.component, M3e.Component.NavMenu.navMenu ]",
    },
    {
      name: "NOT idempotent — a second run re-hops Family and corrupts (run exactly once)",
      input: "M3e.Component.Button.component / M3e.Family.Chip.chip",
      expected: null, // checked specially below
    },
  ];

  let pass = 0;
  let fail = 0;
  for (const c of cases) {
    if (c.expected === null) {
      // The rename is deliberately a ONE-SHOT operation: because Family maps
      // INTO the Component name-slot, running the map a second time would hop
      // those fresh Component tokens on to Element. This is the SAME class of
      // hazard the single-pass design defeats WITHIN a file; across runs the
      // only defense is "run exactly once". Assert the non-idempotence so the
      // property is documented and enforced, not accidental.
      const once = applyRename(c.input);
      const twice = applyRename(once);
      const corruptsOnSecondRun = once !== twice && twice.includes("M3e.Element.Chip");
      if (corruptsOnSecondRun) {
        console.log(`  ok   ${c.name}`);
        pass++;
      } else {
        console.error(`  FAIL ${c.name} — expected a second run to re-hop Family->Component->Element\n    once:  ${JSON.stringify(once)}\n    twice: ${JSON.stringify(twice)}`);
        fail++;
      }
      continue;
    }
    const got = applyRename(c.input);
    if (got === c.expected) {
      console.log(`  ok   ${c.name}`);
      pass++;
    } else {
      console.error(`  FAIL ${c.name}\n    input:    ${JSON.stringify(c.input)}\n    expected: ${JSON.stringify(c.expected)}\n    got:      ${JSON.stringify(got)}`);
      fail++;
    }
  }

  // Contrast test: prove a NAIVE sequential rename WOULD corrupt, so the
  // single-pass design is load-bearing, not incidental.
  const naiveInput = "M3e.Family.Chip.chip";
  let naive = naiveInput.split("M3e.Component.").join("M3e.Element."); // pass 1 (no-op here)
  naive = naive.split("M3e.Family.").join("M3e.Component."); // pass 2 -> M3e.Component.Chip
  // A THIRD (or re-ordered) sequential Component->Element pass would break it;
  // demonstrate the reorder hazard directly:
  let naiveBad = naiveInput.split("M3e.Family.").join("M3e.Component."); // -> M3e.Component.Chip.chip
  naiveBad = naiveBad.split("M3e.Component.").join("M3e.Element."); // -> M3e.Element.Chip.chip  (WRONG)
  const single = applyRename(naiveInput); // -> M3e.Component.Chip.chip (RIGHT)
  if (naiveBad === "M3e.Element.Chip.chip" && single === "M3e.Component.Chip.chip") {
    console.log("  ok   contrast: sequential reorder corrupts, single pass does not");
    pass++;
  } else {
    console.error(`  FAIL contrast test\n    naiveBad: ${naiveBad}\n    single:   ${single}`);
    fail++;
  }

  console.log(`\nselftest: ${pass} passed, ${fail} failed`);
  process.exit(fail === 0 ? 0 : 1);
}

// --- CLI -------------------------------------------------------------------
function main() {
  const args = process.argv.slice(2);
  if (args.includes("--selftest")) return selftest();
  const dry = args.includes("--dry");
  const dirs = args.filter((a) => !a.startsWith("--"));
  if (dirs.length === 0) {
    console.error("usage: rename-namespaces.mjs [--dry] <target-dir> [<target-dir> ...]\n       rename-namespaces.mjs --selftest");
    process.exit(2);
  }
  const { changed, scanned, changedFiles } = migrateDirs(dirs, { dry });
  for (const f of changedFiles) console.log(`${dry ? "would change" : "changed"}: ${f}`);
  console.log(`\nrename-namespaces: ${changed}/${scanned} .elm file(s) ${dry ? "would be " : ""}remapped across ${dirs.length} dir(s)`);
}

main();
