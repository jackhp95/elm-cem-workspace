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
// Portable: no absolute paths. Family-dep sources are resolved from a sibling
// layout (or --dep-src / IR_SRC / FACTS_SRC overrides). Run from a brand root.
//
// Usage:
//   elm-cem registry-check
//   elm-cem registry-check [--elm-json=elm.json] [--elm=<path>] [--dep-src=<owner/pkg>=<srcdir> ...] [--no-audit]
//
// Exit 0 = the package is registry-faithful. Exit 1 = audit violation or compile
// failure (the deliberately-undeclared-dep case fails here).

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
      "  -h, --help                   show this help",
    ].join("\n")
  );
}

function parseArgs(argv) {
  const o = { depSrcs: {} };
  for (const a of argv) {
    if (a === "-h" || a === "--help") o.help = true;
    else if (a === "--no-audit") o.noAudit = true;
    else if (a.startsWith("--elm-json=")) o.elmJson = a.slice("--elm-json=".length);
    else if (a.startsWith("--elm=")) o.elm = a.slice("--elm=".length);
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
  if (pkg === "jackhp95/elm-html-intermediate-representation") {
    if (process.env.IR_SRC) candidates.push(process.env.IR_SRC);
    // sibling of this elm-cem checkout (…/elm-cem/../elm-html-…/src)
    candidates.push(path.resolve(__dirname, "..", "..", "elm-html-intermediate-representation", "src"));
    // in-repo symlink inside elm-cem
    candidates.push(path.resolve(__dirname, "..", "elm-html-intermediate-representation", "src"));
    // sibling of the brand repo being checked
    candidates.push(path.resolve(process.cwd(), "..", "elm-html-intermediate-representation", "src"));
  } else if (pkg === "jackhp95/elm-cem-facts") {
    if (process.env.FACTS_SRC) candidates.push(process.env.FACTS_SRC);
    candidates.push(path.resolve(__dirname, "..", "facts", "src"));
    candidates.push(path.resolve(process.cwd(), "..", "elm-cem", "facts", "src"));
  }
  return candidates.find((c) => c && fs.existsSync(c)) || null;
}

// Recursively symlink a src tree's top-level entries into a scratch src/.
function stageInto(depSrc, scratchSrc) {
  for (const entry of fs.readdirSync(depSrc)) {
    const link = path.join(scratchSrc, entry);
    if (!fs.existsSync(link)) {
      fs.symlinkSync(path.join(depSrc, entry), link);
    }
  }
}

function run(argv) {
  const o = parseArgs(argv);
  if (o.help) {
    usage();
    process.exit(0);
  }

  const cwd = process.cwd();
  const elmJsonPath = path.resolve(cwd, o.elmJson || "elm.json");
  let elmJson;
  try {
    elmJson = JSON.parse(fs.readFileSync(elmJsonPath, "utf8"));
  } catch (e) {
    return fail(`cannot read ${elmJsonPath}: ${e.message}`);
  }
  if (elmJson.type !== "package") {
    fail(`${elmJsonPath} is not a package elm.json (type=${elmJson.type})`);
  }
  const pkgDir = path.dirname(elmJsonPath);
  const srcDir = path.join(pkgDir, "src");
  if (!fs.existsSync(srcDir)) {
    fail(`no src/ next to ${elmJsonPath}`);
  }

  // ── 1. static coverage gate (#48) ──────────────────────────────────────────
  if (!o.noAudit) {
    const violations = family.auditPackage(pkgDir);
    if (violations.length) {
      console.error("registry-check: static coverage gate FAILED:");
      for (const v of violations) console.error(`  - ${v}`);
      fail(`${violations.length} undeclared-import violation(s) — the NB1 class. Declare the dep in elm.json.`);
    }
    console.log("registry-check: OK — static family-dep coverage gate passes.");
  }

  // ── 2. registry-faithful compile ───────────────────────────────────────────
  const elm = o.elm ? path.resolve(cwd, o.elm) : resolveElm();
  if (!elm || !fs.existsSync(elm)) {
    fail("elm binary not found — pass --elm=<path> or run `elm-tooling install`.");
  }

  const declared = elmJson.dependencies || {};
  const exposed = elmJson["exposed-modules"] || [];
  if (exposed.length === 0) {
    fail("elm.json exposes no modules — unpublishable (the B8 empty-exposure trap).");
  }

  // Resolve a staged src tree for every DECLARED unpublished family dep. Staging
  // is gated by `declared`, NOT by what src imports — that gating is precisely
  // what makes an undeclared import unresolvable, catching NB1 at compile time.
  const stagedDeps = [];
  for (const dep of family.FAMILY_DEPS) {
    if (dep.package in declared) {
      const depSrc = resolveFamilySrc(dep.package, o.depSrcs);
      if (!depSrc) {
        fail(
          `elm.json declares ${dep.package} but its local src/ was not found — pass --dep-src=${dep.package}=<dir> (or set IR_SRC/FACTS_SRC).`
        );
      }
      stagedDeps.push({ package: dep.package, src: depSrc });
    }
  }

  const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-registry-check-"));
  const scratchSrc = path.join(scratch, "src");
  fs.mkdirSync(scratchSrc, { recursive: true });

  // Stage the brand src + each declared family dep's src into one package src/.
  stageInto(srcDir, scratchSrc);
  for (const dep of stagedDeps) stageInto(dep.src, scratchSrc);

  // A package-shaped elm.json exposing the brand's real exposed surface. Its
  // `dependencies` are only the base elm/* deps — the unpublished family deps are
  // simulated as "published" ONLY by having been staged into src/ above (and only
  // when declared). `elm make --docs` is what `elm publish` runs, so this mirrors
  // the registry compile, including the exposed-doc-comment requirement.
  const scratchElmJson = {
    type: "package",
    name: elmJson.name || "registry/check",
    summary: elmJson.summary || "registry-faithful compile check",
    license: elmJson.license || "BSD-3-Clause",
    version: elmJson.version || "1.0.0",
    "exposed-modules": [...exposed].sort(),
    "elm-version": elmJson["elm-version"] || "0.19.0 <= v < 0.20.0",
    dependencies: family.baseDependencies(),
    "test-dependencies": {},
  };
  fs.writeFileSync(path.join(scratch, "elm.json"), JSON.stringify(scratchElmJson, null, 4) + "\n");

  console.log(
    `registry-check: compiling ${scratchElmJson.name} (${exposed.length} exposed module(s)) as a package` +
      (stagedDeps.length ? ` with staged dep(s): ${stagedDeps.map((d) => d.package).join(", ")}` : "") +
      " ..."
  );
  const r = spawnSync(elm, ["make", "--docs", "docs.json"], { cwd: scratch, encoding: "utf8" });
  const status = r.status;
  const out = (r.stdout || "") + (r.stderr || "");
  fs.rmSync(scratch, { recursive: true, force: true });

  if (status !== 0) {
    console.error(out);
    fail(
      `package-shaped compile failed. If the error is an unresolved import (e.g. HtmlIr.* / Cem.Facts), ` +
        `elm.json is missing that dependency — the NB1 class.`
    );
  }
  console.log("registry-check: OK — package compiles registry-faithfully (elm make --docs succeeded).");
}

module.exports = { run };

// Direct invocation must do the same work as `elm-cem <subcommand>`. Without this
// guard the file loads, exports `run`, calls nothing, prints nothing and exits 0 —
// a gate reporting success without doing its work, which is precisely the failure
// these scripts exist to prevent. It nearly banked a false "verified" once: an
// agent checking elm-review-cem's neutrality gate ran this file directly, got a
// clean exit 0, and only doubted it because an expected log line never printed.
if (require.main === module) run(process.argv.slice(2));
