#!/usr/bin/env node
// elm-cem split — facet-family package splitter (WS7 / CX11/CX12).
//
// Usage:
//   elm-cem split --packages=<packages.json> --src=<dir> --out=<dir>
//
// Reads a packages.json that describes how to partition a generated Elm source
// tree into per-facet packages. For each package:
//   1. Assigns every .elm module to exactly one package (totality + disjointness)
//   2. Verifies no import violates the declared dep DAG (DAG-respect)
//   3. Emits a mirror tree: per-package elm.json + partitioned src/ + README.md + LICENSE
//
// Isolation probes and docs-size gates run separately (scripts/isolation-probe.mjs
// and scripts/measure-docs.mjs in the consuming repo) because they need the elm
// binary and take longer than the structural split checks.
//
// packages.json schema:
//   {
//     "family": "<short-name>",         // used in log messages
//     "devRepo": "<owner>/<repo>",       // for the copy-only banner
//     "licenseText": "<full text>",      // written to LICENSE in each mirror
//     "packages": [
//       {
//         "name": "<owner>/<pkg>",       // elm package name (placeholder pre-Stage-F)
//         "summary": "<short summary>",
//         "version": "1.0.0",
//         "elmVersion": "0.19.0 <= v < 0.20.0",
//         "deps": {                      // family-internal AND external deps
//           "<owner>/<pkg>": "<range>"   // range like "1.0.0 <= v < 2.0.0"
//         },
//         "buckets": [                   // assignment rules (first match wins)
//           { "prefix": "<ModulePrefix>" },  // module name starts with this
//           { "exact": "<ModuleName>" }       // module name equals this exactly
//         ],
//         "exposeInternal": [            // OPTIONAL: force-expose designated
//           "<Lib>.Forge.Internal",       // *.Internal modules despite the blanket
//           "<Lib>.Internal.Types."        // Internal filter, so a dependent package
//         ]                               // can import them across the boundary
//       }                                 // (fenced by elm-review, exactly like
//     ]                                   // elm/html-ir exposes HtmlIr.Internal). An
//   }                                     // entry ending in "." is a PREFIX (matches
//                                         // every module under it); otherwise EXACT.
//                                         // Each entry MUST match >=1 module routed to
//                                         // this package by its buckets, else GATE FAIL.

"use strict";

const fs = require("fs");
const path = require("path");

module.exports = { run };

function run(argv) {
  // Parse flags
  let packagesPath = null;
  let srcDir = null;
  let outDir = null;

  for (const a of argv) {
    if (a.startsWith("--packages=")) packagesPath = a.slice("--packages=".length);
    else if (a.startsWith("--src=")) srcDir = a.slice("--src=".length);
    else if (a.startsWith("--out=")) outDir = a.slice("--out=".length);
  }

  if (!packagesPath || !srcDir || !outDir) {
    console.error(
      "elm-cem split: usage: elm-cem split --packages=<packages.json> --src=<src-dir> --out=<out-dir>"
    );
    process.exit(1);
  }

  // Resolve paths relative to cwd
  packagesPath = path.resolve(process.cwd(), packagesPath);
  srcDir = path.resolve(process.cwd(), srcDir);
  outDir = path.resolve(process.cwd(), outDir);

  // Load packages.json
  let pkgsSpec;
  try {
    pkgsSpec = JSON.parse(fs.readFileSync(packagesPath, "utf8"));
  } catch (e) {
    console.error(`elm-cem split: cannot read packages.json: ${e.message}`);
    process.exit(1);
  }

  const packages = pkgsSpec.packages || [];
  const devRepo = pkgsSpec.devRepo || "the dev repo";
  const family = pkgsSpec.family || "elm";
  const licenseText = pkgsSpec.licenseText || "";

  // ── 1. Discover all source modules ──────────────────────────────────────────
  const allModules = {}; // moduleName → absolute src path
  walkElm(srcDir, (abs) => {
    const rel = path.relative(srcDir, abs);
    const name = rel.replace(/\.elm$/, "").split(path.sep).join(".");
    allModules[name] = abs;
  });

  const totalModules = Object.keys(allModules).length;
  console.log(`elm-cem split: found ${totalModules} modules in ${srcDir}`);

  // ── 2. Assign modules to packages ───────────────────────────────────────────
  const modToPkg = {}; // moduleName → package name
  const pkgMods = {}; // package name → [moduleName]

  for (const pkg of packages) {
    pkgMods[pkg.name] = [];
  }

  for (const modName of Object.keys(allModules).sort()) {
    let assigned = null;
    for (const pkg of packages) {
      for (const bucket of pkg.buckets || []) {
        if (bucket.prefix && modName.startsWith(bucket.prefix)) {
          assigned = pkg.name;
          break;
        }
        if (bucket.exact && modName === bucket.exact) {
          assigned = pkg.name;
          break;
        }
      }
      if (assigned) break;
    }
    if (!assigned) {
      console.error(`elm-cem split: GATE FAIL — totality violation: module ${modName} not matched by any package bucket`);
      process.exit(1);
    }
    modToPkg[modName] = assigned;
    pkgMods[assigned].push(modName);
  }

  // ── Gate: totality ───────────────────────────────────────────────────────────
  const placed = Object.values(modToPkg).length;
  if (placed !== totalModules) {
    console.error(`elm-cem split: GATE FAIL — totality: ${placed} placed vs ${totalModules} total`);
    process.exit(1);
  }
  console.log(`elm-cem split: totality OK (${placed} modules placed)`);

  // ── Gate: disjointness (each module in exactly one package) ─────────────────
  // Already guaranteed by first-match-wins, but verify
  const seen = new Set();
  for (const [mod, pkg] of Object.entries(modToPkg)) {
    if (seen.has(mod)) {
      console.error(`elm-cem split: GATE FAIL — disjointness: ${mod} assigned to two packages`);
      process.exit(1);
    }
    seen.add(mod);
  }
  console.log("elm-cem split: disjointness OK");

  // ── Gate: DAG-respect ────────────────────────────────────────────────────────
  // Build transitive dep closure for each package
  function transitiveAllowed(pkgName) {
    const pkg = packages.find(p => p.name === pkgName);
    if (!pkg) return new Set();
    const allowed = new Set(Object.keys(pkg.deps || {}));
    for (const dep of Object.keys(pkg.deps || {})) {
      for (const t of transitiveAllowed(dep)) allowed.add(t);
    }
    return allowed;
  }

  const impRe = /^import\s+([A-Za-z0-9_.]+)/gm;
  const dagViolations = [];

  for (const pkg of packages) {
    const allowed = transitiveAllowed(pkg.name);
    for (const modName of pkgMods[pkg.name]) {
      const src = fs.readFileSync(allModules[modName], "utf8");
      let m;
      impRe.lastIndex = 0;
      while ((m = impRe.exec(src)) !== null) {
        const imp = m[1];
        const tgtPkg = modToPkg[imp];
        if (!tgtPkg) continue;           // external dep (elm/core etc.)
        if (tgtPkg === pkg.name) continue; // same package
        if (!allowed.has(tgtPkg)) {
          dagViolations.push(`  ${modName} [${pkg.name}] imports ${imp} [${tgtPkg}]`);
        }
      }
    }
  }

  if (dagViolations.length > 0) {
    console.error("elm-cem split: GATE FAIL — DAG violations:");
    dagViolations.slice(0, 40).forEach(v => console.error(v));
    process.exit(1);
  }
  console.log("elm-cem split: DAG-respect OK");

  // ── 3. Emit mirror trees ─────────────────────────────────────────────────────
  fs.mkdirSync(outDir, { recursive: true });

  for (const pkg of packages) {
    const shortName = pkg.name.split("/")[1];
    const pkgDir = path.join(outDir, shortName);
    const pkgSrcDir = path.join(pkgDir, "src");
    fs.mkdirSync(pkgSrcDir, { recursive: true });

    // Copy source files
    const exposedModules = [];
    // Designated cross-package internal modules to expose despite the blanket
    // Internal filter (see schema `exposeInternal`). An entry ending in "." is a
    // prefix; otherwise it is an exact module name. Validate that each entry
    // matches >=1 routed module — a typo would otherwise silently never expose,
    // exactly the empty-exposed-modules class of bug this splitter exists to
    // prevent.
    const exposeExact = new Set((pkg.exposeInternal || []).filter((e) => !e.endsWith(".")));
    const exposePrefixes = (pkg.exposeInternal || []).filter((e) => e.endsWith("."));
    const forceExposed = (modName) =>
      exposeExact.has(modName) || exposePrefixes.some((p) => modName.startsWith(p));
    for (const entry of pkg.exposeInternal || []) {
      const isPrefix = entry.endsWith(".");
      const matched = pkgMods[pkg.name].some((m) => (isPrefix ? m.startsWith(entry) : m === entry));
      if (!matched) {
        console.error(`elm-cem split: GATE FAIL — exposeInternal: ${pkg.name} lists ${entry} but no bucket routes a matching module to this package`);
        process.exit(1);
      }
    }
    for (const modName of pkgMods[pkg.name].sort()) {
      const srcFile = allModules[modName];
      const relPath = path.relative(srcDir, srcFile);
      const dstFile = path.join(pkgSrcDir, relPath);
      fs.mkdirSync(path.dirname(dstFile), { recursive: true });
      fs.copyFileSync(srcFile, dstFile);
      // Expose all modules except Internal and Review — but DO expose the
      // `<Lib>.Review.Facts` contract module (issue #42; see syncExposedModules
      // in elm-cem.js for the rationale, and NB3 for the empty-exposed-modules
      // bug this closes). Its package must dep `jackhp95/elm-cem-facts` at
      // Stage F (issue #48) so `Cem.Facts` resolves.
      const isReviewFacts = /(^|\.)Review\.Facts$/.test(modName);
      if (
        forceExposed(modName) ||
        (!/(^|\.)Internal(\.|$)/.test(modName) &&
          (isReviewFacts || !/(^|\.)Review(\.|$)/.test(modName)))
      ) {
        exposedModules.push(modName);
      }
    }

    // Emit elm.json (Elm package format — dependencies.direct/indirect)
    const directDeps = {};
    // Family-internal deps use exact versions from the dep packages
    for (const [depName, depRange] of Object.entries(pkg.deps || {})) {
      directDeps[depName] = depRange;
    }
    // Always include elm/core
    if (!directDeps["elm/core"]) directDeps["elm/core"] = "1.0.0 <= v < 2.0.0";

    const elmJson = {
      type: "package",
      name: pkg.name,
      summary: pkg.summary || `${shortName} package`,
      license: "BSD-3-Clause",
      version: pkg.version || "1.0.0",
      "exposed-modules": exposedModules.sort(),
      "elm-version": pkg.elmVersion || "0.19.0 <= v < 0.20.0",
      dependencies: directDeps,
      "test-dependencies": {}
    };
    fs.writeFileSync(path.join(pkgDir, "elm.json"), JSON.stringify(elmJson, null, 4) + "\n");

    // Emit README.md with the copy-only banner
    const banner = `> Generated publish mirror of \`${devRepo}\` — do not edit, do not PR; issues and source live in \`${devRepo}\`.`;
    const readme = [
      `# ${pkg.name}`,
      "",
      banner,
      "",
      `${pkg.summary || shortName}`,
      "",
      `## Install`,
      "",
      `\`\`\``,
      `elm install ${pkg.name}`,
      `\`\`\``,
    ].join("\n");
    fs.writeFileSync(path.join(pkgDir, "README.md"), readme + "\n");

    // Emit LICENSE
    if (licenseText) {
      fs.writeFileSync(path.join(pkgDir, "LICENSE"), licenseText + "\n");
    }

    console.log(`elm-cem split: emitted ${shortName} (${pkgMods[pkg.name].length} modules, ${exposedModules.length} exposed)`);
  }

  console.log(`\nelm-cem split: done — ${packages.length} packages emitted to ${outDir}`);
}

// Recursively walk a directory and call cb(absolutePath) for each .elm file.
function walkElm(dir, cb) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) walkElm(full, cb);
    else if (e.name.endsWith(".elm")) cb(full);
  }
}

// Direct invocation must do the same work as `elm-cem <subcommand>`. Without this
// guard the file loads, exports `run`, calls nothing, prints nothing and exits 0 —
// a gate reporting success without doing its work, which is precisely the failure
// these scripts exist to prevent. It nearly banked a false "verified" once: an
// agent checking elm-review-cem's neutrality gate ran this file directly, got a
// clean exit 0, and only doubted it because an expected log line never printed.
if (require.main === module) run(process.argv.slice(2));
