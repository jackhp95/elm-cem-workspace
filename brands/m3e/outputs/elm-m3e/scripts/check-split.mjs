#!/usr/bin/env node
// check:split — revive the facet-family splitter as a gate.
//
// Regenerates the per-package publish mirror trees from the generated flat src/
// via `elm-cem split` (packages.json), then proves EACH emitted package compiles
// registry-faithfully (`elm-cem registry-check` = static family-dep coverage gate
// + `elm make --docs`), staging every intra-family dep from its freshly-split
// sibling tree. Exit 0 only if the split gates (totality/disjointness/DAG-respect)
// AND every package's registry-check pass.
//
// This is the gate that keeps the 3-package-split path honest: it is the CI-level
// proof that the family remains publishable (no reintroduced import cycle, no
// undeclared dep, no unexposed cross-package import) after any codegen change.
//
// Env: ELM_CEM_BIN (default ../../../../core/elm-cem/bin/elm-cem.js), IR_SRC / FACTS_SRC
// (default: sibling layout, resolved by registry-check itself).

import { execFileSync, spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const CEM = process.env.ELM_CEM_BIN || path.resolve(repo, "..", "..", "..", "..", "core", "elm-cem", "bin", "elm-cem.js");
const packagesPath = path.join(repo, "packages.json");
const outDir = path.join(repo, "dist-packages");

function die(msg) {
  console.error(`check:split: FAIL — ${msg}`);
  process.exit(1);
}

if (!fs.existsSync(packagesPath)) die(`no packages.json at ${packagesPath}`);
const spec = JSON.parse(fs.readFileSync(packagesPath, "utf8"));

// 1. (re)generate the split trees from the flat src/.
console.log("check:split: regenerating split trees ...");
fs.rmSync(outDir, { recursive: true, force: true });
try {
  execFileSync("node", [CEM, "split", "--packages=packages.json", "--src=src", `--out=${outDir}`], {
    cwd: repo,
    stdio: "inherit",
  });
} catch (e) {
  die(`splitter exited ${e.status}`);
}

// short-name → package name, for resolving intra-family --dep-src staging.
const shortToName = {};
for (const p of spec.packages) shortToName[p.name.split("/")[1]] = p.name;

// 2. registry-check every emitted package, staging intra-family deps from their
//    just-split sibling trees. IR/facts auto-resolve inside registry-check.
let failed = 0;
for (const p of spec.packages) {
  const short = p.name.split("/")[1];
  const pkgDir = path.join(outDir, short);
  const depSrcArgs = [];
  for (const dep of Object.keys(p.deps || {})) {
    const depShort = dep.split("/")[1];
    if (dep.startsWith("jackhp95/elm-m3e")) {
      depSrcArgs.push(`--dep-src=${dep}=${path.join(outDir, depShort, "src")}`);
    }
  }
  console.log(`\ncheck:split: registry-check ${p.name} ...`);
  const r = spawnSync("node", [CEM, "registry-check", ...depSrcArgs], {
    cwd: pkgDir,
    encoding: "utf8",
  });
  process.stdout.write(r.stdout || "");
  if (r.status !== 0) {
    process.stderr.write(r.stderr || "");
    console.error(`check:split: registry-check FAILED for ${p.name}`);
    failed++;
  }
}

if (failed) die(`${failed} package(s) failed registry-check`);
console.log(`\ncheck:split: OK — ${spec.packages.length} split package(s) compile registry-faithfully.`);
