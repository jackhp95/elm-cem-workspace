// elm-cem family dependency stamping + coverage gate (issue #48, finding NB1).
//
// SINGLE SOURCE OF TRUTH for the version ranges of the elm-cem family's
// unpublished-pre-Stage-F dependencies, and the import-driven logic that decides
// which of them a given publishable package must declare.
//
// Two family deps exist:
//   * jackhp95/elm-html-intermediate-representation — provides `HtmlIr.*`. Every
//     package whose emitted src imports `HtmlIr.*` must declare it. NB1: five of
//     seven published packages omitted it and failed to compile in the registry.
//   * jackhp95/elm-cem-facts — provides `Cem.Facts`. A package that ships an
//     exposed `<Brand>.Review.Facts` (which `import Cem.Facts`) must declare it.
//
// The decision is DERIVED FROM IMPORTS, never hardcoded per emit-site, so it is
// automatically decay-level-aware: the `full` package ships `Review.Facts` (→
// facts + IR), the `-html` package does not (→ IR only). Add or move a module and
// the stamped dep set follows the actual imports.
//
// The same import scan powers a static GATE (`auditPackage`) that fails if any
// emitted package imports a family namespace — `HtmlIr.*`, `Cem.Facts`, or any
// other foreign brand namespace — that its `elm.json` does not declare. This is
// the cheap check the old split.js never had; it catches NB1 recurrence before a
// package is ever staged against the registry.

"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");

// ── Single-sourced version ranges ────────────────────────────────────────────

// The family deps and the namespaces they provide. `matches(module)` decides
// whether an `import <module>` line requires this dep.
const FAMILY_DEPS = [
  {
    package: "jackhp95/elm-virtual-dom-intermediate-representation",
    range: "1.0.0 <= v < 2.0.0",
    matches: (m) => m === "HtmlIr" || m.startsWith("HtmlIr."),
  },
  {
    package: "jackhp95/elm-cem-facts",
    range: "1.0.0 <= v < 2.0.0",
    // The facts package exposes exactly `Cem.Facts`.
    matches: (m) => m === "Cem.Facts" || m.startsWith("Cem.Facts."),
  },
];

// ── The full consumer-facing family (vendor→publish swap, audit Boundary #10) ─
//
// A publishable *package* declares only the two unpublished deps above (IR +
// facts) — that is what its emitted src imports. A *consumer application* that
// vendors the family via `source-directories` reaches a wider surface: the brand
// (`M3e.*`), the native axis (`TypedHtml.*`), the review rules (`Cem.*` and the
// bare rule modules), plus IR and facts. `elm-cem eject` (bin/eject.js) reuses
// this map in the published→vendored direction (see docs/distribution-model.md).
//
// FAMILY_PACKAGES is the SINGLE SOURCE OF TRUTH for that mapping:
// namespace → published package → version range. IR + facts are reused verbatim
// from FAMILY_DEPS so the two ranges never drift; the three consumer-only
// packages (typed-html, m3e, review-cem) are added here. Detection is by module
// namespace, never by vendor-dir name — every consumer uses a different
// convention (elm-foundation fusing IR+TypedHtml, new-elm-m3e, per-app dir names).
//
// Order matters: `Cem.Facts` (facts, from FAMILY_DEPS) is tested BEFORE the
// broader `Cem.*` review-cem matcher below, so the byte-synced Cem/Facts.elm copy
// a consumer vendors inside elm-review-cem is attributed to elm-cem-facts, exactly
// as the Stage-F cutover prescribes (review-cem drops its own copy, deps facts).
//
// The brand-specific tail (finding 2.3, 2026-08-17 thermonuclear review: this
// used to be 3 M3E package literals hardcoded here, plus a SEPARATE hardcoded
// `BRANDS = { m3e: {...} }` in eject.js describing the same brand) is loaded
// from ../family-configs/*.json — see family-configs/README.md. Each brand
// file contributes its `consumerPackages`, appended in file order AFTER the
// generic FAMILY_DEPS pair, so the `Cem.Facts`-before-`Cem.*` ordering above
// always holds regardless of how many brands are configured.
const FAMILY_CONFIGS_DIR = path.join(__dirname, "..", "family-configs");

function buildMatcher(moduleRoots, extraModules) {
  const roots = moduleRoots || [];
  const extras = new Set(extraModules || []);
  return (m) => roots.some((r) => m === r || m.startsWith(r + ".")) || extras.has(m);
}

// Load every brand family-config, sorted by filename for determinism. Each
// entry: { key, namespace, package, repo, webPackage, consumerPackages }.
// Malformed/unreadable files are skipped with a loud warning rather than
// silently dropped, matching the file's own "derive, never hand-wave" rule.
function loadBrandFamilies(dir) {
  const brands = [];
  let entries;
  try {
    entries = fs.readdirSync(dir).filter((f) => f.endsWith(".json")).sort();
  } catch {
    return brands;
  }
  for (const file of entries) {
    const full = path.join(dir, file);
    try {
      const raw = JSON.parse(fs.readFileSync(full, "utf8"));
      if (!raw.key || !raw.namespace || !raw.package) {
        console.error(`family-deps: ${full} is missing required "key"/"namespace"/"package" — skipping`);
        continue;
      }
      brands.push(raw);
    } catch (e) {
      console.error(`family-deps: could not read ${full}: ${e.message} — skipping`);
    }
  }
  return brands;
}

const BRAND_FAMILIES = loadBrandFamilies(FAMILY_CONFIGS_DIR);

// The eject brand registry — key → brand metadata. Genuinely config-driven:
// dropping a new family-configs/<brand>.json here adds an eject target with
// no JS change (bin/eject.js consumes this instead of its own literal).
const BRAND_REGISTRY = Object.fromEntries(
  BRAND_FAMILIES.map((b) => [
    b.key,
    { key: b.key, namespace: b.namespace, package: b.package, repo: b.repo, webPackage: b.webPackage },
  ])
);

const FAMILY_PACKAGES = [
  ...FAMILY_DEPS, // IR (HtmlIr.*) then facts (Cem.Facts) — ranges single-sourced.
  ...BRAND_FAMILIES.flatMap((b) =>
    (b.consumerPackages || []).map((p) => ({
      package: p.package,
      range: p.range,
      matches: buildMatcher(p.moduleRoots, p.extraModules),
    }))
  ),
];

// The published family package a vendored module belongs to, or null. First
// match wins (see the ordering note on FAMILY_PACKAGES).
function familyPackageFor(module) {
  return FAMILY_PACKAGES.find((d) => d.matches(module)) || null;
}

// The exact lower-bound version of a family range ("1.0.0 <= v < 2.0.0" →
// "1.0.0"). Application elm.json dependencies pin an EXACT version, whereas a
// package uses the full range; the swap script picks per elm.json `type` but
// single-sources the number from the one range here.
function lowerBound(range) {
  const m = /^\s*(\d+\.\d+\.\d+)\b/.exec(range);
  if (!m) throw new Error(`family-deps: cannot parse lower bound from range "${range}"`);
  return m[1];
}

// The base Elm deps every generated package carries (verbatim ranges).
const BASE_ELM_DEPS = {
  "elm/core": "1.0.0 <= v < 2.0.0",
  "elm/html": "1.0.0 <= v < 2.0.0",
  "elm/json": "1.0.0 <= v < 2.0.0",
  "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
};

// Module roots provided by BASE_ELM_DEPS. An import whose root is here is
// satisfied by the base deps, so the gate does not treat it as a foreign
// namespace. (elm/core, elm/html, elm/json, elm/virtual-dom.)
const ELM_STDLIB_ROOTS = new Set([
  // elm/core
  "Basics", "List", "Maybe", "Result", "String", "Char", "Tuple", "Dict", "Set",
  "Array", "Debug", "Platform", "Process", "Task", "Bitwise", "Never",
  // elm/html
  "Html",
  // elm/json
  "Json",
  // elm/virtual-dom
  "VirtualDom",
]);

// ── Import scanning ───────────────────────────────────────────────────────────

// Return a fresh copy of the base Elm dependency block.
function baseDependencies() {
  return { ...BASE_ELM_DEPS };
}

// The family dep entry an imported module requires, or null.
function familyDepFor(module) {
  return FAMILY_DEPS.find((d) => d.matches(module)) || null;
}

// Walk a src tree → { moduleName: absolutePath }.
function discoverModules(srcDir) {
  const out = {};
  const walk = (dir) => {
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, e.name);
      if (e.isDirectory()) walk(full);
      else if (e.name.endsWith(".elm")) {
        const rel = path.relative(srcDir, full).replace(/\.elm$/, "").split(path.sep).join(".");
        out[rel] = full;
      }
    }
  };
  walk(srcDir);
  return out;
}

const IMPORT_RE = /^import\s+([A-Za-z0-9_.]+)/gm;

// Every `import` target in an Elm source string.
function importsOf(src) {
  const out = [];
  let m;
  IMPORT_RE.lastIndex = 0;
  while ((m = IMPORT_RE.exec(src)) !== null) out.push(m[1]);
  return out;
}

// The family deps (package → range) that the modules under `srcDir` import.
// Import-driven, so it is automatically correct per decay level: whatever
// modules were copied into this package's src/ determine its dep set.
function requiredFamilyDeps(srcDir) {
  const modules = discoverModules(srcDir);
  const deps = {};
  for (const file of Object.values(modules)) {
    for (const imp of importsOf(fs.readFileSync(file, "utf8"))) {
      const dep = familyDepFor(imp);
      if (dep) deps[dep.package] = dep.range;
    }
  }
  return deps;
}

// Build the full `dependencies` block for a publishable package: base Elm deps +
// exactly the family deps its src imports. `extra` merges any caller-forced deps.
function stampDependencies(srcDir, extra = {}) {
  return { ...baseDependencies(), ...requiredFamilyDeps(srcDir), ...extra };
}

// ── Coverage gate ─────────────────────────────────────────────────────────────

// Module-name roots (e.g. "Review" for "Review.Rule") exposed by every
// NON-family dependency an elm.json declares — a hand-authored package (like
// elm-review-cem) may legitimately depend on ordinary published packages
// (jfmengels/elm-review, stil4m/elm-syntax) beyond the family+stdlib set, and
// the audit below must not flag those as undeclared. Resolved from the local
// Elm package cache (any cached version's elm.json `exposed-modules` — root
// namespaces don't change across a package's versions), so this is best-effort
// and additive: it only ever widens what the audit accepts, it never narrows
// the family/stdlib checks above.
function providedRootsFromDeclaredDeps(declared, elmHome) {
  const home = elmHome || process.env.ELM_HOME || path.join(os.homedir(), ".elm");
  const roots = new Set();
  for (const pkg of Object.keys(declared)) {
    if (FAMILY_DEPS.some((d) => d.package === pkg)) continue; // handled separately
    const pkgCacheDir = path.join(home, "0.19.1", "packages", ...pkg.split("/"));
    let versions;
    try {
      versions = fs.readdirSync(pkgCacheDir);
    } catch {
      continue;
    }
    for (const version of versions) {
      let depElmJson;
      try {
        depElmJson = JSON.parse(fs.readFileSync(path.join(pkgCacheDir, version, "elm.json"), "utf8"));
      } catch {
        continue;
      }
      const exposed = depElmJson["exposed-modules"];
      const names = Array.isArray(exposed) ? exposed : Object.values(exposed || {}).flat();
      for (const name of names) roots.add(name.split(".")[0]);
    }
  }
  return roots;
}

// Audit one emitted package directory (containing elm.json + src/). Returns a
// list of violation strings; empty means the package declares every family /
// foreign namespace its src imports. Catches NB1: an `import HtmlIr.*` with no
// `jackhp95/elm-html-intermediate-representation` dependency, an exposed
// `Review.Facts` importing `Cem.Facts` with no facts dep, or an import of some
// other brand's namespace with no dep providing it.
// `providedModules` (optional) is the set of module names EXPOSED by declared
// unpublished family deps — e.g. when auditing jackhp95/elm-m3e-components, the
// exposed-modules of its declared dep jackhp95/elm-m3e-core (`M3e.Attributes`,
// `M3e.Kind`, `M3e.Forge.Internal`, …). A family that SPLITS one namespace root
// across sibling packages (`M3e.*` living in core + components + builder) can't
// be resolved by the fixed FAMILY_DEPS namespace table alone, so an import of a
// sibling's exposed module would look "foreign". Passing the siblings' exposed
// surface lets the audit see it as covered — the caller (registry-check) knows
// which deps are declared+staged and what each exposes.
function auditPackage(pkgDir, providedModules = new Set()) {
  const elmJsonPath = path.join(pkgDir, "elm.json");
  const srcDir = path.join(pkgDir, "src");
  const violations = [];

  let elmJson;
  try {
    elmJson = JSON.parse(fs.readFileSync(elmJsonPath, "utf8"));
  } catch (e) {
    return [`cannot read ${elmJsonPath}: ${e.message}`];
  }
  const declaredDeps = elmJson.dependencies || {};
  const declared = new Set(Object.keys(declaredDeps));
  const otherDeclaredRoots = providedRootsFromDeclaredDeps(declaredDeps);
  const modules = discoverModules(srcDir);
  const ownModules = new Set(Object.keys(modules));

  for (const [modName, file] of Object.entries(modules)) {
    for (const imp of importsOf(fs.readFileSync(file, "utf8"))) {
      if (ownModules.has(imp)) continue; // intra-package import
      const dep = familyDepFor(imp);
      if (dep) {
        if (!declared.has(dep.package)) {
          violations.push(
            `${elmJson.name || pkgDir}: ${modName} imports ${imp} but elm.json does not declare ${dep.package}`
          );
        }
        continue;
      }
      if (providedModules.has(imp)) continue; // exposed by a declared family dep
      const root = imp.split(".")[0];
      if (ELM_STDLIB_ROOTS.has(root)) continue; // provided by the base Elm deps
      if (otherDeclaredRoots.has(root)) continue; // provided by a declared non-family dependency
      violations.push(
        `${elmJson.name || pkgDir}: ${modName} imports foreign namespace ${imp} — no declared dependency provides it`
      );
    }
  }
  return violations;
}

module.exports = {
  FAMILY_DEPS,
  FAMILY_PACKAGES,
  BRAND_FAMILIES,
  BRAND_REGISTRY,
  loadBrandFamilies,
  familyPackageFor,
  lowerBound,
  BASE_ELM_DEPS,
  ELM_STDLIB_ROOTS,
  baseDependencies,
  familyDepFor,
  requiredFamilyDeps,
  stampDependencies,
  auditPackage,
  providedRootsFromDeclaredDeps,
  discoverModules,
  importsOf,
};
