// elm-cem validate — the docs-size gate (issue #50).
//
// Promotes elm-fluent-ui's validate.mjs (the audit's "best single-package gate")
// and folds in the per-brand measure-docs.mjs split-measurement fork. One
// subcommand, two shapes, chosen by whether the brand splits:
//
//   - No packages.json  → SINGLE-PACKAGE measure: stage the brand's own src/
//     (minus Review.*) + the unpublished IR source, `elm make --docs`, assert
//     docs.json <= 700 KB. (fluent / shoelace / web-awesome.)
//
//   - packages.json present → SPLIT measure: run `elm-cem split` into a temp
//     tree, then measure each emitted package's docs.json (staging its declared
//     family deps), asserting every package <= 700 KB. (the split brands.)
//
// Portable: elm + IR/facts sources resolved via node_modules + sibling layout
// (env overrides IR_SRC / FACTS_SRC). Run from a brand repo root.
//
// Usage:
//   elm-cem validate [--src=src] [--elm=<path>] [--emit-docs=docs.json] [--no-assert]
//   elm-cem validate --packages=packages.json [--split-out=<dir>] [--skip=<pkg> ...]

"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawnSync } = require("child_process");
const shared = require("./shared");
const family = require("./family-deps");

const CLI = path.join(__dirname, "elm-cem.js");
const DOCS_LIMIT = shared.DOCS_LIMIT;

function fail(msg) {
  console.error(`validate: FAIL — ${msg}`);
  process.exit(1);
}

function usage() {
  console.log(
    [
      "elm-cem validate — docs-size gate (single-package, or per-split-package if packages.json).",
      "",
      "Run from a brand repo root.",
      "",
      "Options:",
      "  --src=<dir>          generated source dir (default: src) [single-package mode]",
      "  --packages=<path>    packages.json → split-measure mode (default: packages.json if present)",
      "  --split-out=<dir>    where to emit the split tree (default: a temp dir)",
      "  --skip=<pkg>         skip a package by name/shortname (repeatable, comma-ok) [split mode]",
      "  --elm=<path>         elm 0.19.1 binary (auto-resolved)",
      "  --emit-docs=<path>   copy the produced docs.json here [single-package mode]",
      "  --no-assert          report sizes but never exit 1",
      "  -h, --help           show this help",
    ].join("\n")
  );
}

function parseArgs(argv) {
  const o = { skip: new Set() };
  for (const a of argv) {
    if (a === "-h" || a === "--help") o.help = true;
    else if (a === "--no-assert") o.noAssert = true;
    else if (a.startsWith("--src=")) o.src = a.slice("--src=".length);
    else if (a.startsWith("--packages=")) o.packages = a.slice("--packages=".length);
    else if (a.startsWith("--split-out=")) o.splitOut = a.slice("--split-out=".length);
    else if (a.startsWith("--elm=")) o.elm = a.slice("--elm=".length);
    else if (a.startsWith("--emit-docs=")) o.emitDocs = a.slice("--emit-docs=".length);
    else if (a.startsWith("--skip=")) a.slice("--skip=".length).split(",").forEach((s) => s.trim() && o.skip.add(s.trim()));
    else fail(`unknown argument: ${a}`);
  }
  return o;
}

// Build a package-shaped measurement dir (own modules + vendored dep sources)
// and return docs.json byte size. `deps` is the external published deps object.
function measurePackage(elm, name, summary, ownSrc, exposed, vendorSrcs, deps) {
  const mDir = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-validate-"));
  const mSrc = path.join(mDir, "src");
  fs.mkdirSync(mSrc, { recursive: true });
  shared.copyDir(ownSrc, mSrc, (rel, isDir) => (isDir || rel.endsWith(".elm")) && !/(^|\/)Review(\/|$)/.test(rel));
  for (const v of vendorSrcs) shared.copyDir(v, mSrc, (rel, isDir) => isDir || rel.endsWith(".elm"));

  // The vendored IR/facts sources carry their own elm/* import needs (e.g.
  // HtmlIr.Internal imports VirtualDom), which the brand's package elm.json may
  // not declare directly. Floor the measurement deps with the family base set
  // (core/html/json/virtual-dom) — the same set registry-check compiles against.
  const externalDeps = { ...family.baseDependencies(), ...deps };
  delete externalDeps["jackhp95/elm-virtual-dom-intermediate-representation"];
  delete externalDeps["jackhp95/elm-cem-facts"];

  const elmJson = {
    type: "package",
    name: name || "registry/check",
    summary: summary || name || "docs-size measurement",
    license: "BSD-3-Clause",
    version: "1.0.0",
    "exposed-modules": [...exposed].sort(),
    "elm-version": "0.19.0 <= v < 0.20.0",
    dependencies: externalDeps,
    "test-dependencies": {},
  };
  fs.writeFileSync(path.join(mDir, "elm.json"), JSON.stringify(elmJson, null, 4) + "\n");

  const docsPath = path.join(mDir, "docs.json");
  const r = spawnSync(elm, ["make", "--docs", docsPath, "--output=/dev/null"], {
    cwd: mDir,
    encoding: "utf8",
    stdio: "pipe",
  });
  if (r.status !== 0) {
    console.error((r.stdout || "").slice(0, 4000));
    console.error((r.stderr || "").slice(0, 4000));
    fs.rmSync(mDir, { recursive: true, force: true });
    fail(`elm make --docs failed for ${name}`);
  }
  const bytes = fs.statSync(docsPath).size;
  return { bytes, docsPath, mDir };
}

function runSinglePackage(o, elm, cwd) {
  const srcDir = path.resolve(cwd, o.src || "src");
  if (!fs.existsSync(srcDir)) fail(`src dir not found: ${srcDir}`);
  const irSrc = shared.resolveIrSrc();
  if (!irSrc) fail("IR source not found — set IR_SRC or place the IR repo as a sibling.");

  const elmJson = JSON.parse(fs.readFileSync(path.resolve(cwd, "elm.json"), "utf8"));
  const exposed = shared.walkElmModules(srcDir);
  const vendorSrcs = [irSrc];
  const factsSrc = shared.resolveFactsSrc();
  if (factsSrc && (elmJson.dependencies || {})["jackhp95/elm-cem-facts"]) vendorSrcs.push(factsSrc);

  const { bytes, docsPath, mDir } = measurePackage(
    elm,
    elmJson.name,
    elmJson.summary,
    srcDir,
    exposed,
    vendorSrcs,
    elmJson.dependencies || {}
  );
  const pct = ((bytes / DOCS_LIMIT) * 100).toFixed(1);
  const over = bytes > DOCS_LIMIT;
  console.log(`validate: ${elmJson.name} — ${exposed.length} exposed module(s)`);
  console.log(`validate: docs.json = ${bytes.toLocaleString()} B (${pct}% of ${DOCS_LIMIT.toLocaleString()}) ${over ? "OVER LIMIT" : "ok"}`);
  if (o.emitDocs) {
    fs.copyFileSync(docsPath, path.resolve(cwd, o.emitDocs));
    console.log(`validate: wrote ${o.emitDocs}`);
  }
  fs.rmSync(mDir, { recursive: true, force: true });
  if (over && !o.noAssert) fail("docs.json exceeds the size limit — author packages.json and split.");
  console.log("validate: PASS");
}

function runSplit(o, elm, cwd, packagesPath) {
  const spec = JSON.parse(fs.readFileSync(packagesPath, "utf8"));
  const packages = spec.packages || [];
  const srcDir = path.resolve(cwd, o.src || "src");

  const splitOut = o.splitOut
    ? path.resolve(cwd, o.splitOut)
    : fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-validate-split-"));
  console.log(`validate: split-measure via ${path.relative(cwd, packagesPath)} → ${path.relative(cwd, splitOut) || splitOut}`);
  const s = spawnSync("node", [CLI, "split", `--packages=${packagesPath}`, `--src=${srcDir}`, `--out=${splitOut}`], {
    cwd,
    encoding: "utf8",
    stdio: "inherit",
  });
  if (s.status !== 0) fail("split failed (see output above).");

  const irSrc = shared.resolveIrSrc();
  const factsSrc = shared.resolveFactsSrc();
  // family shortname -> emitted split src dir (for transitive vendoring)
  const familySrc = {};
  for (const p of packages) {
    const short = p.name.split("/")[1];
    const cand = path.join(splitOut, short, "src");
    if (fs.existsSync(cand)) familySrc[p.name] = cand;
  }

  const transitive = (name, seen = new Set()) => {
    if (seen.has(name)) return seen;
    seen.add(name);
    const p = packages.find((x) => x.name === name);
    if (p) for (const d of Object.keys(p.deps || {})) transitive(d, seen);
    return seen;
  };

  let anyOver = false;
  for (const p of packages) {
    const short = p.name.split("/")[1];
    // Skip the review-facts contract package: its only module is `<Lib>.Review.Facts`,
    // which measurePackage's copy filter strips (it drops every Review/ module), so the
    // measurement elm.json would expose nothing and `elm make --docs` would fail with
    // "NO INPUT". A single-module facts contract is trivially under the size cap; the
    // gate that actually keeps it publishable is registry-check (check-split.mjs), not
    // this docs-size measure. Match on `facts` too (some brands name it `<fam>-facts`
    // rather than `<fam>-review-facts`).
    if (/review|facts/i.test(p.name) || o.skip.has(p.name) || o.skip.has(short)) {
      console.log(`  SKIP  ${p.name} (review-facts or --skip)`);
      continue;
    }
    const pkgSrc = path.join(splitOut, short, "src");
    if (!fs.existsSync(pkgSrc)) {
      console.log(`  WARN  ${p.name} not in split output; skipping`);
      continue;
    }
    // Vendor sources: family deps (from split output), plus IR/facts when declared.
    const vendorSrcs = [];
    const deps = transitive(p.name);
    deps.delete(p.name);
    for (const d of deps) {
      if (familySrc[d]) vendorSrcs.push(familySrc[d]);
      else if (d === "jackhp95/elm-virtual-dom-intermediate-representation" && irSrc) vendorSrcs.push(irSrc);
      else if (d === "jackhp95/elm-cem-facts" && factsSrc) vendorSrcs.push(factsSrc);
    }
    // Also stage IR/facts if this package's own deps declare them.
    for (const d of Object.keys(p.deps || {})) {
      if (d === "jackhp95/elm-virtual-dom-intermediate-representation" && irSrc && !vendorSrcs.includes(irSrc)) vendorSrcs.push(irSrc);
      if (d === "jackhp95/elm-cem-facts" && factsSrc && !vendorSrcs.includes(factsSrc)) vendorSrcs.push(factsSrc);
    }
    // External deps only: drop every family-internal dep (it is vendored into
    // src/ above, so declaring it as a published dep makes elm reject the
    // measurement elm.json as "incompatible dependencies").
    const familyNames = new Set(packages.map((x) => x.name));
    const externalDeps = {};
    for (const [dep, range] of Object.entries(p.deps || {})) {
      if (!familyNames.has(dep)) externalDeps[dep] = range;
    }
    const exposed = shared.walkElmModules(pkgSrc);
    const { bytes, mDir } = measurePackage(elm, p.name, p.summary, pkgSrc, exposed, vendorSrcs, externalDeps);
    const pct = ((bytes / DOCS_LIMIT) * 100).toFixed(1);
    const over = bytes > DOCS_LIMIT;
    if (over) anyOver = true;
    console.log(`  ${(over ? "OVER" : "ok").padEnd(4)}  ${p.name.padEnd(34)} ${bytes.toLocaleString().padStart(10)} B (${pct}%)`);
    fs.rmSync(mDir, { recursive: true, force: true });
  }

  if (!o.splitOut) fs.rmSync(splitOut, { recursive: true, force: true });
  console.log(`\nvalidate: DOCS_LIMIT = ${DOCS_LIMIT.toLocaleString()} B`);
  if (anyOver && !o.noAssert) fail("one or more split packages exceed the docs-size limit.");
  console.log("validate: PASS — all measured packages within the docs-size limit.");
}

function run(argv) {
  const o = parseArgs(argv);
  if (o.help) {
    usage();
    process.exit(0);
  }
  const cwd = process.cwd();
  const elm = o.elm ? path.resolve(cwd, o.elm) : shared.resolveBin("elm");
  if (!elm || !fs.existsSync(elm)) fail("elm binary not found — pass --elm=<path> or run `elm-tooling install`.");

  const packagesPath = o.packages
    ? path.resolve(cwd, o.packages)
    : fs.existsSync(path.join(cwd, "packages.json"))
      ? path.join(cwd, "packages.json")
      : null;

  if (packagesPath) runSplit(o, elm, cwd, packagesPath);
  else runSinglePackage(o, elm, cwd);
}

module.exports = { run };

// Direct invocation must do the same work as `elm-cem <subcommand>`. Without this
// guard the file loads, exports `run`, calls nothing, prints nothing and exits 0 —
// a gate reporting success without doing its work, which is precisely the failure
// these scripts exist to prevent. It nearly banked a false "verified" once: an
// agent checking elm-review-cem's neutrality gate ran this file directly, got a
// clean exit 0, and only doubted it because an expected log line never printed.
if (require.main === module) run(process.argv.slice(2));
