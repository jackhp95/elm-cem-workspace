// elm-cem brand-sync — scaffold/sync a brand's tooling from the family template
// (issue #50). A brand carries only config; the gate logic, CI, and review
// config are owned by elm-cem and materialized here so drift is impossible.
//
// Syncs (all idempotent):
//   - package.json  : the standard gate scripts (gate/validate/acid/format/
//                     review/build/postinstall) + canonical `gen`; removes the
//                     now-centralized per-brand scripts (measure-docs,
//                     isolation-probe, gate:drift, gate:registry).
//   - .github/workflows/ci.yml : verbatim from templates/ci.yml (byte-identical
//                     across brands — no token).
//   - review/src/ReviewConfig.elm : from templates/ReviewConfig.elm, {{LIB}} /
//                     {{BRAND}} substituted (identical-modulo-token across brands).
//   - README.md     : from templates/README.skeleton.md, only when missing
//                     (or --force-readme) — an existing README is never clobbered.
//
// Portable: no absolute paths; the brand invokes elm-cem via ELM_CEM_BIN.
//
// Usage (from a brand repo root):
//   elm-cem brand-sync [--lib=<Prefix>] [--brand=<name>] [--config-from=<json> ...]
//                      [--preserve-gen] [--skip-review] [--force-readme] [--check]
//
//   --check  : do not write; exit 1 if ci.yml / ReviewConfig differ from template.

"use strict";

const fs = require("fs");
const path = require("path");

const TEMPLATES = path.resolve(__dirname, "..", "templates");

function fail(msg) {
  console.error(`brand-sync: FAIL — ${msg}`);
  process.exit(1);
}

function usage() {
  console.log(
    [
      "elm-cem brand-sync — materialize a brand's gate scripts + ci.yml + ReviewConfig + README from the family template.",
      "",
      "Run from a brand repo root.",
      "",
      "Options:",
      "  --lib=<Prefix>        brand module prefix (e.g. W, Sl, Calcite); inferred from src/ if omitted",
      "  --brand=<name>        package name (default: package.json name)",
      "  --config-from=<json>  config file for the canonical gen script (repeatable; default config/slots.json)",
      "  --cem=<path>          set package.json config.cem to this manifest path",
      "  --preserve-gen        keep the existing `gen` script (do not rewrite to canonical form)",
      "  --skip-review         do not write review/src/ReviewConfig.elm",
      "  --force-readme        overwrite an existing README.md with the skeleton",
      "  --check               verify-only: exit 1 if ci.yml / ReviewConfig drift from template",
      "  -h, --help            show this help",
    ].join("\n")
  );
}

function parseArgs(argv) {
  const o = { configFrom: [] };
  for (const a of argv) {
    if (a === "-h" || a === "--help") o.help = true;
    else if (a === "--preserve-gen") o.preserveGen = true;
    else if (a === "--skip-review") o.skipReview = true;
    else if (a === "--force-readme") o.forceReadme = true;
    else if (a === "--check") o.check = true;
    else if (a.startsWith("--lib=")) o.lib = a.slice("--lib=".length);
    else if (a.startsWith("--brand=")) o.brand = a.slice("--brand=".length);
    else if (a.startsWith("--cem=")) o.cem = a.slice("--cem=".length);
    else if (a.startsWith("--config-from=")) o.configFrom.push(a.slice("--config-from=".length));
    else fail(`unknown argument: ${a}`);
  }
  return o;
}

// The library module prefix = the src/*.elm barrel whose name has a matching
// src/<Name>/ subdirectory (W ↔ W/, Sl ↔ Sl/, …).
function inferLib(cwd) {
  const srcDir = path.join(cwd, "src");
  if (!fs.existsSync(srcDir)) return null;
  const entries = fs.readdirSync(srcDir, { withFileTypes: true });
  const dirs = new Set(entries.filter((e) => e.isDirectory()).map((e) => e.name));
  const barrels = entries
    .filter((e) => e.isFile() && e.name.endsWith(".elm"))
    .map((e) => e.name.replace(/\.elm$/, ""))
    .filter((n) => dirs.has(n));
  return barrels.sort((a, b) => a.length - b.length)[0] || null;
}

function renderReviewConfig(lib, brand) {
  const tpl = fs.readFileSync(path.join(TEMPLATES, "ReviewConfig.elm"), "utf8");
  return tpl.split("{{LIB}}").join(lib).split("{{BRAND}}").join(brand);
}

function renderReadme(lib, brand) {
  const tpl = fs.readFileSync(path.join(TEMPLATES, "README.skeleton.md"), "utf8");
  return tpl.split("{{LIB}}").join(lib).split("{{BRAND}}").join(brand);
}

function ciYml() {
  return fs.readFileSync(path.join(TEMPLATES, "ci.yml"), "utf8");
}

function prePushHook() {
  return fs.readFileSync(path.join(TEMPLATES, "pre-push"), "utf8");
}

const ELM_CEM = '"${ELM_CEM_BIN:-../elm-cem/bin/elm-cem.js}"';

// Pinned so every brand resolves the same run-p/run-s, and so a brand that has
// never installed it gets a working `check` on first `npm install`.
const NPM_RUN_ALL_VERSION = "^9.0.3";

// The family script convention (planning/2026-08-04-script-convention-plan.md):
//
//   gen:*    writes git-tracked files        build:*  untracked artifacts
//   check:*  verifies, writes nothing        test:*   runs a suite
//
// Bare `check` is a glob combo, so a new check joins the gate the moment it is
// defined rather than when someone remembers to add it. Every step is ALSO
// runnable on its own — `elm-cem gate` is decomposed into check:drift /
// check:registry / check:acid so you can run just the one you are iterating on.
function standardScripts(existing, o) {
  const s = { ...existing };

  // Remove per-brand scripts centralized into elm-cem subcommands, plus the
  // pre-convention names now superseded (validate -> check:docs-size,
  // acid -> check:acid, review -> check:review, format:check -> check:format,
  // and `build`, which conflated generation with verification).
  for (const dead of [
    "measure-docs",
    "isolation-probe",
    "gate:drift",
    "gate:registry",
    "whatwg",
    "validate",
    "acid",
    "review",
    "format:check",
    "build",
  ]) {
    delete s[dead];
  }

  // `hooks:install` points git at the committed hooks/ dir; postinstall runs it
  // so a fresh `npm install` arms the pre-push gate without a manual step.
  s["hooks:install"] = "git config core.hooksPath hooks";
  s.postinstall = "elm-tooling install && npm run hooks:install";

  // --- check:* — each one independently runnable -----------------------------
  s["check:format"] = "node_modules/.bin/elm-format tests/ --validate";
  s["check:review"] = "node_modules/.bin/elm-review --config review";
  s["check:drift"] = `node ${ELM_CEM} regen-drift`;
  s["check:registry"] = `node ${ELM_CEM} registry-check`;
  s["check:acid"] = `node ${ELM_CEM} acid`;
  s["check:gates"] = `node ${ELM_CEM} check-gates`;
  s["check:docs-size"] = `node ${ELM_CEM} validate`;

  // --- combos ----------------------------------------------------------------
  // run-p: these are independent, so parallel is both correct and faster.
  s.check = 'run-p "check:*"';
  // `gate` is what hooks/pre-push runs. It picks up test:* only if the brand has
  // any — `run-p` errors when a pattern matches nothing, and most brands have no
  // test suite beyond the acid probes already covered by check:acid.
  const hasTests = Object.keys(s).some((k) => k.startsWith("test:"));
  if (hasTests) s.test = 'run-p "test:*"';
  s.gate = hasTests ? "run-s check test" : "npm run check";

  // `format` WRITES, so it is not a check:* — it is the fix for check:format.
  s.format = "node_modules/.bin/elm-format tests/ --yes";

  // A brand whose `gen` does not invoke elm-cem has a BESPOKE pipeline, and
  // clobbering it is destructive: elm-typed-html builds from its own
  // `manifest/native.cem.json` via `scripts/regen.sh`, and overwriting its `gen`
  // with the canonical one made the next `npm run gen` delete all of `src/`.
  // Preserve it by default and say so; `--preserve-gen` remains for the explicit case.
  const bespokeGen =
    typeof s.gen === "string" && s.gen.length > 0 && !/elm-cem|ELM_CEM/.test(s.gen);
  if (bespokeGen) {
    console.log(
      `brand-sync: preserving bespoke \`gen\` (${s.gen.slice(0, 60)}…) — it does not invoke elm-cem`
    );
  }

  if (!o.preserveGen && !bespokeGen) {
    const cfgs = (o.configFrom.length ? o.configFrom : ["config/slots.json"])
      .map((c) => `--config-from=${c}`)
      .join(" ");
    s.gen =
      `PATH="$PWD/node_modules/.bin:$PATH" node ${ELM_CEM} ` +
      `--flags-from=$npm_package_config_cem ${cfgs} --output=src && ` +
      `node_modules/.bin/elm-format src --yes`;
  }
  return s;
}

function writeIfChanged(file, content, results, label) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const prev = fs.existsSync(file) ? fs.readFileSync(file, "utf8") : null;
  if (prev === content) {
    results.push(`  unchanged  ${label}`);
    return;
  }
  fs.writeFileSync(file, content);
  results.push(`  ${prev === null ? "created  " : "updated  "}  ${label}`);
}

function run(argv) {
  const o = parseArgs(argv);
  if (o.help) {
    usage();
    process.exit(0);
  }

  const cwd = process.cwd();
  const pkgPath = path.join(cwd, "package.json");
  if (!fs.existsSync(pkgPath)) fail("no package.json in cwd — run from a brand repo root.");
  const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));

  const brand = o.brand || pkg.name;
  const lib = o.lib || inferLib(cwd);
  if (!lib) fail("could not infer the library module prefix — pass --lib=<Prefix>.");

  const ci = ciYml();
  const review = renderReviewConfig(lib, brand);

  // ── --check: verify-only (used by a drift test) ────────────────────────────
  if (o.check) {
    let drift = 0;
    const ciFile = path.join(cwd, ".github", "workflows", "ci.yml");
    if (!fs.existsSync(ciFile) || fs.readFileSync(ciFile, "utf8") !== ci) {
      console.error("brand-sync --check: ci.yml differs from template");
      drift++;
    }
    if (!o.skipReview) {
      const rvFile = path.join(cwd, "review", "src", "ReviewConfig.elm");
      if (!fs.existsSync(rvFile) || fs.readFileSync(rvFile, "utf8") !== review) {
        console.error("brand-sync --check: review/src/ReviewConfig.elm differs from template");
        drift++;
      }
    }
    const hookFile = path.join(cwd, "hooks", "pre-push");
    if (!fs.existsSync(hookFile) || fs.readFileSync(hookFile, "utf8") !== prePushHook()) {
      console.error("brand-sync --check: hooks/pre-push differs from template");
      drift++;
    }
    if (drift) fail(`${drift} generated file(s) drifted — run \`elm-cem brand-sync\`.`);
    console.log("brand-sync --check: OK — generated files match the template.");
    return;
  }

  const results = [];

  // package.json scripts + config.cem
  pkg.scripts = standardScripts(pkg.scripts || {}, o);

  // The combo scripts call run-p/run-s, so the tool that provides them has to be
  // declared here. Scaffolding scripts a brand cannot run would be worse than
  // scaffolding none. npm-run-all2 is the maintained fork of npm-run-all.
  pkg.devDependencies = pkg.devDependencies || {};
  if (!pkg.devDependencies["npm-run-all2"]) {
    pkg.devDependencies["npm-run-all2"] = NPM_RUN_ALL_VERSION;
  }
  if (o.cem) {
    pkg.config = pkg.config || {};
    pkg.config.cem = o.cem;
  }
  const nextPkg = JSON.stringify(pkg, null, 2) + "\n";
  writeIfChanged(pkgPath, nextPkg, results, "package.json (scripts)");

  // ci.yml
  writeIfChanged(path.join(cwd, ".github", "workflows", "ci.yml"), ci, results, ".github/workflows/ci.yml");

  // hooks/pre-push — the primary gate. Written executable; `hooks:install`
  // (run by postinstall) points core.hooksPath at it.
  const hookPath = path.join(cwd, "hooks", "pre-push");
  writeIfChanged(hookPath, prePushHook(), results, "hooks/pre-push");
  fs.chmodSync(hookPath, 0o755);

  // ReviewConfig.elm
  if (!o.skipReview) {
    writeIfChanged(path.join(cwd, "review", "src", "ReviewConfig.elm"), review, results, "review/src/ReviewConfig.elm");
  }

  // README.md — only when missing, unless --force-readme.
  const readmePath = path.join(cwd, "README.md");
  if (!fs.existsSync(readmePath) || o.forceReadme) {
    writeIfChanged(readmePath, renderReadme(lib, brand), results, "README.md");
  } else {
    results.push("  skipped    README.md (exists; pass --force-readme to overwrite)");
  }

  console.log(`brand-sync: ${brand} (lib=${lib})`);
  for (const r of results) console.log(r);
  console.log("brand-sync: done.");
}

module.exports = { run };

// Direct invocation must do the same work as `elm-cem <subcommand>`. Without this
// guard the file loads, exports `run`, calls nothing, prints nothing and exits 0 —
// a gate reporting success without doing its work, which is precisely the failure
// these scripts exist to prevent. It nearly banked a false "verified" once: an
// agent checking elm-review-cem's neutrality gate ran this file directly, got a
// clean exit 0, and only doubted it because an expected log line never printed.
if (require.main === module) run(process.argv.slice(2));
