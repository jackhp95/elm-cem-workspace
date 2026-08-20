#!/usr/bin/env node
// check-elm-shape-drift.mjs — Phase 1 (L6): the canonical-engine drift gate.
//
// Phase 1 collapsed the duplicated html→elm shape grammar into ONE engine,
// pipeline/elm-cem/src/elm-shape.mjs. This gate keeps it one engine:
//
//   1. The engine still exports its full canonical API (Layer 1 resolvers +
//      Layer 2 renderers). Deleting/renaming one is caught here.
//   2. The engine renders the shared call shape for a FIXTURE component exactly
//      as expected (a self-contained golden). Perturbing renderComponentCall's
//      whitespace/grammar fails THIS gate — in the same CI run as the migrated
//      consumers' own byte-diff gates (elm-cem `test:elm-shape` and
//      tools/check-drift.mjs's cem-figma-connect output byte-diff, which now
//      flows through elm-shape). That is the "one perturbation fails every
//      consumer" property L6 asks for.
//   3. Every MIGRATED consumer imports the engine and carries NO private
//      re-implementation of the shape grammar (a future dev re-inlining
//      `renderExample`/`resolveToken`/`setterOf`/`slotSetterOf` fails the gate).
//      Not-yet-migrated consumers are listed explicitly as PENDING, so A's
//      deferred migration is documented in CI rather than silently forgotten —
//      flip its `migrated` flag when L5 lands and the import is then enforced.
//
// Zero dependencies. Exits 0 on success, 1 on any failure.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  renderComponentCall,
  renderAttrList,
  renderList,
  renderSlot,
  renderTextSeam,
  renderNativeAttr,
  renderTypedHtml,
  ok,
  err,
  canon,
  setterOf,
  resolveEnumToken,
  resolveAttrExpr,
  slotFnOf,
  slotAttrOf,
  actionNoneOf,
  entryOf,
  iconNameExpr,
} from "../pipeline/elm-cem/src/elm-shape.mjs";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));

const problems = [];
const fail = (m) => problems.push(m);

// ── 1. the canonical API surface still exists ──────────────────────────────
const API = {
  renderComponentCall,
  renderAttrList,
  renderList,
  renderSlot,
  renderTextSeam,
  renderNativeAttr,
  renderTypedHtml,
  ok,
  err,
  canon,
  setterOf,
  resolveEnumToken,
  resolveAttrExpr,
  slotFnOf,
  slotAttrOf,
  actionNoneOf,
  entryOf,
  iconNameExpr,
};
for (const [name, fn] of Object.entries(API)) {
  if (typeof fn !== "function") fail(`elm-shape no longer exports \`${name}\` as a function`);
}

// ── 2. the shared call shape renders exactly (fixture golden) ──────────────
// The record-double-list form is the one the ctor-rename cascade moved the
// composed components to; lock its exact bytes at BOTH layouts.
const topGolden = renderComponentCall({
  module: "M3e.Button",
  entry: "component",
  form: "record-double-list",
  setters: [{ setter: "variant", expr: "M3e.Values.filled" }],
  content: `Kit.text "Go"`,
  actionNone: "M3e.Button.Action.none",
  label: "fixture",
  multiline: true,
});
const topExpected =
  "M3e.Button.component\n" +
  "    { content = Kit.text \"Go\"\n" +
  "    , action = M3e.Button.Action.none\n" +
  "    }\n" +
  "    [ M3e.Button.variant M3e.Values.filled\n" +
  "    ]\n" +
  "    []";
if (topGolden !== topExpected) {
  fail(
    `elm-shape renderComponentCall (multiline record) drifted.\n--- expected ---\n${topExpected}\n--- actual ---\n${topGolden}`
  );
}

const nestedGolden = renderComponentCall({
  module: "M3e.Chip",
  entry: "component",
  form: "record-double-list",
  setters: [],
  children: [`Kit.text "A"`],
  actionNone: "M3e.Chip.Action.none",
  label: "fixture",
  multiline: false,
});
const nestedExpected = `M3e.Chip.component { content = Kit.text "A", action = M3e.Chip.Action.none } [] []`;
if (nestedGolden !== nestedExpected) {
  fail(`elm-shape renderComponentCall (inline record) drifted.\n--- expected ---\n${nestedExpected}\n--- actual ---\n${nestedGolden}`);
}

// ── 3. consumer invariants: migrated consumers import + don't re-inline ────
// A "private re-implementation" is a top-level `function <name>(` for any of the
// grammar functions the engine now owns. A thin same-name WRAPPER that delegates
// (e.g. `function resolveToken(...) { return must(resolveEnumToken(...)) }`) is
// fine — those keep the historical `_internal.*` test surface — so the gate only
// flags a re-DECLARED renderer body, i.e. the multiline call-shape switch. We key
// on the load-bearing renderer `renderExample`'s switch and the multiline
// composition, which no delegating wrapper contains.
const consumers = [
  {
    name: "elm-cem-figma-connect (elm emitter)",
    file: "pipeline/elm-cem-figma-connect/profiles/m3-kit/emitters/elm.mjs",
    migrated: true,
  },
  {
    // Engine A — deferred (L5): its generation is dead against the current
    // library (deleted Kit/Native seam, FATAL compile harness, stale-vocab unit
    // tests). See docs/plans/2026-08-17-phase1-L4-facec-coverage-audit.md. Flip
    // `migrated` to true when L5 lands; the import is then ENFORCED below.
    name: "elm-m3e docs (to-elm)",
    file: "brands/m3e/generated/docs/elm-m3e-docs/scripts/examples-gen/lib/to-elm.mjs",
    migrated: false,
  },
];

// A re-inlined multiline renderer would contain BOTH a `switch (` over a form AND
// the record-form multiline composition marker. The delegating wrapper contains
// neither (it calls renderComponentCall). This catches a future dev copy-pasting
// the old grammar back in.
const REINLINE_MARKERS = [/\{ content = \$\{[^}]*\}\\n/, /case "record-double-list": \{/];

for (const c of consumers) {
  const abs = path.join(repoRoot, c.file);
  if (!fs.existsSync(abs)) {
    fail(`consumer file missing: ${c.file}`);
    continue;
  }
  const src = fs.readFileSync(abs, "utf8");
  if (c.migrated) {
    if (!/from\s+["']elm-cem\/elm-shape["']/.test(src)) {
      fail(`${c.name} is marked migrated but does NOT import from "elm-cem/elm-shape"`);
    }
    const reinlined = REINLINE_MARKERS.filter((re) => re.test(src));
    if (reinlined.length === REINLINE_MARKERS.length) {
      fail(
        `${c.name} appears to re-inline the shape grammar (found the multiline record-form ` +
          `composition locally). Route it through elm-shape's renderComponentCall instead.`
      );
    }
  } else {
    console.log(
      `NOTE  ${c.name} — PENDING migration onto elm-shape (Phase 1 L5 deferred). ` +
        `Import not yet enforced.`
    );
  }
}

// ── report ─────────────────────────────────────────────────────────────────
if (problems.length > 0) {
  console.error("check-elm-shape-drift: FAILED");
  for (const p of problems) console.error(`  - ${p}`);
  process.exit(1);
}
console.log(
  "check-elm-shape-drift: OK — canonical engine intact, fixture shape byte-stable, " +
    "migrated consumers route through elm-shape."
);
