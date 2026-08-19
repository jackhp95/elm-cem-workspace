#!/usr/bin/env node
// Tests for `elm-cem brand-sync` (issue #50): scaffolding is deterministic,
// idempotent, byte-identical-modulo-token across brands, and --check detects
// drift. Runs against a throwaway fake-brand dir — no real brand repo needed.

import { spawnSync } from "node:child_process";
import assert from "node:assert";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { repo } from "./lib/harness.mjs";

const CLI = path.join(repo, "bin", "elm-cem.js");

function fakeBrand(name, lib) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), `brand-sync-${name}-`));
  fs.writeFileSync(
    path.join(dir, "package.json"),
    JSON.stringify(
      { name, version: "1.0.0", config: { cem: "node_modules/x/custom-elements.json" }, scripts: { "measure-docs": "old", "gate:drift": "old" } },
      null,
      2
    ) + "\n"
  );
  fs.mkdirSync(path.join(dir, "src", lib), { recursive: true });
  fs.writeFileSync(path.join(dir, "src", `${lib}.elm`), `module ${lib} exposing (x)\n\n\nx =\n    1\n`);
  return dir;
}

function sync(dir, args = []) {
  const r = spawnSync("node", [CLI, "brand-sync", ...args], { cwd: dir, encoding: "utf8" });
  return r;
}

const a = fakeBrand("elm-aaa", "Aaa");
const b = fakeBrand("elm-bbb", "Bbb");

// 1. brand-sync infers the lib prefix and scaffolds the files.
assert.equal(sync(a).status, 0, "brand-sync should succeed");
const ciA = fs.readFileSync(path.join(a, ".github", "workflows", "ci.yml"), "utf8");
const reviewA = fs.readFileSync(path.join(a, "review", "src", "ReviewConfig.elm"), "utf8");
const pkgA = JSON.parse(fs.readFileSync(path.join(a, "package.json"), "utf8"));
assert.ok(fs.existsSync(path.join(a, "README.md")), "README scaffolded when missing");
console.log("brand-sync-test: OK — scaffolds ci.yml + ReviewConfig + README + package.json");

// 2. Standard gate scripts present; obsolete per-brand scripts removed.
// The elm-cem subcommands are now reached through granular check:* names — see 2a2
// for the full convention. `gate` is the pre-push entry point; with no test:* in a
// brand it delegates straight to `check`.
const CEM = 'node "${ELM_CEM_BIN:-../elm-cem/bin/elm-cem.js}"';
assert.equal(pkgA.scripts["check:drift"], `${CEM} regen-drift`);
assert.equal(pkgA.scripts["check:registry"], `${CEM} registry-check`);
assert.equal(pkgA.scripts["check:acid"], `${CEM} acid`);
assert.equal(pkgA.scripts["check:docs-size"], `${CEM} validate`);
assert.equal(pkgA.scripts.gate, "npm run check");
assert.ok(!("measure-docs" in pkgA.scripts), "measure-docs removed");
assert.ok(!("gate:drift" in pkgA.scripts), "gate:drift removed");
assert.ok(!pkgA.scripts.gen.includes("/Users/"), "canonical gen has no absolute path");
console.log("brand-sync-test: OK — standard scripts merged, obsolete scripts purged, gen path-free");

// 2a2. The script convention: granular check:* steps, glob combo, no dead names.
// Every step must be independently runnable — that is the point of decomposing
// `elm-cem gate` into drift/registry/acid rather than shipping one opaque script.
for (const g of ["check:format", "check:review", "check:drift", "check:registry", "check:acid", "check:docs-size"]) {
  assert.ok(pkgA.scripts[g], `${g} is scaffolded and independently runnable`);
}
assert.equal(pkgA.scripts.check, 'run-p "check:*"', "check is a glob combo, not a hand-maintained list");
assert.ok(pkgA.scripts.gate, "gate exists (what pre-push runs)");
assert.ok(pkgA.scripts.format && !pkgA.scripts.format.includes("--validate"), "format WRITES; it is not a check");
for (const dead of ["validate", "acid", "review", "format:check", "build"]) {
  assert.ok(!(dead in pkgA.scripts), `pre-convention script \`${dead}\` is purged`);
}
// The combos need run-p/run-s, so the tool must be declared — scaffolding
// scripts a brand cannot run would be worse than scaffolding none.
assert.ok(
  (pkgA.devDependencies || {})["npm-run-all2"],
  "npm-run-all2 is declared as a devDependency"
);
console.log("brand-sync-test: OK — granular check:* steps, glob combo, npm-run-all2 declared");

// 2b. The pre-push gate: hook scaffolded, executable, and armed by postinstall.
// The hook IS the primary gate for this family (CI is manual-dispatch only), so
// a brand that scaffolds without it would push unverified.
const hookA = path.join(a, "hooks", "pre-push");
assert.ok(fs.existsSync(hookA), "hooks/pre-push scaffolded");
assert.ok((fs.statSync(hookA).mode & 0o111) !== 0, "hooks/pre-push is executable");
assert.equal(pkgA.scripts["hooks:install"], "git config core.hooksPath hooks");
assert.ok(
  pkgA.scripts.postinstall.includes("npm run hooks:install"),
  "postinstall arms the hook, so `npm install` is enough"
);
const hookBody = fs.readFileSync(hookA, "utf8");
assert.ok(hookBody.includes("npm run"), "hook actually runs the gate");
assert.ok(hookBody.includes("SKIP_GATE"), "hook documents its escape hatch");
console.log("brand-sync-test: OK — pre-push hook scaffolded, executable, armed by postinstall");

// 2c. CI must not duplicate the local gate on every push. Local-first is the
// whole point: the workflow clones private siblings behind a PAT, so leaving it
// on push/pull_request makes every push depend on that token still being valid.
assert.ok(ciA.includes("workflow_dispatch"), "ci.yml is dispatchable");
assert.ok(!/^on:\s*$[\s\S]{0,200}?^\s+push:/m.test(ciA), "ci.yml does not trigger on push");
assert.ok(!/^\s+pull_request:/m.test(ciA), "ci.yml does not trigger on pull_request");
console.log("brand-sync-test: OK — ci.yml is manual-dispatch only (local pre-push is the gate)");

// 3. Idempotent: a second sync makes no changes.
const pkgBefore = fs.readFileSync(path.join(a, "package.json"), "utf8");
assert.equal(sync(a).status, 0);
assert.equal(fs.readFileSync(path.join(a, "package.json"), "utf8"), pkgBefore, "package.json stable");
assert.equal(fs.readFileSync(path.join(a, ".github", "workflows", "ci.yml"), "utf8"), ciA, "ci.yml stable");
console.log("brand-sync-test: OK — idempotent");

// 4. --check passes after sync, fails on drift.
assert.equal(sync(a, ["--check"]).status, 0, "--check passes when in sync");
fs.appendFileSync(path.join(a, ".github", "workflows", "ci.yml"), "\n# drift\n");
assert.notEqual(sync(a, ["--check"]).status, 0, "--check fails on drift");
console.log("brand-sync-test: OK — --check detects drift");

// 4b. --check also guards the hook. A brand could otherwise weaken or delete its
// own gate and stay "in sync".
assert.equal(sync(a).status, 0, "re-sync repairs the ci.yml drift from 4");
assert.equal(sync(a, ["--check"]).status, 0, "--check passes again after re-sync");
fs.appendFileSync(hookA, "\n# drift\n");
assert.notEqual(sync(a, ["--check"]).status, 0, "--check fails on hook drift");
assert.equal(sync(a).status, 0, "re-sync restores the hook");
assert.equal(fs.readFileSync(hookA, "utf8"), hookBody, "hook restored byte-for-byte");
console.log("brand-sync-test: OK — --check detects hook drift, sync restores it");

// 5. Byte-identical-modulo-token: ci.yml identical, ReviewConfig identical after
//    substituting each brand's token back to a placeholder.
assert.equal(sync(b).status, 0);
const ciB = fs.readFileSync(path.join(b, ".github", "workflows", "ci.yml"), "utf8");
assert.equal(ciA, ciB, "ci.yml is byte-identical across brands (no token)");
const reviewB = fs.readFileSync(path.join(b, "review", "src", "ReviewConfig.elm"), "utf8");
const normA = reviewA.split("Aaa").join("{{LIB}}").split("elm-aaa").join("{{BRAND}}");
const normB = reviewB.split("Bbb").join("{{LIB}}").split("elm-bbb").join("{{BRAND}}");
assert.equal(normA, normB, "ReviewConfig is identical modulo the brand token");
console.log("brand-sync-test: OK — ci.yml identical; ReviewConfig identical-modulo-token across brands");

for (const d of [a, b]) fs.rmSync(d, { recursive: true, force: true });
console.log("\nbrand-sync-test: ALL TESTS PASSED");
