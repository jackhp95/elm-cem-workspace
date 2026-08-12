#!/usr/bin/env node
// Release gates: regen-drift + registry-check (issue #49, findings NB5 + B2/NB1).
//
// Builds a throwaway brand repo from the committed nonm3e fixture (generate →
// elm-format → package elm.json → package.json), then exercises both gates:
//
//   regen-drift    — PASSES on the freshly-generated brand; FAILS after a single
//                    committed src file is perturbed (the NB5 staleness signal).
//   registry-check — the static coverage gate FAILS when a declared family dep
//                    (IR) is removed (NB1); PASSES on the correctly-stamped
//                    package; and, when elm + the IR/facts src are available, the
//                    package-shaped compile SUCCEEDS with deps staged and FAILS
//                    (MODULE NOT FOUND) when the IR dep is undeclared.
//
// Run standalone: `node tests/gates.test.mjs`

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, "..");
const cli = path.join(repo, "bin", "elm-cem.js");
const fixture = path.join(repo, "tests", "fixtures", "nonm3e.cem.json");
const IR = "jackhp95/elm-html-intermediate-representation";

let failures = 0;
const ok = (msg) => console.log(`gates-test: OK — ${msg}`);
const check = (cond, msg, extra = "") => {
  if (cond) ok(msg);
  else {
    console.error(`gates-test: FAIL — ${msg}${extra ? "\n" + extra : ""}`);
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
const factsSrc = path.join(repo, "facts", "src");

// ── Build a throwaway brand repo ──────────────────────────────────────────────
const brand = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-gates-"));
const brandSrc = path.join(brand, "src");
// Real brands keep their per-component config at config/slots.json — the path
// the regen-drift gate defaults to. Mirror that convention here.
fs.mkdirSync(path.join(brand, "config"), { recursive: true });
fs.writeFileSync(path.join(brand, "config", "slots.json"), JSON.stringify({ _phantom: true }));
// A brand ships its CEM in the repo; point package.json config.cem at a copy.
fs.copyFileSync(fixture, path.join(brand, "custom-elements.json"));
fs.writeFileSync(
  path.join(brand, "package.json"),
  JSON.stringify({ name: "elm-wc-test", config: { cem: "custom-elements.json" } }, null, 2)
);
// Seed a package elm.json; the generator stamps exposed-modules + family deps.
fs.writeFileSync(
  path.join(brand, "elm.json"),
  JSON.stringify(
    {
      type: "package",
      name: "jackhp95/elm-wc",
      summary: "gates test brand",
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
  [cli, `--flags-from=${path.join(brand, "custom-elements.json")}`, "--config-from=config/slots.json", `--output=${brandSrc}`],
  { cwd: brand, encoding: "utf8" }
);
if (gen.status !== 0) {
  console.error(gen.stdout, gen.stderr);
  console.error("gates-test: FAIL — could not generate the test brand");
  process.exit(1);
}
if (fs.existsSync(elmFormat)) spawnSync(elmFormat, [brandSrc, "--yes"], { encoding: "utf8" });

const runGate = (sub, args = []) =>
  spawnSync("node", [cli, sub, ...args], { cwd: brand, encoding: "utf8" });

// ── regen-drift ───────────────────────────────────────────────────────────────
{
  const clean = runGate("regen-drift");
  check(clean.status === 0, "regen-drift PASSES on a freshly-generated brand", clean.stdout + clean.stderr);

  // Perturb one committed src file.
  const barrel = fs.readdirSync(brandSrc).find((f) => f.endsWith(".elm"));
  const barrelPath = path.join(brandSrc, barrel);
  const original = fs.readFileSync(barrelPath, "utf8");
  fs.writeFileSync(barrelPath, original.replace("{-|", "{-| DRIFT"));
  const dirty = runGate("regen-drift");
  check(dirty.status === 1, "regen-drift FAILS when a committed src file is perturbed");
  fs.writeFileSync(barrelPath, original); // revert
  const reverted = runGate("regen-drift");
  check(reverted.status === 0, "regen-drift PASSES again after the perturbation is reverted");
}

// ── registry-check: static coverage gate (no elm needed) ─────────────────────
{
  // Exercise the static coverage gate deterministically (no elm required).
  const auditOnly = spawnSync(
    "node",
    ["-e", `process.exit(require(${JSON.stringify(path.join(repo, "bin", "family-deps.js"))}).auditPackage(${JSON.stringify(brand)}).length === 0 ? 0 : 1)`],
    { encoding: "utf8" }
  );
  check(auditOnly.status === 0, "registry-check static gate PASSES on the correctly-stamped brand");

  // Remove the IR dep → the static gate must fail (NB1).
  const elmJsonPath = path.join(brand, "elm.json");
  const saved = fs.readFileSync(elmJsonPath, "utf8");
  const j = JSON.parse(saved);
  delete j.dependencies[IR];
  fs.writeFileSync(elmJsonPath, JSON.stringify(j, null, 4) + "\n");
  const bad = runGate("registry-check");
  check(bad.status === 1 && /NB1|undeclared/.test(bad.stdout + bad.stderr), "registry-check FAILS when the IR dep is removed (NB1)");
  fs.writeFileSync(elmJsonPath, saved); // revert
}

// ── registry-check: package-shaped compile (needs elm + IR + facts) ──────────
if (!elm || !irSrc || !fs.existsSync(factsSrc)) {
  console.log(`gates-test: SKIP compile checks (elm=${!!elm} ir=${!!irSrc} facts=${fs.existsSync(factsSrc)})`);
} else {
  const good = runGate("registry-check", [`--elm=${elm}`, `--dep-src=${IR}=${irSrc}`, `--dep-src=jackhp95/elm-cem-facts=${factsSrc}`]);
  check(good.status === 0, "registry-check compile PASSES with family deps staged", good.stdout + good.stderr);

  // Undeclared-dep compile catch: drop IR, skip the static gate, prove the
  // package-shaped compile itself fails with an unresolved HtmlIr import.
  const elmJsonPath = path.join(brand, "elm.json");
  const saved = fs.readFileSync(elmJsonPath, "utf8");
  const j = JSON.parse(saved);
  delete j.dependencies[IR];
  fs.writeFileSync(elmJsonPath, JSON.stringify(j, null, 4) + "\n");
  const bad = runGate("registry-check", ["--no-audit", `--elm=${elm}`]);
  check(
    bad.status === 1 && /MODULE NOT FOUND|HtmlIr/.test(bad.stdout + bad.stderr),
    "registry-check compile FAILS (MODULE NOT FOUND) when IR is undeclared"
  );
  fs.writeFileSync(elmJsonPath, saved);
}

fs.rmSync(brand, { recursive: true, force: true });

if (failures > 0) {
  console.error(`\ngates-test: ${failures} FAILURE(S)`);
  process.exit(1);
}
console.log("\ngates-test: ALL GATES PASSED");
