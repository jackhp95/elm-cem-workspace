#!/usr/bin/env node
// registry-check --nested-pkg + base-deps-verbatim (batch-4 hardening, friction
// 20260812T012700Z: elm-m3e-icons/elm.json shipped missing elm/json +
// elm/virtual-dom — deps needed transitively via the staged IR internals module
// — and nothing caught it).
//
// Two gaps closed together, both exercised here against a purpose-built nested
// icon package (mirrors the real elm-m3e-icons bug precisely: IR correctly
// declared so the static family-dep audit passes, but elm/json + elm/virtual-dom
// omitted from `dependencies`):
//
//   1. registry-check was never invoked against a nested package at all — only
//      regen-drift's --nested-pkg covered it, and drift only proves "matches a
//      fresh regen", not "the regen declares a self-sufficient elm.json".
//      registry-check now accepts --nested-pkg=<dir> (repeatable) too.
//   2. The package-shaped compile's scratch elm.json unconditionally stamped
//      `family.baseDependencies()` (a fixed {elm/core, elm/html, elm/json,
//      elm/virtual-dom}) instead of the REAL committed elm.json's declared
//      deps — so a real elm.json missing elm/json/elm/virtual-dom still
//      "compiled registry-faithfully": the check silently supplied the missing
//      dep itself. Fixed to use the real declared (non-family) deps verbatim.
//
// Needs elm + a local IR src (env IR_SRC, or the sibling-repo default) to run
// the compile-level assertions; SKIPs those (not fails) if unavailable, same
// convention as gates.test.mjs.
//
// Run standalone: `node tests/registry-check-nested-pkg.test.mjs`

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, "..");
const cli = path.join(repo, "bin", "elm-cem.js");
const fixture = path.join(repo, "tests", "fixtures", "wc-widgets.cem.json");
const IR = "jackhp95/elm-html-intermediate-representation";

let failures = 0;
const ok = (msg) => console.log(`registry-check-nested-pkg-test: OK — ${msg}`);
const check = (cond, msg, extra = "") => {
  if (cond) ok(msg);
  else {
    console.error(`registry-check-nested-pkg-test: FAIL — ${msg}${extra ? "\n" + extra : ""}`);
    failures++;
  }
};

const elm = [path.join(repo, "node_modules", ".bin", "elm"), process.env.ELM_BINARY].find(
  (e) => e && fs.existsSync(e)
);
const elmFormat = path.join(repo, "node_modules", ".bin", "elm-format");
const irSrc = [
  path.resolve(repo, "..", "elm-html-intermediate-representation", "src"),
  process.env.IR_SRC,
].find((p) => p && fs.existsSync(p));

if (!elm || !irSrc) {
  console.log(`registry-check-nested-pkg-test: SKIP (elm=${!!elm} ir=${!!irSrc})`);
  process.exit(0);
}

// ── Build a throwaway brand whose config declares a nested icon package with
//    IR correctly declared but elm/json + elm/virtual-dom OMITTED — the exact
//    shape of the real bug. ────────────────────────────────────────────────
const brand = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-registry-nested-"));
fs.mkdirSync(path.join(brand, "config"), { recursive: true });
fs.writeFileSync(path.join(brand, "config", "icons-catalog.json"), JSON.stringify({ names: ["menu", "close"] }));
const depsIncomplete = { "elm/core": "1.0.0 <= v < 2.0.0", "elm/html": "1.0.0 <= v < 2.0.0", [IR]: "1.0.0 <= v < 2.0.0" };
const depsComplete = {
  ...depsIncomplete,
  "elm/json": "1.0.0 <= v < 2.0.0",
  "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
};
const slotsJsonFor = (deps) =>
  JSON.stringify({
    _phantom: true,
    _iconModule: {
      lib: "Nk",
      iconComp: "Icon",
      catalogFrom: "config/icons-catalog.json",
      tag: "nk-icon",
      iconFamily: "Nk Icons",
      package: { dir: "nk-icons", name: "test/nk-icons", summary: "nested-pkg registry-check test", version: "1.0.0", deps },
    },
  });
fs.writeFileSync(path.join(brand, "config", "slots.json"), slotsJsonFor(depsIncomplete));
fs.copyFileSync(fixture, path.join(brand, "custom-elements.json"));
fs.writeFileSync(
  path.join(brand, "package.json"),
  JSON.stringify({ name: "elm-nk-icons-test", config: { cem: "custom-elements.json" } }, null, 2)
);
// Seed a package elm.json (the generator stamps exposed-modules + family deps
// into it as a side effect of generation, same as gates.test.mjs's brand).
fs.writeFileSync(
  path.join(brand, "elm.json"),
  JSON.stringify(
    {
      type: "package",
      name: "jackhp95/elm-nk",
      summary: "registry-check nested-pkg test brand",
      license: "BSD-3-Clause",
      version: "1.0.0",
      "exposed-modules": [],
      "elm-version": "0.19.0 <= v < 0.20.0",
      dependencies: {
        "elm/core": "1.0.0 <= v < 2.0.0",
        "elm/html": "1.0.0 <= v < 2.0.0",
        "elm/json": "1.0.0 <= v < 2.0.0",
        "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
      },
      "test-dependencies": {},
    },
    null,
    4
  ) + "\n"
);

const gen = spawnSync(
  "node",
  [cli, `--flags-from=${path.join(brand, "custom-elements.json")}`, "--config-from=config/slots.json", `--output=${path.join(brand, "src")}`],
  { cwd: brand, encoding: "utf8" }
);
if (gen.status !== 0) {
  console.error(gen.stdout, gen.stderr);
  console.error("registry-check-nested-pkg-test: FAIL — could not generate the test brand");
  process.exit(1);
}
const nestedSrc = path.join(brand, "nk-icons", "src");
if (fs.existsSync(elmFormat)) spawnSync(elmFormat, [nestedSrc, "--yes"], { encoding: "utf8" });
check(fs.existsSync(nestedSrc), "nested icon package src/ was written by the generator (test setup sanity)");

const runRegistryCheck = (args = []) =>
  spawnSync("node", [cli, "registry-check", `--elm=${elm}`, `--dep-src=${IR}=${irSrc}`, ...args], {
    cwd: brand,
    encoding: "utf8",
  });

// ── Gap 1: registry-check must be INVOKABLE against a nested package at all ──
{
  const noNested = runRegistryCheck([]); // root brand elm.json has no exposed-modules — compile step should fail differently, but the point is it never even LOOKS at nk-icons
  check(
    !new RegExp("nk-icons").test(noNested.stdout + noNested.stderr),
    "registry-check WITHOUT --nested-pkg never mentions the nested package (the pre-fix blind spot)"
  );
}

// ── Gap 2: the nested package's elm.json is missing elm/json + elm/virtual-dom
//    (real committed shape) -> compile must FAIL naming the missing modules. ──
{
  const bad = runRegistryCheck(["--nested-pkg=nk-icons"]);
  const out = bad.stdout + bad.stderr;
  check(
    bad.status === 1 && /nk-icons/.test(out) && /(Json\.Decode|Json\.Encode|VirtualDom)/.test(out),
    'registry-check --nested-pkg=nk-icons FAILS, naming the package AND the unresolved Json/VirtualDom import (elm/json + elm/virtual-dom missing)',
    out
  );
}

// ── Revert: declare the two missing base deps -> GREEN. ──────────────────────
{
  fs.writeFileSync(path.join(brand, "config", "slots.json"), slotsJsonFor(depsComplete));
  const nestedElmJsonPath = path.join(brand, "nk-icons", "elm.json");
  const nestedElmJson = JSON.parse(fs.readFileSync(nestedElmJsonPath, "utf8"));
  nestedElmJson.dependencies = depsComplete;
  fs.writeFileSync(nestedElmJsonPath, JSON.stringify(nestedElmJson, null, 4) + "\n");

  const good = runRegistryCheck(["--nested-pkg=nk-icons"]);
  check(
    good.status === 0,
    "registry-check --nested-pkg=nk-icons PASSES again once elm/json + elm/virtual-dom are declared",
    good.stdout + good.stderr
  );
}

fs.rmSync(brand, { recursive: true, force: true });

if (failures > 0) {
  console.error(`\nregistry-check-nested-pkg-test: ${failures} FAILURE(S)`);
  process.exit(1);
}
console.log("\nregistry-check-nested-pkg-test: ALL CHECKS PASSED");
