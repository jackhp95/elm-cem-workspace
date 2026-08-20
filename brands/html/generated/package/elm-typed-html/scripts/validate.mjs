#!/usr/bin/env node
// validate.mjs — elm make --docs gate for elm-typed-html.
//
// Two gates, in order:
//   1. a manifest pre-flight — no attribute name may carry two different
//      `type.text` values across elements (the `datetime` regression backstop);
//   2. the docs-size gate below.
//
// Assembles a temp measurement dir:
//   - package-type elm.json (copy of this repo's elm.json)
//   - src/ = this repo's src/ + the IR sibling (jackhp95/elm-html-intermediate-representation)
// Runs `elm make --docs /tmp/th-docs.json` and reports the byte count.
//
// Usage:
//   node scripts/validate.mjs [--elm=<path>] [--ir=<path>] [--no-assert]
//
//   --elm=<path>   path to elm 0.19.1 binary (default: node_modules/.bin/elm)
//   --ir=<path>    path to elm-html-intermediate-representation/src
//                  (default: ../../elm-html-intermediate-representation/src, relative to this repo)
//   --no-assert    report only; do not fail on docs-size violations
//
// The docs-size is reported; a DOCS_LIMIT of 700,000 bytes triggers failure
// unless --no-assert is passed.

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(here, "..");

const DOCS_LIMIT = 700_000;

// ── Parse flags ───────────────────────────────────────────────────────────────
const rawArgs = process.argv.slice(2);

function argVal(prefix) {
  const a = rawArgs.find((x) => x.startsWith(prefix));
  return a ? a.slice(prefix.length) : null;
}

const noAssert = rawArgs.includes("--no-assert");

// Locate elm binary
const elmArg = argVal("--elm=");
const elmBin = elmArg
  ? path.resolve(repoRoot, elmArg)
  : path.join(repoRoot, "node_modules", ".bin", "elm");

if (!fs.existsSync(elmBin)) {
  console.error(`validate: cannot find elm binary at ${elmBin}`);
  console.error("         Install deps first: npm ci");
  process.exit(1);
}

// Locate IR src
const irArg = argVal("--ir=");
const irSrc = irArg
  ? path.resolve(repoRoot, irArg)
  : path.resolve(repoRoot, "../../../../../packages/elm-virtual-dom-intermediate-representation/src");

if (!fs.existsSync(irSrc)) {
  console.error(`validate: cannot find elm-html-intermediate-representation/src at ${irSrc}`);
  console.error("          Clone the sibling repo or pass --ir=<path>");
  process.exit(1);
}

// Locate elm-cem-facts src (provides Cem.Facts, imported by the exposed
// TypedHtml.Review.Facts module). Extracted into its own package by elm-cem #42.
const factsArg = argVal("--facts=");
const factsSrc = factsArg
  ? path.resolve(repoRoot, factsArg)
  : path.resolve(repoRoot, "../../../../../pipeline/elm-cem/facts/src");

if (!fs.existsSync(factsSrc)) {
  console.error(`validate: cannot find elm-cem-facts/src at ${factsSrc}`);
  console.error("          Clone the elm-cem repo or pass --facts=<path>");
  process.exit(1);
}

// ── Manifest pre-flight: one attribute name, one type ─────────────────────────
//
// A backstop for the `datetime` regression. The manifest declared `datetime` as
// `string` on <ins>/<del> and `number` on <time>; all three live in the `Text`
// home module, which emits ONE re-exported setter per attribute name. The two
// specs were silently reduced to one and <time>'s `Float` was published for all
// three, so `<ins datetime="2024-01-01">` became unexpressible.
//
// The generator now REFUSES to emit in that situation (elm-cem
// `Emit.guardHomeAttrTypes`). This check is the second line: it names the drift in
// the curated INPUT, before a generator run, and it fires for a cross-home conflict
// too — which the generator only reports as an info note, because there each element
// legitimately keeps its own locally-typed setter.
//
// Two elements MAY agree on a type and differ in prose; only `type.text` is compared.
const manifest = JSON.parse(
  fs.readFileSync(path.join(repoRoot, "manifest", "native.cem.json"), "utf8")
);

const typesByAttr = new Map(); // attr name -> Map<type.text, string[] element names>
for (const decl of manifest.modules.flatMap((m) => m.declarations ?? [])) {
  for (const attr of decl.attributes ?? []) {
    const type = attr.type?.text ?? "(untyped)";
    if (!typesByAttr.has(attr.name)) typesByAttr.set(attr.name, new Map());
    const byType = typesByAttr.get(attr.name);
    if (!byType.has(type)) byType.set(type, []);
    byType.get(type).push(decl.name);
  }
}

const conflicts = [...typesByAttr.entries()]
  .filter(([, byType]) => byType.size > 1)
  .sort(([a], [b]) => a.localeCompare(b));

if (conflicts.length > 0) {
  console.error(
    "validate: FAIL — one attribute name carries two different `type.text` values across elements."
  );
  console.error(
    "          One Elm module cannot expose one setter at two types, so the generator either"
  );
  console.error(
    "          refuses to emit or publishes exactly one of them. Make the curation agree."
  );
  for (const [name, byType] of conflicts) {
    const shown = [...byType.entries()]
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([type, els]) => `${type} (${els.sort().join(", ")})`)
      .join("  vs  ");
    console.error(`  - ${name}: ${shown}`);
  }
  process.exit(1);
}

console.log(
  `validate: manifest OK — ${typesByAttr.size} attribute names, each with one \`type.text\`.`
);

// ── Read this repo's elm.json ─────────────────────────────────────────────────
const elmJsonPath = path.join(repoRoot, "elm.json");
const elmJson = JSON.parse(fs.readFileSync(elmJsonPath, "utf8"));

// The generator stamps the sibling jackhp95/* packages (IR + facts) as real
// deps (elm-cem #48), but they are not on the registry yet. For the docs gate
// we compile their src in-tree instead, so strip those deps from the temp
// elm.json — elm rejects declared-but-unpublishable dependencies.
if (elmJson.dependencies) {
  elmJson.dependencies = Object.fromEntries(
    Object.entries(elmJson.dependencies).filter(([name]) => name.startsWith("elm/"))
  );
}

// ── Assemble temp dir ─────────────────────────────────────────────────────────
const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "elm-typed-html-validate-"));
const tmpSrc = path.join(tmpDir, "src");
fs.mkdirSync(tmpSrc, { recursive: true });

// Copy this repo's src/ (the generated TypedHtml modules)
copyDir(path.join(repoRoot, "src"), tmpSrc);

// Copy the IR src/ (HtmlIr.* modules needed at compile time)
copyDir(irSrc, tmpSrc);

// Copy the elm-cem-facts src/ (Cem.Facts, imported by TypedHtml.Review.Facts)
copyDir(factsSrc, tmpSrc);

// Write the package elm.json into the temp dir (verbatim copy is fine)
fs.writeFileSync(
  path.join(tmpDir, "elm.json"),
  JSON.stringify(elmJson, null, 4) + "\n"
);

const docsOut = path.join(tmpDir, "docs.json");

console.log(`validate: elm     = ${elmBin}`);
console.log(`validate: IR src  = ${irSrc}`);
console.log(`validate: tmp dir = ${tmpDir}`);
console.log();

// ── Run elm make --docs ───────────────────────────────────────────────────────
const r = spawnSync(elmBin, ["make", "--docs", docsOut], {
  cwd: tmpDir,
  encoding: "utf8",
  stdio: "pipe",
});

if (r.status !== 0) {
  console.error("validate: FAIL — elm make --docs failed");
  if (r.stderr) console.error(r.stderr.slice(0, 5000));
  if (r.stdout) console.error(r.stdout.slice(0, 2000));
  fs.rmSync(tmpDir, { recursive: true, force: true });
  process.exit(1);
}

if (!fs.existsSync(docsOut)) {
  console.error("validate: FAIL — docs.json was not produced");
  fs.rmSync(tmpDir, { recursive: true, force: true });
  process.exit(1);
}

const bytes = fs.statSync(docsOut).size;
const pct = ((bytes / DOCS_LIMIT) * 100).toFixed(1);
const over = bytes > DOCS_LIMIT;
const flag = over ? "OVER LIMIT" : bytes > DOCS_LIMIT * 0.9 ? "tight" : "ok";

console.log(`validate: docs.json = ${bytes.toLocaleString()} B  (${pct}% of ${DOCS_LIMIT.toLocaleString()} B limit)  [${flag}]`);

if (over && !noAssert) {
  console.error("\nvalidate: GATE FAIL — docs.json exceeds the docs-size limit.");
  fs.rmSync(tmpDir, { recursive: true, force: true });
  process.exit(1);
}

console.log("validate: PASS — all exposed modules compile, docs.json produced.");
fs.rmSync(tmpDir, { recursive: true, force: true });

// ── Helpers ───────────────────────────────────────────────────────────────────
function copyDir(src, dst) {
  if (!fs.existsSync(src)) return;
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcFull = path.join(src, entry.name);
    const dstFull = path.join(dst, entry.name);
    if (entry.isDirectory()) {
      fs.mkdirSync(dstFull, { recursive: true });
      copyDir(srcFull, dstFull);
    } else {
      fs.copyFileSync(srcFull, dstFull);
    }
  }
}
