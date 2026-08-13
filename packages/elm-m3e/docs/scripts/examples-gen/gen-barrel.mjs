// Barrelise every Usage example's TOP (Standard `M3e.*`) code by RUNNING the
// opt-in `PreferBarrel` elm-review rule over it, then write the barrel-first
// result into a SEPARATE, index-aligned sidecar `config/examples.barrel.json`
//
// (exactly like gen-record-build.mjs writes examples.surfaces.json). The rich
// file's `top` is LEFT UNTOUCHED so it stays the Standard source-of-truth that the
// ④ Record / ⑤ Build translators derive from — this step is therefore order- and
// re-run-independent. build-examples-data.mjs prefers the barrel `top` for the
// docs `top` field, falling back to the Standard `top` where barrelisation was
// rejected. Shape: { "<Module>": [ "<barrelTop>" | null, ... ] } (null = keep
// Standard). This step may run any time after build:examples-surfaces; it reads
// only `top` from the rich file.
//
// This is a thin report-driven harness around the real rule (same shape as
// gen-record-build.mjs), built on lib/scratch-harness.mjs:
//   1. Write ALL examples' `top` as bindings into one scratch Elm APPLICATION
//      (source-dirs = real library sources) — the compile-verified corpus.
//   2. Write a scratch elm-review CONFIG whose single rule is `PreferBarrel.rule`.
//   3. Run `elm-review --report=json` (NOT --fix). Apply the rename edits ourselves
//      in one pass (each `M3e.<Comp>.view`/`.<setter>` / `M3e.Token.<token>` node
//      → its flat `M3e.<name>` barrel export). We SKIP the rule's zero-width
//      `import M3e` insertions — imports are regenerated from references here.
//   4. Recover each binding, compile-verify the whole barrelised set, and keep an
//      output only if it COMPILES (the barrel is a faithful re-export, so it
//      always should); otherwise fall back to the original Standard `top`.
//
// `PreferBarrel` deliberately leaves `M3e.<Comp>.child` / `.children` / `.name` /
// `M3e.<Comp>.value` qualified (those names are NOT in the barrel), so a barrelised
// button top reads `M3e.button [ M3e.variant M3e.filled ] [ M3e.Button.child (…) ]`.

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
// docs/scripts/examples-gen/gen-barrel.mjs -> elm-m3e root is three up.
const REPO = resolve(HERE, "..", "..", "..");

const RICH = resolve(REPO, "config/examples.rich.json");
const BARREL = resolve(REPO, "config/examples.barrel.json");

const SRC_DIRS = [`${REPO}/src`, `${REPO}/docs/kit`];
const ELM_BIN = `${REPO}/docs/node_modules/.bin/elm`;
const REVIEW_BIN = `${REPO}/docs/node_modules/.bin/elm-review`;
const reviewElm = JSON.parse(readFileSync(`${REPO}/review/elm.json`, "utf8"));

const REVIEW_CONFIG = `module ReviewConfig exposing (config)

import Cem.PreferBarrel
import M3e.Review.Facts
import Review.Rule exposing (Rule)
import Set


config : List Rule
config =
    [ Cem.PreferBarrel.ruleWith (Set.fromList M3e.Review.Facts.reExposedValueTokens) M3e.Review.Facts.facts ]
`;

// Run PreferBarrel over the { name -> code } corpus; return { name -> rewritten }.
function barrelise(items) {
  const cfgDir = mkScratchDir("barrel-cfg");
  const targetDir = mkScratchDir("barrel-target");
  writeReviewConfig(cfgDir, {
    reviewSrcDir: `${REPO}/review/src`,
    reviewElm,
    extraSourceDirs: [`${REPO}/src`, `${REPO}/../elm-review-cem/src`],
    reviewConfigElm: REVIEW_CONFIG,
  });
  const text = writeCorpusApp(targetDir, items, SRC_DIRS);
  const json = runReviewJson(REVIEW_BIN, cfgDir, targetDir, ELM_BIN, { label: "barrel" });
  return parseBindings(applyEditsPartial(text, json));
}

function main() {
  const rich = JSON.parse(readFileSync(RICH, "utf8"));

  // One binding per example whose Standard `top` compiles (the corpus).
  const items = [];
  for (const module of Object.keys(rich)) {
    rich[module].forEach((ex, idx) => {
      if (ex.top == null) return;
      items.push({ module, idx, name: bindingName(module, idx), code: ex.top });
    });
  }

  const byName = barrelise(items);

  // Keep the barrelised form only if it (a) actually changed and (b) compiles;
  // otherwise null → build-examples-data.mjs falls back to the Standard `top`.
  const candidates = {};
  for (const it of items) candidates[it.name] = byName[it.name] ?? it.code;
  const ok = compilingNames(candidates);

  const out = {};
  for (const module of Object.keys(rich)) out[module] = rich[module].map(() => null);
  let barrelised = 0;
  for (const it of items) {
    const code = byName[it.name];
    if (code && code !== it.code && ok.has(it.name)) {
      out[it.module][it.idx] = code;
      barrelised++;
    }
  }

  writeFileSync(BARREL, JSON.stringify(out, null, 2) + "\n");
  console.log(
    `gen-barrel: barrelised ${barrelised}/${items.length} examples → ${BARREL} ` +
      `(non-barrelised keep the Standard top).`,
  );
}

main();
