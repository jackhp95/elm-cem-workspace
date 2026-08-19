#!/usr/bin/env node
// check-cc-elm-refs.mjs — the Code Connect → Elm module-reference gate.
//
// Stream 2 (see docs/plans/2026-08-17-stream2-cc-elm-naming-reconciliation.md):
// cem-figma-connect emits Code Connect Elm snippets
// (core/cem-figma-connect/generated/m3-kit/elm/*.figma.ts). Every module a
// snippet imports or calls into MUST exist in the real elm-m3e API, or a
// consumer who pastes the snippet cannot compile it. This gate proves that by
// checking every module reference in each emitted snippet against the ACTUAL
// module set of the elm-m3e source tree + the vendored TypedHtml foundation.
//
// v1 (this file) = module-reference existence. It deterministically catches the
// exact bug this stream targets — snippets referencing NON-EXISTENT modules
// (`M3e.Button` instead of `M3e.Component.Button`; the deleted `Kit` / `Native`
// seams). It is offline and needs no elm toolchain, so it runs anywhere gate-all
// runs. It does NOT catch argument-type errors; a full `elm make` over the
// substituted snippet bodies is the documented v2 hardening (see the plan, F4).
//
// Usage:
//   node tools/check-cc-elm-refs.mjs           # report; exit 0 (non-blocking v1)
//   node tools/check-cc-elm-refs.mjs --strict  # exit 1 if any missing reference
//
// Zero dependencies (plain Node ESM).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const strict = process.argv.includes("--strict");

// Source roots whose emitted `.elm` module names define the REAL, referenceable
// API surface a Code Connect snippet may name. elm-m3e/src carries the M3e.*
// modules (barrel `M3e`, `M3e.Component.*`, `M3e.Build.*`, `M3e.Icon`,
// `M3e.Values`, `M3e.Action`, …); the docs vendor carries the `TypedHtml.*`
// plain-HTML foundation the snippets use for scaffolding.
const SRC_ROOTS = [
  path.join(repoRoot, "brands", "m3e", "generated", "package", "elm-m3e", "src"),
  path.join(repoRoot, "brands", "m3e", "generated", "docs", "elm-m3e-docs", "vendor", "elm-foundation"),
];

// Where the emitted Code Connect Elm snippets live.
const CC_ELM_DIR = path.join(
  repoRoot,
  "pipeline",
  "elm-cem-figma-connect",
  "generated",
  "m3-kit",
  "elm",
);

function walkElm(dir, out) {
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walkElm(full, out);
    else if (entry.name.endsWith(".elm")) out.push(full);
  }
  return out;
}

// The set of real module names, read from each file's `module X.Y exposing`
// header (the authoritative module identity — file path and header always agree
// in valid Elm).
function realModuleSet() {
  const set = new Set();
  for (const root of SRC_ROOTS) {
    for (const file of walkElm(root, [])) {
      const head = fs.readFileSync(file, "utf8").slice(0, 4000);
      const m = head.match(/^module\s+([A-Za-z0-9_.]+)\s+exposing/m);
      if (m) set.add(m[1]);
    }
  }
  return set;
}

// Strip Elm/JS comments so prose that names a (deliberately illustrative) module
// in a `/** … */` header or `// url=…` line is never mistaken for a code
// reference. Only real code regions are scanned.
function stripComments(src) {
  return src.replace(/\/\*[\s\S]*?\*\//g, " ").replace(/\/\/[^\n]*/g, " ");
}

// Every module a snippet file depends on: the authoritative `imports: [...]`
// array PLUS any module-qualified reference in the code (belt-and-suspenders —
// catches an emitter that calls a module it forgot to import). A module-
// qualified reference is one-or-more Capitalized dotted segments immediately
// followed by a lowercase member (`M3e.Component.Badge.component` -> module
// `M3e.Component.Badge`; `M3e.Values.large` -> `M3e.Values`; `M3e.text` ->
// `M3e`).
function referencedModules(code) {
  const mods = new Set();

  // Authoritative import list (single line in the emitted file).
  const importsLine = code.match(/imports:\s*\[([^\]]*)\]/);
  if (importsLine) {
    for (const m of importsLine[1].matchAll(/import\s+([A-Za-z0-9_.]+)/g)) {
      mods.add(m[1]);
    }
  }

  // Module-qualified call sites in the code.
  for (const m of code.matchAll(/\b((?:[A-Z][A-Za-z0-9_]*\.)+)[a-z][A-Za-z0-9_]*/g)) {
    mods.add(m[1].replace(/\.$/, ""));
  }
  return mods;
}

function main() {
  const real = realModuleSet();
  if (real.size === 0) {
    console.error(
      "check-cc-elm-refs: found 0 real modules under " +
        SRC_ROOTS.join(", ") +
        " — source tree missing? refusing to pass vacuously.",
    );
    process.exit(1);
  }

  if (!fs.existsSync(CC_ELM_DIR)) {
    console.error(`check-cc-elm-refs: no emitted Code Connect Elm at ${CC_ELM_DIR}`);
    process.exit(1);
  }
  const files = fs
    .readdirSync(CC_ELM_DIR)
    .filter((f) => f.endsWith(".figma.ts"))
    .sort();

  const missingByModule = new Map(); // module -> count of files referencing it
  const filesWithMissing = [];

  for (const file of files) {
    const src = fs.readFileSync(path.join(CC_ELM_DIR, file), "utf8");
    const code = stripComments(src);
    const refs = referencedModules(code);
    const missing = [...refs].filter((m) => !real.has(m)).sort();
    if (missing.length) {
      filesWithMissing.push({ file, missing });
      for (const m of missing) missingByModule.set(m, (missingByModule.get(m) || 0) + 1);
    }
  }

  console.log(
    `check-cc-elm-refs: ${files.length} snippet(s); ` +
      `${real.size} real modules; ` +
      `${filesWithMissing.length} snippet(s) reference a non-existent module.`,
  );

  if (filesWithMissing.length) {
    const ranked = [...missingByModule.entries()].sort((a, b) => b[1] - a[1]);
    console.log("\nMissing modules (referenced but not in the real elm-m3e API):");
    for (const [mod, n] of ranked) console.log(`  ${String(n).padStart(4)}×  ${mod}`);
    console.log("\nFirst 20 offending snippets:");
    for (const { file, missing } of filesWithMissing.slice(0, 20)) {
      console.log(`  ${file}  ->  ${missing.join(", ")}`);
    }
    if (strict) {
      console.error(
        `\ncheck-cc-elm-refs: FAIL (--strict) — ${filesWithMissing.length} snippet(s) ` +
          `reference non-existent modules. See ` +
          `docs/plans/2026-08-17-stream2-cc-elm-naming-reconciliation.md.`,
      );
      process.exit(1);
    }
    console.log(
      "\ncheck-cc-elm-refs: non-blocking v1 (report only). Run with --strict to gate.",
    );
  } else {
    console.log("check-cc-elm-refs: OK — every snippet references only real modules.");
  }
  process.exit(0);
}

main();
