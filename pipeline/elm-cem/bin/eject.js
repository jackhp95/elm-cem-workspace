// elm-cem eject — the published-primitives → vendored-full-brand cutover.
//
// WHY THIS EXISTS
// ───────────────
// A phantom-typed N-component brand can never fit the Elm registry's 700 KB
// docs.json cap (see docs/distribution-model.md). So the registry ships only the
// brand's HTML-like primitives (`jackhp95/elm-<brand>`, the ~10 general modules);
// the full component surface is delivered by EJECT: pull the pre-generated
// `<Brand>.*` modules into the consumer's tree as a build artifact.
//
// Eject is the mirror image of the retired `swap` command (vendored → published);
// it reuses the SAME namespace→package map in bin/family-deps.js. Given the pulled
// `vendor/<Brand>` tree, it:
//   1. adds `vendor/<Brand>` to source-directories,
//   2. REMOVES the `jackhp95/elm-<brand>` dep — the vendored superset already
//      contains the primitives, so keeping both would collide on `<Brand>.Html`,
//   3. PROMOTES the family deps the vendored code actually imports (IR always;
//      facts only if `<Brand>.Review.Facts` is present) from indirect → direct —
//      detected by scanning imports, never hardcoded,
//   4. pins `@m3e/web` in package.json to the version the bindings target, so the
//      Elm bindings and the runtime web components cannot drift,
//   5. (--with-review) wires elm-review-cem: scaffold a fresh review/ or, if one
//      exists, safe-merge the two deps + source-dir and PRINT the ReviewConfig
//      lines to add.
//
// --dry-run (DEFAULT) prints the plan and writes nothing. --write applies it.

"use strict";

const fs = require("fs");
const path = require("path");
const family = require("./family-deps");

// The brand registry — derived from ../family-configs/*.json (finding 2.3,
// 2026-08-17 thermonuclear review: this used to be a JS literal with exactly
// one hardcoded "m3e" entry despite eject being advertised as brand-generic).
// A second brand is a data change (drop a file in family-configs/), not a
// code change — see family-configs/README.md.
const BRANDS = family.BRAND_REGISTRY;

function usage() {
  console.log(
    [
      "elm-cem eject <brand> — pull a brand's full component surface into your tree.",
      "",
      "Usage:",
      "  elm-cem eject <brand> --elm-json=<path> [options]",
      "",
      "Options:",
      "  --elm-json=<path>     the consumer elm.json to rewire (required)",
      "  --into=<dir>          vendor dir for the pulled modules (default vendor/<Brand>)",
      "  --ref=<tag|sha>       brand repo ref to pull (default: matching the web version)",
      "  --web-version=<v>     the @m3e/web version to pin in package.json",
      "  --with-review         also wire the elm-review-cem rules",
      "  --dry-run             print the plan, change nothing (DEFAULT)",
      "  --write               apply in place",
      "  -h, --help            show this help",
      "",
      "Brands: " + Object.keys(BRANDS).join(", "),
    ].join("\n")
  );
}

function fail(msg) {
  console.error(`eject: ${msg}`);
  process.exit(1);
}

function parseArgs(argv) {
  const opts = {
    brand: null,
    elmJson: null,
    into: null,
    ref: null,
    webVersion: null,
    withReview: false,
    write: false,
  };
  for (const a of argv) {
    if (a === "-h" || a === "--help") opts.help = true;
    else if (a === "--write") opts.write = true;
    else if (a === "--dry-run") opts.write = false;
    else if (a === "--with-review") opts.withReview = true;
    else if (a.startsWith("--elm-json=")) opts.elmJson = a.slice("--elm-json=".length);
    else if (a.startsWith("--into=")) opts.into = a.slice("--into=".length);
    else if (a.startsWith("--ref=")) opts.ref = a.slice("--ref=".length);
    else if (a.startsWith("--web-version=")) opts.webVersion = a.slice("--web-version=".length);
    else if (!a.startsWith("-") && !opts.brand) opts.brand = a;
    else fail(`unknown argument: ${a}`);
  }
  return opts;
}

// ── Dependency detection (pure) ──────────────────────────────────────────────

// The family packages the vendored brand tree imports — the deps the ejected
// code needs, EXCLUDING the brand itself (its own `<Brand>.*` imports are
// internal to the vendored source, not a dependency). Detected by scanning every
// module's imports and mapping via family-deps.js.
function detectFamilyDeps(vendorDir, brandPackage) {
  const modules = family.discoverModules(vendorDir); // { name: absPath }
  const deps = new Set();
  for (const name of Object.keys(modules)) {
    const src = fs.readFileSync(modules[name], "utf8");
    for (const imp of family.importsOf(src)) {
      const dep = family.familyPackageFor(imp);
      if (dep && dep.package !== brandPackage) deps.add(dep.package);
    }
  }
  return deps;
}

// ── elm.json plan (pure) ─────────────────────────────────────────────────────

function isApplication(elmJson) {
  return elmJson.type === "application" || elmJson.type === undefined;
}

// Build the eject plan for a parsed consumer elm.json. `vendorEntry` is the
// source-directory string to add (relative to elm.json). `detectedDeps` is the
// Set of family package names the vendored code imports. Does not mutate.
function planEject(elmJson, vendorEntry, detectedDeps, brand) {
  const isApp = isApplication(elmJson);
  const srcDirs = Array.isArray(elmJson["source-directories"])
    ? elmJson["source-directories"]
    : [];
  const addSrcDir = srcDirs.includes(vendorEntry) ? null : vendorEntry;

  // The brand's published primitives package is superseded by the vendored tree.
  const removeDep = brand.package;

  // Promote the detected family deps, ordered by FAMILY_PACKAGES for determinism.
  const addDeps = family.FAMILY_PACKAGES.filter((d) => detectedDeps.has(d.package)).map((d) => ({
    package: d.package,
    value: isApp ? family.lowerBound(d.range) : d.range,
  }));

  return { isApp, srcDirs, addSrcDir, removeDep, addDeps, vendorEntry };
}

function depBlock(elmJson, isApp) {
  if (isApp) {
    elmJson.dependencies = elmJson.dependencies || {};
    elmJson.dependencies.direct = elmJson.dependencies.direct || {};
    elmJson.dependencies.indirect = elmJson.dependencies.indirect || {};
    return elmJson.dependencies.direct;
  }
  elmJson.dependencies = elmJson.dependencies || {};
  return elmJson.dependencies;
}

function sortObjectInPlace(obj) {
  const sorted = Object.fromEntries(Object.keys(obj).sort().map((k) => [k, obj[k]]));
  for (const k of Object.keys(obj)) delete obj[k];
  Object.assign(obj, sorted);
}

// Apply the elm.json plan in place. Returns the same object.
function applyEject(elmJson, plan) {
  // 1. Add the vendored source-directory.
  if (plan.addSrcDir) {
    elmJson["source-directories"] = [...plan.srcDirs, plan.addSrcDir];
  }

  const direct = depBlock(elmJson, plan.isApp);

  // 2. Remove the superseded brand primitives package (from direct AND indirect).
  delete direct[plan.removeDep];
  if (plan.isApp && elmJson.dependencies.indirect) {
    delete elmJson.dependencies.indirect[plan.removeDep];
  }

  // 3. Promote the detected family deps to direct (dropping any indirect copy).
  for (const d of plan.addDeps) {
    direct[d.package] = d.value;
    if (plan.isApp && elmJson.dependencies.indirect) {
      delete elmJson.dependencies.indirect[d.package];
    }
  }

  sortObjectInPlace(direct);
  if (plan.isApp && elmJson.dependencies.indirect) sortObjectInPlace(elmJson.dependencies.indirect);
  return elmJson;
}

// Which planned deps aren't already declared at the intended value.
function pendingDeps(elmJson, plan) {
  const direct = depBlock(elmJson, plan.isApp);
  return plan.addDeps.filter((d) => direct[d.package] !== d.value);
}

// ── package.json plan (pure) ─────────────────────────────────────────────────

// The @m3e/web pin: assert brand.webPackage === webVersion under devDependencies.
function planPkg(pkgJson, brand, webVersion) {
  if (!webVersion) return { pkg: brand.webPackage, version: null, current: null, change: false };
  const dev = (pkgJson && pkgJson.devDependencies) || {};
  const deps = (pkgJson && pkgJson.dependencies) || {};
  const current = dev[brand.webPackage] || deps[brand.webPackage] || null;
  return {
    pkg: brand.webPackage,
    version: webVersion,
    current,
    // where it already lives, so we update in place rather than duplicating.
    inDeps: deps[brand.webPackage] !== undefined,
    change: current !== webVersion,
  };
}

function applyPkg(pkgJson, plan) {
  if (!plan.version || !plan.change) return pkgJson;
  if (plan.inDeps) {
    pkgJson.dependencies[plan.pkg] = plan.version;
  } else {
    pkgJson.devDependencies = pkgJson.devDependencies || {};
    pkgJson.devDependencies[plan.pkg] = plan.version;
  }
  return pkgJson;
}

// ── review wiring (pure) ─────────────────────────────────────────────────────

// The one-line consumer ReviewConfig — Cem.all wired to the brand's generated
// facts. `<Brand>.Review.Facts` imports only Cem.Facts, so this is all that's
// needed.
function reviewConfigSource(brand) {
  return [
    "module ReviewConfig exposing (config)",
    "",
    "{-| elm-review config for " + brand.namespace + " — the elm-cem-family rules,",
    "wired to the generated brand facts. See jackhp95/elm-review-cem.",
    "-}",
    "",
    "import Cem",
    "import " + brand.namespace + ".Review.Facts",
    "import Review.Rule exposing (Rule)",
    "",
    "",
    "config : List Rule",
    "config =",
    "    Cem.all " + brand.namespace + ".Review.Facts.facts",
    "",
  ].join("\n");
}

// The review/elm.json DIRECT deps a fresh setup needs. (Indirect deps are left to
// `elm-review`/`elm` to solve on first run — emitting a guaranteed-valid full
// solution would require the solver.)
const REVIEW_DIRECT_DEPS = {
  "elm/core": "1.0.5",
  "jfmengels/elm-review": "2.16.0 <= v < 3.0.0",
  "jackhp95/elm-review-cem": "1.0.0 <= v < 2.0.0",
  "jackhp95/elm-cem-facts": "1.0.0 <= v < 2.0.0",
  "stil4m/elm-syntax": "7.3.0 <= v < 8.0.0",
};

// Plan the review step. `reviewExists` = a review/ dir with an elm.json is
// present. `vendorFromReview` = path from review/ to the vendored brand dir.
function planReview(opts) {
  const { withReview, reviewExists, brand, vendorFromReview } = opts;
  if (!withReview) return { mode: "skip" };
  if (!reviewExists) {
    return {
      mode: "scaffold",
      files: {
        "review/src/ReviewConfig.elm": reviewConfigSource(brand),
      },
      elmJson: {
        type: "application",
        "source-directories": ["src", vendorFromReview],
        "elm-version": "0.19.1",
        dependencies: { direct: REVIEW_DIRECT_DEPS, indirect: {} },
        "test-dependencies": { direct: {}, indirect: {} },
      },
    };
  }
  return {
    mode: "merge",
    addDeps: {
      "jackhp95/elm-review-cem": REVIEW_DIRECT_DEPS["jackhp95/elm-review-cem"],
      "jackhp95/elm-cem-facts": REVIEW_DIRECT_DEPS["jackhp95/elm-cem-facts"],
    },
    addSrcDir: vendorFromReview,
    instructions: [
      "  Add to your review/src/ReviewConfig.elm:",
      "    import Cem",
      "    import " + brand.namespace + ".Review.Facts",
      "    -- then append to your `config` list:",
      "    ++ Cem.all " + brand.namespace + ".Review.Facts.facts",
    ].join("\n"),
  };
}

// ── diff rendering (pure) ────────────────────────────────────────────────────

function renderDiff(elmJson, plan, pkgPlan, reviewPlan, elmJsonPath) {
  const lines = [];
  lines.push(`eject plan for ${elmJsonPath}`);
  lines.push(`  elm.json type: ${plan.isApp ? "application (exact versions)" : "package (ranges)"}`);
  lines.push("");

  lines.push("  source-directories:");
  lines.push(plan.addSrcDir ? `    + ${plan.addSrcDir}` : `    (${plan.vendorEntry} already present)`);
  lines.push("");

  const direct = depBlock(elmJson, plan.isApp);
  lines.push(`  ${plan.isApp ? "dependencies.direct" : "dependencies"}:`);
  if (direct[plan.removeDep] !== undefined) lines.push(`    - "${plan.removeDep}"  (superseded by the vendored source)`);
  const pending = pendingDeps(elmJson, plan);
  if (pending.length) for (const d of pending) lines.push(`    + "${d.package}": "${d.value}"`);
  if (direct[plan.removeDep] === undefined && !pending.length) lines.push("    (already ejected)");
  lines.push("");

  if (pkgPlan && pkgPlan.version) {
    lines.push("  package.json (pin runtime web components):");
    lines.push(
      pkgPlan.change
        ? `    ~ "${pkgPlan.pkg}": "${pkgPlan.current || "<absent>"}" → "${pkgPlan.version}"`
        : `    ("${pkgPlan.pkg}" already at ${pkgPlan.version})`
    );
    lines.push("");
  }

  if (reviewPlan && reviewPlan.mode !== "skip") {
    if (reviewPlan.mode === "scaffold") {
      lines.push("  review (elm-review-cem): scaffold fresh review/ (elm.json + ReviewConfig.elm)");
    } else if (reviewPlan.mode === "merge") {
      lines.push("  review (elm-review-cem): existing review/ — safe-merge elm.json deps + source-dir:");
      for (const [k, v] of Object.entries(reviewPlan.addDeps)) lines.push(`    + "${k}": "${v}"`);
      lines.push(`    + source-directory: ${reviewPlan.addSrcDir}`);
      lines.push("  then add to review/src/ReviewConfig.elm (by hand):");
      lines.push(reviewPlan.instructions);
    }
    lines.push("");
  }

  lines.push("  → run again with --write to apply.");
  return lines.join("\n");
}

module.exports = {
  BRANDS,
  parseArgs,
  detectFamilyDeps,
  isApplication,
  planEject,
  applyEject,
  pendingDeps,
  planPkg,
  applyPkg,
  reviewConfigSource,
  planReview,
  renderDiff,
  REVIEW_DIRECT_DEPS,
  // run is defined below (impure).
  run,
};

// ── run (impure: git pull + apply) ───────────────────────────────────────────

function run(argv) {
  const opts = parseArgs(argv);
  if (opts.help) {
    usage();
    process.exit(0);
  }
  if (!opts.brand) fail("missing <brand> (e.g. `elm-cem eject m3e`)");
  const brand = BRANDS[opts.brand];
  if (!brand) fail(`unknown brand "${opts.brand}". Known: ${Object.keys(BRANDS).join(", ")}`);
  if (!opts.elmJson) fail("missing required --elm-json=<path>");

  const elmJsonPath = path.resolve(process.cwd(), opts.elmJson);
  if (!fs.existsSync(elmJsonPath)) fail(`no such file: ${elmJsonPath}`);
  const consumerDir = path.dirname(elmJsonPath);
  const vendorEntry = opts.into || `vendor/${brand.namespace}`;
  const vendorAbs = path.resolve(consumerDir, vendorEntry);

  // NOTE: the git-pull step is intentionally a thin shell-out and is exercised
  // end-to-end, not unit-tested (network). The planning below is pure + tested.
  if (opts.write) {
    pullBrand(brand, opts.ref, vendorAbs);
  }
  if (!fs.existsSync(vendorAbs)) {
    fail(`vendor dir ${vendorAbs} not present — run with --write to pull it, or pre-populate it.`);
  }

  const elmJson = JSON.parse(fs.readFileSync(elmJsonPath, "utf8"));
  const detected = detectFamilyDeps(vendorAbs, brand.package);
  const plan = planEject(elmJson, vendorEntry, detected, brand);

  const pkgPath = path.join(consumerDir, "package.json");
  const pkgJson = fs.existsSync(pkgPath) ? JSON.parse(fs.readFileSync(pkgPath, "utf8")) : null;
  const pkgPlan = pkgJson ? planPkg(pkgJson, brand, opts.webVersion) : { version: null };

  const reviewDir = path.join(consumerDir, "review");
  const reviewExists = fs.existsSync(path.join(reviewDir, "elm.json"));
  const vendorFromReview = path.relative(reviewDir, vendorAbs);
  const reviewPlan = planReview({ withReview: opts.withReview, reviewExists, brand, vendorFromReview });

  console.log(renderDiff(elmJson, plan, pkgPlan, reviewPlan, elmJsonPath));

  if (!opts.write) return;

  applyEject(elmJson, plan);
  fs.writeFileSync(elmJsonPath, JSON.stringify(elmJson, null, 4) + "\n");
  console.log(`\neject: WROTE ${elmJsonPath}`);

  if (pkgJson && pkgPlan.change) {
    applyPkg(pkgJson, pkgPlan);
    fs.writeFileSync(pkgPath, JSON.stringify(pkgJson, null, 2) + "\n");
    console.log(`eject: pinned ${pkgPlan.pkg}@${pkgPlan.version} in ${pkgPath}`);
  }

  if (reviewPlan.mode === "scaffold") {
    fs.mkdirSync(path.join(reviewDir, "src"), { recursive: true });
    fs.writeFileSync(path.join(reviewDir, "elm.json"), JSON.stringify(reviewPlan.elmJson, null, 4) + "\n");
    fs.writeFileSync(path.join(reviewDir, "src", "ReviewConfig.elm"), reviewPlan.files["review/src/ReviewConfig.elm"]);
    console.log(`eject: scaffolded review/ — run \`cd review && elm-review\` (it will solve indirect deps).`);
  } else if (reviewPlan.mode === "merge") {
    const rej = JSON.parse(fs.readFileSync(path.join(reviewDir, "elm.json"), "utf8"));
    const rdirect = depBlock(rej, isApplication(rej));
    for (const [k, v] of Object.entries(reviewPlan.addDeps)) if (rdirect[k] === undefined) rdirect[k] = v;
    if (!((rej["source-directories"] || []).includes(reviewPlan.addSrcDir))) {
      rej["source-directories"] = [...(rej["source-directories"] || []), reviewPlan.addSrcDir];
    }
    sortObjectInPlace(rdirect);
    fs.writeFileSync(path.join(reviewDir, "elm.json"), JSON.stringify(rej, null, 4) + "\n");
    console.log(`eject: merged elm-review-cem deps into review/elm.json — add the ReviewConfig lines above by hand.`);
  }
}

// Pull the brand's src/ into vendorAbs via a shallow git clone.
function pullBrand(brand, ref, vendorAbs) {
  const { spawnSync } = require("child_process");
  const os = require("os");
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-eject-"));
  const url = `https://github.com/${brand.repo}.git`;
  const args = ["clone", "--depth", "1"];
  if (ref) args.push("--branch", ref);
  args.push(url, tmp);
  const r = spawnSync("git", args, { encoding: "utf8" });
  if (r.status !== 0) fail(`git clone ${url} failed:\n${r.stderr || r.stdout}`);
  const srcFrom = path.join(tmp, "src");
  if (!fs.existsSync(srcFrom)) fail(`pulled repo has no src/ at ${srcFrom}`);
  fs.rmSync(vendorAbs, { recursive: true, force: true });
  fs.mkdirSync(vendorAbs, { recursive: true });
  fs.cpSync(srcFrom, vendorAbs, { recursive: true });
  fs.rmSync(tmp, { recursive: true, force: true });
  console.log(`eject: pulled ${brand.repo}${ref ? "@" + ref : ""} → ${vendorAbs}`);
}

// Direct invocation must do the same work as `elm-cem <subcommand>`. Without this
// guard the file loads, exports `run`, calls nothing, prints nothing and exits 0 —
// a gate reporting success without doing its work, which is precisely the failure
// these scripts exist to prevent. It nearly banked a false "verified" once: an
// agent checking elm-review-cem's neutrality gate ran this file directly, got a
// clean exit 0, and only doubted it because an expected log line never printed.
if (require.main === module) run(process.argv.slice(2));
