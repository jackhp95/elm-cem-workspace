// elm-cem registry-check gate (issue #49, historical finding B2 / NB1).
//
// Proves a publishable package compiles AS IT WOULD FROM THE REGISTRY. The
// release gates historically compiled a different artifact than `elm publish`
// would (B2): app-shaped builds with the whole worktree on source-directories,
// which silently resolve imports the published package elm.json never declares.
// That is exactly how NB1 hid — five of seven packages imported `HtmlIr.*` while
// their elm.json declared only elm/* deps, and no gate caught it until a
// fake-registry compile in the audit.
//
// This gate is the COMPILE-level complement to #48's static coverage gate
// (family-deps.js `auditPackage`, reused verbatim below). It:
//
//   1. runs `auditPackage` — the cheap static check: every family / foreign
//      namespace a module imports must be declared in elm.json. (NB1 statically.)
//   2. compiles a PACKAGE-SHAPED build whose resolvable module set is derived
//      STRICTLY from the committed elm.json `dependencies`: the brand's own src
//      plus a staged source tree for each DECLARED unpublished family dep (IR at
//      the sibling repo, facts at elm-cem/facts/src). Because staging is gated by
//      the declared deps, an `import HtmlIr.*` with the IR dep MISSING is
//      unresolvable and the compile FAILS — catching NB1 at compile level, the
//      thing the old app-shaped gates could not.
//
// The scratch package.json's `dependencies` for the non-family (elm/*) side are
// taken VERBATIM from the real committed elm.json (minus the family packages,
// which are staged instead of declared) — NOT a hardcoded assumed set. Earlier
// this stamped `family.baseDependencies()` (a fixed {elm/core, elm/html,
// elm/json, elm/virtual-dom}) unconditionally, so a real elm.json that omitted
// elm/json or elm/virtual-dom still "compiled registry-faithfully": the check
// silently supplied the missing dep itself instead of testing whether it was
// actually declared. This is exactly how a downstream brand's standalone icon
// sub-package shipped an elm.json missing two base deps (needed transitively
// via a staged IR internals module) undetected — friction
// 20260812T012700Z. Using the real declared set makes a missing base dep
// unresolvable at compile time, same mechanism as NB1 for family deps.
//
// A brand's generator can ALSO write standalone NESTED package trees alongside
// the main package (config-driven via `_iconModule.package` — an icon
// sub-package with no components dependency is the first user). Those were
// never registry-checked — only regen-drift's `--nested-pkg` covered them, and
// drift only proves "matches a fresh regen", not "the regen itself declares a
// self-sufficient elm.json". `--nested-pkg=<dir>` here (repeatable) runs the
// SAME audit+compile check against each nested package's own elm.json/src, so a
// missing dep is caught whether it lives in the root package or a nested one.
//
// Portable: no absolute paths. Family-dep sources are resolved from a sibling
// layout (or --dep-src / IR_SRC / FACTS_SRC overrides). Run from a brand root.
//
// Usage:
//   elm-cem registry-check
//   elm-cem registry-check [--elm-json=elm.json] [--elm=<path>] [--dep-src=<owner/pkg>=<srcdir> ...] [--no-audit] [--nested-pkg=<dir> ...]
//
// Exit 0 = the package (and every --nested-pkg) is registry-faithful. Exit 1 =
// audit violation, missing/undeclared dep, or compile failure in any of them
// (the failing one is named in the output).

"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawnSync } = require("child_process");
const family = require("./family-deps");

function fail(msg) {
  console.error(`registry-check: FAIL — ${msg}`);
  process.exit(1);
}

function usage() {
  console.log(
    [
      "elm-cem registry-check — prove a publishable package compiles as it would from the registry.",
      "",
      "Run from a brand repo root. Reads the committed package elm.json, runs the",
      "static family-dep coverage gate (#48), then a package-shaped compile whose",
      "resolvable modules come STRICTLY from the declared dependencies — so an",
      "undeclared family import (NB1) fails to compile.",
      "",
      "Options:",
      "  --elm-json=<path>            package elm.json (default: elm.json)",
      "  --elm=<path>                 elm 0.19.1 binary (auto-resolved)",
      "  --dep-src=<owner/pkg>=<dir>  map an unpublished family dep to its local src/ (repeatable)",
      "  --no-audit                   skip the static coverage gate (compile only)",
      "  --nested-pkg=<dir>           also audit+compile <dir>/elm.json + <dir>/src as its own",
      "                               package (a standalone nested package the generator",
      "                               writes, e.g. an icon sub-package); repeatable",
      "  -h, --help                   show this help",
    ].join("\n")
  );
}

function parseArgs(argv) {
  const o = { depSrcs: {}, nestedPkg: [] };
  for (const a of argv) {
    if (a === "-h" || a === "--help") o.help = true;
    else if (a === "--no-audit") o.noAudit = true;
    else if (a.startsWith("--elm-json=")) o.elmJson = a.slice("--elm-json=".length);
    else if (a.startsWith("--elm=")) o.elm = a.slice("--elm=".length);
    else if (a.startsWith("--nested-pkg=")) o.nestedPkg.push(a.slice("--nested-pkg=".length));
    else if (a.startsWith("--dep-src=")) {
      const spec = a.slice("--dep-src=".length);
      const eq = spec.indexOf("=");
      if (eq === -1) fail(`bad --dep-src (want <owner/pkg>=<dir>): ${spec}`);
      o.depSrcs[spec.slice(0, eq)] = path.resolve(process.cwd(), spec.slice(eq + 1));
    } else fail(`unknown argument: ${a}`);
  }
  return o;
}

// Resolve elm from the brand's node_modules, then this elm-cem's, walking up.
function resolveElm() {
  const binName = process.platform === "win32" ? "elm.cmd" : "elm";
  const roots = [process.cwd(), path.resolve(__dirname, "..")];
  const seen = new Set();
  for (const start of roots) {
    let dir = start;
    while (dir && !seen.has(dir)) {
      seen.add(dir);
      const cand = path.join(dir, "node_modules", ".bin", binName);
      if (fs.existsSync(cand)) return cand;
      const parent = path.dirname(dir);
      if (parent === dir) break;
      dir = parent;
    }
  }
  return null;
}

// Local src/ tree for an unpublished family dep. Explicit --dep-src wins; then
// env overrides; then a sibling layout (works whether the sibling is next to the
// brand or next to this elm-cem checkout). Portable — no absolute paths baked in.
function resolveFamilySrc(pkg, depSrcs) {
  if (depSrcs[pkg]) return depSrcs[pkg];
  const candidates = [];
  if (pkg === "jackhp95/elm-virtual-dom-intermediate-representation") {
    if (process.env.IR_SRC) candidates.push(process.env.IR_SRC);
    // in-repo renamed symlink inside elm-cem (workspace)
    candidates.push(path.resolve(__dirname, "..", "elm-virtual-dom-intermediate-representation", "src"));
    // workspace top-level packages/ location
    candidates.push(path.resolve(__dirname, "..", "..", "..", "packages", "elm-virtual-dom-intermediate-representation", "src"));
    // sibling of this elm-cem checkout (standalone; external mirror dir name)
    candidates.push(path.resolve(__dirname, "..", "..", "elm-html-intermediate-representation", "src"));
    // sibling of the brand repo being checked (standalone; external mirror dir name)
    candidates.push(path.resolve(process.cwd(), "..", "elm-html-intermediate-representation", "src"));
  } else if (pkg === "jackhp95/elm-cem-facts") {
    if (process.env.FACTS_SRC) candidates.push(process.env.FACTS_SRC);
    candidates.push(path.resolve(__dirname, "..", "facts", "src"));
    candidates.push(path.resolve(process.cwd(), "..", "elm-cem", "facts", "src"));
  }
  return candidates.find((c) => c && fs.existsSync(c)) || null;
}

// Deep-merge a src tree into a scratch src/: recurse into directories (creating
// real dirs in the scratch) and symlink each FILE, skipping any that already
// exists. File-granularity (not top-level-entry) merging is required when two
// staged family packages SPLIT one namespace — e.g. jackhp95/elm-m3e-core owns
// `M3e/Attributes.elm` while jackhp95/elm-m3e-components owns `M3e/Component/*`
// and `M3e.elm`; both live under `M3e/`, so a coarse top-level symlink of `M3e`
// would let the first-staged package hide the other's modules.
function stageInto(depSrc, scratchSrc) {
  for (const entry of fs.readdirSync(depSrc, { withFileTypes: true })) {
    const from = path.join(depSrc, entry.name);
    const to = path.join(scratchSrc, entry.name);
    if (entry.isDirectory()) {
      fs.mkdirSync(to, { recursive: true });
      stageInto(from, to);
    } else if (!fs.existsSync(to)) {
      fs.symlinkSync(from, to);
    }
  }
}

// Run the full audit+compile check against ONE package (root or nested).
// `label` prefixes every message so a failure names which package it is.
function checkPackage(elmJsonPath, label, o) {
  const cwd = process.cwd();
  const prefix = label ? `[${label}] ` : "";
  const fail1 = (msg) => fail(`${prefix}${msg}`);

  let elmJson;
  try {
    elmJson = JSON.parse(fs.readFileSync(elmJsonPath, "utf8"));
  } catch (e) {
    return fail1(`cannot read ${elmJsonPath}: ${e.message}`);
  }
  if (elmJson.type !== "package") {
    fail1(`${elmJsonPath} is not a package elm.json (type=${elmJson.type})`);
  }
  const pkgDir = path.dirname(elmJsonPath);
  const srcDir = path.join(pkgDir, "src");
  if (!fs.existsSync(srcDir)) {
    fail1(`no src/ next to ${elmJsonPath}`);
  }

  const declared = elmJson.dependencies || {};
  const exposed = elmJson["exposed-modules"] || [];
  if (exposed.length === 0) {
    fail1("elm.json exposes no modules — unpublishable (the B8 empty-exposure trap).");
  }

  // Resolve a staged src tree for every DECLARED unpublished dep that is not a
  // base elm/* package. The fixed family deps (IR, facts) auto-resolve from the
  // sibling layout; ANY other intra-family dep (e.g. jackhp95/elm-m3e-core when
  // checking jackhp95/elm-m3e-components) must be mapped with
  // --dep-src=<owner/pkg>=<dir>. Staging is gated by `declared`, NOT by what src
  // imports — that gating is precisely what makes an undeclared import
  // unresolvable, catching NB1 at compile time — and it now generalizes past the
  // fixed family list so a split family (core <- components <- builder) is
  // registry-checkable. Resolved BEFORE the audit so the audit can see what the
  // siblings expose.
  const baseNames = new Set(Object.keys(family.BASE_ELM_DEPS));
  const stagedDeps = [];
  for (const depPkg of Object.keys(declared)) {
    if (baseNames.has(depPkg)) continue; // elm/* stay as declared base deps
    const depSrc = o.depSrcs[depPkg] || resolveFamilySrc(depPkg, o.depSrcs);
    if (!depSrc) {
      fail1(
        `elm.json declares ${depPkg} but its local src/ was not found — pass --dep-src=${depPkg}=<dir> (or set IR_SRC/FACTS_SRC for the known family deps).`
      );
    }
    stagedDeps.push({ package: depPkg, src: depSrc });
  }

  // Module names exposed by each staged dep (read from the dep's own elm.json,
  // conventionally at <src>/../elm.json). Feeds the audit so imports of a sibling
  // that shares this package's namespace root (e.g. components importing core's
  // M3e.Attributes) resolve instead of looking foreign.
  const providedModules = new Set();
  for (const dep of stagedDeps) {
    const depElmJson = path.join(path.dirname(dep.src), "elm.json");
    try {
      const ej = JSON.parse(fs.readFileSync(depElmJson, "utf8"));
      for (const m of ej["exposed-modules"] || []) providedModules.add(m);
    } catch (_e) {
      /* dep elm.json unreadable — audit falls back to the FAMILY_DEPS table */
    }
  }

  // ── 1. static coverage gate (#48) ──────────────────────────────────────────
  if (!o.noAudit) {
    const violations = family.auditPackage(pkgDir, providedModules);
    if (violations.length) {
      console.error(`registry-check: ${prefix}static coverage gate FAILED:`);
      for (const v of violations) console.error(`  - ${v}`);
      fail1(`${violations.length} undeclared-import violation(s) — the NB1 class. Declare the dep in elm.json.`);
    }
    console.log(`registry-check: OK — ${prefix}static family-dep coverage gate passes.`);
  }

  // ── 2. registry-faithful compile ───────────────────────────────────────────
  const elm = o.elm ? path.resolve(cwd, o.elm) : resolveElm();
  if (!elm || !fs.existsSync(elm)) {
    fail1("elm binary not found — pass --elm=<path> or run `elm-tooling install`.");
  }

  const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-registry-check-"));
  const scratchSrc = path.join(scratch, "src");
  fs.mkdirSync(scratchSrc, { recursive: true });

  // Stage the brand src + each declared family dep's src into one package src/.
  stageInto(srcDir, scratchSrc);
  for (const dep of stagedDeps) stageInto(dep.src, scratchSrc);

  // Non-family (elm/*) deps come VERBATIM from the real committed elm.json — NOT
  // a hardcoded assumed set — so a missing base dep (e.g. elm/json) is absent
  // here too and the compile below fails to resolve it, same as any other
  // undeclared dep. Family deps are excluded: they're simulated by staging their
  // src directly, not by declaring an unpublished package name to `elm make`.
  const stagedNames = new Set(stagedDeps.map((d) => d.package));
  const baseDeclared = Object.fromEntries(Object.entries(declared).filter(([pkg]) => !stagedNames.has(pkg)));

  // A package-shaped elm.json exposing the brand's real exposed surface. `elm
  // make --docs` is what `elm publish` runs, so this mirrors the registry
  // compile, including the exposed-doc-comment requirement.
  const scratchElmJson = {
    type: "package",
    name: elmJson.name || "registry/check",
    summary: elmJson.summary || "registry-faithful compile check",
    license: elmJson.license || "BSD-3-Clause",
    version: elmJson.version || "1.0.0",
    "exposed-modules": [...exposed].sort(),
    "elm-version": elmJson["elm-version"] || "0.19.0 <= v < 0.20.0",
    dependencies: baseDeclared,
    "test-dependencies": {},
  };
  fs.writeFileSync(path.join(scratch, "elm.json"), JSON.stringify(scratchElmJson, null, 4) + "\n");

  console.log(
    `registry-check: ${prefix}compiling ${scratchElmJson.name} (${exposed.length} exposed module(s)) as a package` +
      (stagedDeps.length ? ` with staged dep(s): ${stagedDeps.map((d) => d.package).join(", ")}` : "") +
      " ..."
  );
  const r = spawnSync(elm, ["make", "--docs", "docs.json"], { cwd: scratch, encoding: "utf8" });
  const status = r.status;
  const out = (r.stdout || "") + (r.stderr || "");
  fs.rmSync(scratch, { recursive: true, force: true });

  if (status !== 0) {
    console.error(out);
    fail1(
      `package-shaped compile failed. If the error is an unresolved import (e.g. HtmlIr.* / Cem.Facts / Json.* / VirtualDom), ` +
        `elm.json is missing that dependency — the NB1 class (now also covers base elm/* deps, not just family deps).`
    );
  }
  console.log(`registry-check: OK — ${prefix}package compiles registry-faithfully (elm make --docs succeeded).`);
}

function run(argv) {
  const o = parseArgs(argv);
  if (o.help) {
    usage();
    process.exit(0);
  }

  const cwd = process.cwd();
  const rootElmJsonPath = path.resolve(cwd, o.elmJson || "elm.json");
  checkPackage(rootElmJsonPath, o.nestedPkg.length ? "root" : "", o);

  for (const dir of o.nestedPkg) {
    const nestedElmJsonPath = path.resolve(cwd, dir, "elm.json");
    if (!fs.existsSync(nestedElmJsonPath)) {
      fail(`--nested-pkg=${dir} configured but no elm.json found at ${nestedElmJsonPath}`);
    }
    checkPackage(nestedElmJsonPath, `nested package "${dir}"`, o);
  }
}

module.exports = { run };

// Direct invocation must do the same work as `elm-cem <subcommand>`. Without this
// guard the file loads, exports `run`, calls nothing, prints nothing and exits 0 —
// a gate reporting success without doing its work, which is precisely the failure
// these scripts exist to prevent. It nearly banked a false "verified" once: an
// agent checking elm-review-cem's neutrality gate ran this file directly, got a
// clean exit 0, and only doubted it because an expected log line never printed.
if (require.main === module) run(process.argv.slice(2));
