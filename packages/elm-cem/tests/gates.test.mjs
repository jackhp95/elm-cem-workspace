#!/usr/bin/env node
// Release gates: regen-drift + registry-check (issue #49, findings NB5 + B2/NB1).
//
// Builds a throwaway brand repo from the committed wc-widgets fixture (finding 2.6: named for its actual brand, not "not-m3e" — M3E is not the default here) (generate →
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
import { repo, makeCheck } from "./lib/harness.mjs";

const cli = path.join(repo, "bin", "elm-cem.js");
const fixture = path.join(repo, "tests", "fixtures", "wc-widgets.cem.json");
const IR = "jackhp95/elm-html-intermediate-representation";

const { check, finish } = makeCheck("gates-test");

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

// A SEPARATE throwaway brand, isolated from `brand` above, whose config also
// declares `_iconModule.package` so the generator writes a standalone nested
// package (elm-m3e batch-2's `elm-m3e-icons` pattern). Kept separate so the
// nested-pkg tests below don't leak an extra exposed module into `brand`'s
// elm.json and perturb the unrelated registry-check compile assertions further
// down this file (bit us once — see the `--nested-pkg` test block's history).
const brandIcons = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-gates-icons-"));
const brandIconsSrc = path.join(brandIcons, "src");
fs.mkdirSync(path.join(brandIcons, "config"), { recursive: true });
fs.writeFileSync(path.join(brandIcons, "config", "icons-catalog.json"), JSON.stringify({ names: ["menu", "close"] }));
fs.writeFileSync(
  path.join(brandIcons, "config", "slots.json"),
  JSON.stringify({
    _phantom: true,
    _iconModule: {
      lib: "Wc",
      iconComp: "Icon",
      catalogFrom: "config/icons-catalog.json",
      // Deliberately NOT "m3e-icon"/"Material Symbols" — this is the
      // non-M3E fixture proving finding 2.1 is fixed: gen-icon-module.js
      // must emit THIS tag/prose, not M3E's, and must fail loud without them.
      tag: "wc-icon",
      iconFamily: "Test Icons",
      package: {
        dir: "wc-icons",
        name: "test/wc-icons",
        summary: "test nested icon package",
        version: "1.0.0",
        deps: { "elm/core": "1.0.0 <= v < 2.0.0", "elm/html": "1.0.0 <= v < 2.0.0" },
      },
    },
  })
);
fs.copyFileSync(fixture, path.join(brandIcons, "custom-elements.json"));
fs.writeFileSync(
  path.join(brandIcons, "package.json"),
  JSON.stringify({ name: "elm-wc-icons-test", config: { cem: "custom-elements.json" } }, null, 2)
);
const genIcons = spawnSync(
  "node",
  [
    cli,
    `--flags-from=${path.join(brandIcons, "custom-elements.json")}`,
    "--config-from=config/slots.json",
    `--output=${brandIconsSrc}`,
  ],
  { cwd: brandIcons, encoding: "utf8" }
);
if (genIcons.status !== 0) {
  console.error(genIcons.stdout, genIcons.stderr);
  console.error("gates-test: FAIL — could not generate the nested-pkg test brand");
  process.exit(1);
}

// finding 2.1 (2026-08-17 thermonuclear review): gen-icon-module.js used to
// hardcode M3E's "m3e-icon" tag and "Material Symbols" prose regardless of
// brand. Prove the non-M3E "Wc" fixture above gets ITS OWN tag/prose, not M3E's.
{
  const wcIconSrc = fs.readFileSync(path.join(brandIconsSrc, "Wc", "Icon.elm"), "utf8");
  check(wcIconSrc.includes("wc-icon"), "gen-icon-module emits the config-driven tag (\"wc-icon\") for a non-M3E brand");
  check(wcIconSrc.includes("Test Icons"), "gen-icon-module emits the config-driven iconFamily (\"Test Icons\") for a non-M3E brand");
  check(!wcIconSrc.includes("m3e-icon"), "gen-icon-module does NOT leak M3E's \"m3e-icon\" tag into a non-M3E brand's output");
  check(!wcIconSrc.includes("Material Symbols"), "gen-icon-module does NOT leak M3E's \"Material Symbols\" prose into a non-M3E brand's output");
}

// A brand that declares _iconModule without tag/iconFamily must fail loud,
// not silently fall back to M3E's defaults (the exact bug finding 2.1 named).
{
  const brandNoTag = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-gates-icons-notag-"));
  fs.mkdirSync(path.join(brandNoTag, "config"), { recursive: true });
  fs.writeFileSync(path.join(brandNoTag, "config", "icons-catalog.json"), JSON.stringify({ names: ["menu"] }));
  fs.writeFileSync(
    path.join(brandNoTag, "config", "slots.json"),
    JSON.stringify({ _phantom: true, _iconModule: { lib: "Wc", iconComp: "Icon", catalogFrom: "config/icons-catalog.json" } })
  );
  fs.copyFileSync(fixture, path.join(brandNoTag, "custom-elements.json"));
  fs.writeFileSync(
    path.join(brandNoTag, "package.json"),
    JSON.stringify({ name: "elm-wc-icons-notag-test", config: { cem: "custom-elements.json" } }, null, 2)
  );
  const genNoTag = spawnSync(
    "node",
    [
      cli,
      `--flags-from=${path.join(brandNoTag, "custom-elements.json")}`,
      "--config-from=config/slots.json",
      `--output=${path.join(brandNoTag, "src")}`,
    ],
    { cwd: brandNoTag, encoding: "utf8" }
  );
  check(
    genNoTag.status !== 0 && /_iconModule\.tag/.test(genNoTag.stdout + genNoTag.stderr),
    "gen-icon-module FAILS LOUD (not a silent M3E-flavored default) when _iconModule.tag/iconFamily are missing",
    genNoTag.stdout + genNoTag.stderr
  );
}

const nestedPkgSrc = path.join(brandIcons, "wc-icons", "src");
if (fs.existsSync(elmFormat)) {
  spawnSync(elmFormat, [brandIconsSrc, "--yes"], { encoding: "utf8" });
  if (fs.existsSync(nestedPkgSrc)) spawnSync(elmFormat, [nestedPkgSrc, "--yes"], { encoding: "utf8" });
}
const runGateIcons = (sub, args = []) => spawnSync("node", [cli, sub, ...args], { cwd: brandIcons, encoding: "utf8" });

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

// ── regen-drift --nested-pkg (elm-m3e-icons drift-gap fix) ───────────────────
// The generator also writes a standalone `wc-icons/` package (config-driven via
// `_iconModule.package`, mirroring elm-m3e's real `elm-m3e-icons`). Without
// --nested-pkg, regen-drift never looks at it — this proves --nested-pkg=wc-icons
// closes that blind spot the same way the root src/ check works.
{
  check(fs.existsSync(nestedPkgSrc), "nested package src/ was written by the generator (test setup sanity)");

  const clean = runGateIcons("regen-drift", ["--nested-pkg=wc-icons"]);
  check(
    clean.status === 0,
    "regen-drift --nested-pkg=wc-icons PASSES on a freshly-generated nested package",
    clean.stdout + clean.stderr
  );

  // Without --nested-pkg at all, a nested-package perturbation must NOT be caught
  // (documents the gap this feature closes — the root-only gate stays green).
  const nestedFile = path.join(nestedPkgSrc, "Wc", "Icon.elm");
  const nestedOriginal = fs.readFileSync(nestedFile, "utf8");
  fs.writeFileSync(nestedFile, nestedOriginal.replace("{-|", "{-| DRIFT"));
  const rootOnlyBlind = runGateIcons("regen-drift"); // no --nested-pkg
  check(
    rootOnlyBlind.status === 0,
    "regen-drift WITHOUT --nested-pkg stays green on nested-package drift (the pre-fix blind spot)"
  );

  // With --nested-pkg, the same perturbation must FAIL and name the package.
  const nestedDirty = runGateIcons("regen-drift", ["--nested-pkg=wc-icons"]);
  check(
    nestedDirty.status === 1 && /wc-icons/.test(nestedDirty.stdout + nestedDirty.stderr),
    "regen-drift --nested-pkg=wc-icons FAILS and names the package when its committed src is perturbed",
    nestedDirty.stdout + nestedDirty.stderr
  );

  fs.writeFileSync(nestedFile, nestedOriginal); // revert
  const nestedReverted = runGateIcons("regen-drift", ["--nested-pkg=wc-icons"]);
  check(
    nestedReverted.status === 0,
    "regen-drift --nested-pkg=wc-icons PASSES again after the nested perturbation is reverted"
  );

  // A configured-but-missing nested package must fail loudly, not silently pass.
  const missing = runGateIcons("regen-drift", ["--nested-pkg=does-not-exist"]);
  check(
    missing.status === 1 && /does-not-exist/.test(missing.stdout + missing.stderr),
    "regen-drift --nested-pkg=<missing dir> FAILS loudly instead of silently skipping"
  );
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
fs.rmSync(brandIcons, { recursive: true, force: true });

finish("\ngates-test: ALL GATES PASSED");
