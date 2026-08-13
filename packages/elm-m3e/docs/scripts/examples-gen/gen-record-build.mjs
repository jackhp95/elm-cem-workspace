// Generate the Record (`M3e.<Comp>.el { … }`) and Build (`M3e.<Comp>.build |> …`)
// surface code for every Usage example, BY RUNNING the surface elm-review translator
// rules (`TranslateToRecord` / `TranslateToBuild`) over each example's `top`
// (Standard `M3e.*`) code. NO new HTML->Elm converter is written here — this is a
// thin harness around the real rules, built on lib/scratch-harness.mjs.
//
// Mechanism (per surface):
//   1. Write ALL examples' `top` code as bindings into one scratch Elm
//      APPLICATION (a fresh tmpdir, source-dirs = real library sources) — the
//      same pattern verify-examples.mjs uses. The `top` bindings all compile
//      (they are the compile-verified corpus), which elm-review requires.
//   2. Write a scratch elm-review CONFIG (a per-surface tmpdir) whose single
//      rule is `TranslateTo<Surface>.rule M3e.Review.Facts.facts`. (We copy
//      review/src into the config's src and overwrite ReviewConfig.elm; pointing
//      source-directories straight at review/src collides with its own
//      ReviewConfig and runs the FULL rule set.)
//   3. Run `elm-review --report=json` (NOT --fix). The JSON report carries each
//      error's `fix` as explicit {range,string} edits. We apply the target-surface
//      CONVERSION edits and SKIP the whole-node Seam-escape edits ourselves in ONE
//      pass — a PARTIAL conversion: convert whatever converts, leave every
//      un-converted node as its original Standard source.
//
//      Why not `--fix-all-without-prompt`: for a node the rule can't cleanly
//      convert it emits a whole-node `Seam.fromHtml (...)` escape — a call the
//      SAME rule re-triggers on, wrapping it again on every fixpoint iteration
//      → unbounded growth → node stack overflow. A single report-driven pass
//      sidesteps the fixpoint entirely.
//   4. Recover each binding's rewritten code, compile-verify the whole set, and
//      keep an output only if it COMPILES and actually reaches the target surface
//      (the rewrite CHANGED the code — record → `M3e.<Comp>.el { … }`, build →
//      `M3e.<Comp>.build … |> … |> M3e.<Comp>.toElement`). Everything else
//      (identity — the conservative rule declined to transform — or a mixed tree
//      that doesn't type-check) is left null so build-examples-data.mjs produces a
//      null field and the UI shows the "identical by design" rationale tab.
//
// Surface note: the rules `Cem.translateToRecord` / `Cem.translateToBuild`
// (elm-review-cem) target the per-component `el` (required-record) and `build`
// (builder-pipe) forms. translateToRecord only fires on the 29 components that
// have an `el` required record; translateToBuild fires on all components; both are
// conservative no-ops on non-statically-resolvable calls (so not every example
// yields a record/build surface — that's expected).
//
// Output: config/examples.surfaces.json = { "<Module>": [ { record, build }, ... ] }
// aligned index-for-index with config/examples.rich.json. build-examples-data.mjs
// would merge these into docs/data/examples.json (with the elm-format pass).

import { readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import {
  mkScratchDir,
  writeCorpusApp,
  writeReviewConfig,
  runReviewJson,
  applyEditsPartial,
  parseBindings,
  bindingName,
} from "./lib/scratch-harness.mjs";
import { compilingNames } from "./verify-examples.mjs";

const HERE = dirname(fileURLToPath(import.meta.url));
// docs/scripts/examples-gen/gen-record-build.mjs -> elm-m3e root is three up.
const REPO = resolve(HERE, "..", "..", "..");

const RICH = resolve(REPO, "config/examples.rich.json");
const OUT = resolve(REPO, "config/examples.surfaces.json");

const SRC_DIRS = [`${REPO}/src`, `${REPO}/docs/kit`];
const ELM_BIN = `${REPO}/docs/node_modules/.bin/elm`;
const REVIEW_BIN = `${REPO}/docs/node_modules/.bin/elm-review`;
const reviewElm = JSON.parse(readFileSync(`${REPO}/review/elm.json`, "utf8"));

// Each surface = one Cem translator rule run over the Standard `top` corpus.
const SURFACES = [
  { key: "record", imports: ["import Cem", "import M3e.Review.Facts"], ruleExpr: "Cem.translateToRecord M3e.Review.Facts.facts" },
  { key: "build", imports: ["import Cem", "import M3e.Review.Facts"], ruleExpr: "Cem.translateToBuild M3e.Review.Facts.facts" },
];

// Run one translator rule over the { name -> code } corpus; return { name -> rewritten }.
function runRule(items, { imports, ruleExpr, key }) {
  const cfgDir = mkScratchDir(`surface-${key}-cfg`);
  const targetDir = mkScratchDir(`surface-${key}-target`);
  writeReviewConfig(cfgDir, {
    reviewSrcDir: `${REPO}/review/src`,
    reviewElm,
    extraSourceDirs: [`${REPO}/src`, `${REPO}/../elm-review-cem/src`],
    reviewConfigElm: `module ReviewConfig exposing (config)

${imports.join("\n")}
import Review.Rule exposing (Rule)


config : List Rule
config =
    [ ${ruleExpr} ]
`,
  });
  const text = writeCorpusApp(targetDir, items, SRC_DIRS);
  const json = runReviewJson(REVIEW_BIN, cfgDir, targetDir, ELM_BIN, { label: `surface:${key}` });
  return parseBindings(applyEditsPartial(text, json));
}

function main() {
  const rich = JSON.parse(readFileSync(RICH, "utf8"));

  // One binding per example whose Standard `top` compiles (the corpus the rules
  // require — the rewritten form is only trusted if it still compiles).
  const items = [];
  for (const module of Object.keys(rich)) {
    rich[module].forEach((ex, idx) => {
      if (ex.top == null) return;
      items.push({ module, idx, name: bindingName(module, idx), code: ex.top });
    });
  }

  // Result skeleton aligned index-for-index with the rich corpus.
  const out = {};
  for (const module of Object.keys(rich)) out[module] = rich[module].map(() => ({}));

  const counts = {};
  for (const surface of SURFACES) {
    const byName = runRule(items, surface);
    // Trust a rewrite only if it CHANGED the code (the conservative rule fired)
    // AND the whole rewritten corpus still compiles.
    const candidates = {};
    for (const it of items) candidates[it.name] = byName[it.name] ?? it.code;
    const ok = compilingNames(candidates);

    let kept = 0;
    for (const it of items) {
      const code = byName[it.name];
      if (code && code !== it.code && ok.has(it.name)) {
        out[it.module][it.idx][surface.key] = code;
        kept++;
      }
    }
    counts[surface.key] = kept;
  }

  writeFileSync(OUT, JSON.stringify(out, null, 2) + "\n");
  console.log(
    `gen-record-build: over ${items.length} examples — ` +
      SURFACES.map((s) => `${s.key} ${counts[s.key]}`).join(", ") +
      ` → ${OUT} (non-transformed show the rationale tab).`,
  );
}

main();
