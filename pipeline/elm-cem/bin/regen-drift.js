// elm-cem regen-drift gate (issue #49, finding NB5 / the B22/B3 class).
//
// Regenerates a brand from its manifest (CEM) + config into a throwaway temp
// dir, elm-formats it, and diffs the result against the committed `src/` and the
// committed `elm.json`'s `exposed-modules` + `dependencies`. Any drift FAILS the
// gate. This is the check whose absence let four brands' committed src fall one
// generator-generation behind (the missing-`styleList` NB5): the only prior
// detection was a manual regen-to-temp-and-diff during the release audit.
//
// It runs from a brand repo root and is fully portable: the CEM path comes from
// the repo's own `package.json` `config.cem` (or --flags-from), config files
// default to `config/slots.json` (or are passed explicitly), and the generator
// binary is this same elm-cem checkout — brands invoke it through an `ELM_CEM_BIN`
// env that defaults to a sibling `../elm-cem/bin/elm-cem.js`. No absolute paths.
//
// A brand's generator can ALSO write standalone NESTED package trees alongside
// the main `src/` (config-driven via `_iconModule.package` — see
// gen-icon-module.js — an icon sub-package with no components dependency is the
// first user of this). Those trees are regenerated into the same temp dir
// (`<work>/<dir>/src`, `<work>/<dir>/elm.json`) by the same codegen run, but were
// NOT diffed by this gate — a silent blind spot (see the drift-gap friction filed
// against the first brand to use it): a hand-edited nested package could drift
// from a fresh regen with the gate reporting green. `--nested-pkg=<dir>`
// (repeatable) closes that gap by running the same src/ + elm.json diff against
// each configured nested package directory.
//
// Usage (from a brand repo root):
//   elm-cem regen-drift
//   elm-cem regen-drift --flags-from=<cem> --config-from=<json> [--config-from=... ] [--src=src] [--elm-json=elm.json] [--nested-pkg=<dir> ...]
//
// Exit 0 = committed output matches a fresh regen. Exit 1 = drift (diff printed).

"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawnSync } = require("child_process");

const CLI = path.join(__dirname, "elm-cem.js");

function fail(msg) {
  console.error(`regen-drift: FAIL — ${msg}`);
  process.exit(1);
}

function usage() {
  console.log(
    [
      "elm-cem regen-drift — fail if committed generated src has drifted from a fresh regen.",
      "",
      "Run from a brand repo root. The CEM defaults to package.json config.cem;",
      "config files default to config/slots.json when present.",
      "",
      "Options:",
      "  --flags-from=<cem>     Custom Elements Manifest (default: package.json config.cem)",
      "  --config-from=<json>   per-component config; repeatable (default: config/slots.json if present)",
      "  --src=<dir>            committed generated source dir to compare (default: src)",
      "  --elm-json=<path>      committed package elm.json to compare (default: elm.json)",
      "  --nested-pkg=<dir>     also diff <dir>/src + <dir>/elm.json (a standalone",
      "                         nested package the generator writes, e.g. an icon",
      "                         sub-package); repeatable",
      "  -h, --help             show this help",
    ].join("\n")
  );
}

function parseArgs(argv) {
  const o = { configFrom: [], nestedPkg: [] };
  for (const a of argv) {
    if (a === "-h" || a === "--help") o.help = true;
    else if (a.startsWith("--flags-from=")) o.flagsFrom = a.slice("--flags-from=".length);
    else if (a.startsWith("--config-from=")) o.configFrom.push(a.slice("--config-from=".length));
    else if (a.startsWith("--src=")) o.src = a.slice("--src=".length);
    else if (a.startsWith("--elm-json=")) o.elmJson = a.slice("--elm-json=".length);
    else if (a.startsWith("--nested-pkg=")) o.nestedPkg.push(a.slice("--nested-pkg=".length));
    else fail(`unknown argument: ${a}`);
  }
  return o;
}

// package.json config.cem in cwd, or null.
function pkgConfigCem(cwd) {
  try {
    const pkg = JSON.parse(fs.readFileSync(path.join(cwd, "package.json"), "utf8"));
    return (pkg.config && pkg.config.cem) || null;
  } catch {
    return null;
  }
}

// Resolve elm-format from the brand's node_modules, then this elm-cem's, walking
// up from each. Returns an absolute path or null.
function resolveElmFormat() {
  const binName = process.platform === "win32" ? "elm-format.cmd" : "elm-format";
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

// git diff --no-index between two paths. Returns the diff text ("" = identical).
// Works outside a git repo and gives readable, reviewable output; exit code 1
// signals a difference, which is exactly the drift signal we want.
function gitDiff(a, b) {
  const r = spawnSync("git", ["diff", "--no-index", "--", a, b], { encoding: "utf8" });
  return r.stdout || "";
}

// The two elm.json fields the generator owns: exposed-modules + dependencies.
// (elm-cem's syncExposedModules writes both; everything else is hand-authored.)
function generatorOwnedElmJson(elmJsonPath) {
  const j = JSON.parse(fs.readFileSync(elmJsonPath, "utf8"));
  return JSON.stringify(
    { "exposed-modules": j["exposed-modules"] || [], dependencies: j.dependencies || {} },
    null,
    2
  );
}

function run(argv) {
  const o = parseArgs(argv);
  if (o.help) {
    usage();
    process.exit(0);
  }

  const cwd = process.cwd();
  const flagsFrom = o.flagsFrom || pkgConfigCem(cwd);
  if (!flagsFrom) {
    fail("no CEM found — pass --flags-from=<cem> or set package.json config.cem");
  }
  const cemAbs = path.resolve(cwd, flagsFrom);
  if (!fs.existsSync(cemAbs)) {
    fail(`CEM not found at ${cemAbs} (install brand deps so its custom-elements.json is materialized?)`);
  }

  let configFrom = o.configFrom;
  if (configFrom.length === 0 && fs.existsSync(path.join(cwd, "config", "slots.json"))) {
    configFrom = ["config/slots.json"];
  }

  const committedSrc = path.resolve(cwd, o.src || "src");
  if (!fs.existsSync(committedSrc)) {
    fail(`committed src dir not found at ${committedSrc}`);
  }
  const committedElmJson = path.resolve(cwd, o.elmJson || "elm.json");

  const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-regen-drift-"));
  const tmpSrc = path.join(work, "src");
  const tmpElmJson = path.join(work, "elm.json");

  // Seed a copy of the committed elm.json so the generator's dep-stamp +
  // exposed-modules sync (syncExposedModules) runs against a realistic file and
  // its output participates in the diff.
  if (fs.existsSync(committedElmJson)) {
    fs.copyFileSync(committedElmJson, tmpElmJson);
  }

  const genArgs = [
    CLI,
    `--flags-from=${cemAbs}`,
    ...configFrom.map((c) => `--config-from=${path.resolve(cwd, c)}`),
    `--output=${tmpSrc}`,
  ];
  console.log(`regen-drift: regenerating from ${path.relative(cwd, cemAbs) || cemAbs} ...`);
  const g = spawnSync("node", genArgs, { cwd, encoding: "utf8", stdio: "inherit" });
  if (g.status !== 0) {
    fail("regeneration failed (see output above)");
  }

  // Normalize formatting exactly as the committed src is normalized at gen time,
  // so the diff surfaces real API drift, not line-wrapping noise. Nested-package
  // trees are formatted too (same rule the committed nested src is expected to
  // follow), or a nested-pkg diff would just be formatting noise.
  const fmt = resolveElmFormat();
  const formatTargets = [tmpSrc, ...o.nestedPkg.map((dir) => path.join(work, dir, "src"))].filter((d) =>
    fs.existsSync(d)
  );
  if (fmt) {
    for (const target of formatTargets) {
      const f = spawnSync(fmt, [target, "--yes"], { encoding: "utf8" });
      if (f.status !== 0) {
        fail(`elm-format failed on the regenerated output at ${target}:\n${f.stderr || f.stdout}`);
      }
    }
  } else {
    console.warn(
      "regen-drift: WARNING — elm-format not found; comparing UNformatted output (drift may be formatting noise)"
    );
  }

  // Diff one committed tree (src + elm.json) against its freshly-regenerated
  // counterpart. `label` prefixes drift output so a failure names which tree
  // (root or a nested package) went stale. Returns true if drift was found.
  function compareTree(label, committedSrcDir, tmpSrcDir, committedElmJsonPath, tmpElmJsonPath) {
    let treeDrift = false;

    const srcDiff = gitDiff(committedSrcDir, tmpSrcDir);
    if (srcDiff.trim()) {
      treeDrift = true;
      console.error(`\nregen-drift: DRIFT in ${label} src/ (committed ⟵ | fresh regen ⟶):`);
      console.error(srcDiff);
    }

    if (fs.existsSync(committedElmJsonPath) && fs.existsSync(tmpElmJsonPath)) {
      const aFile = path.join(work, `committed.${label.replace(/[^\w.-]/g, "_")}.elm.json.slice`);
      const bFile = path.join(work, `regen.${label.replace(/[^\w.-]/g, "_")}.elm.json.slice`);
      fs.writeFileSync(aFile, generatorOwnedElmJson(committedElmJsonPath) + "\n");
      fs.writeFileSync(bFile, generatorOwnedElmJson(tmpElmJsonPath) + "\n");
      const elmJsonDiff = gitDiff(aFile, bFile);
      if (elmJsonDiff.trim()) {
        treeDrift = true;
        console.error(`\nregen-drift: DRIFT in ${label} elm.json exposed-modules / dependencies:`);
        console.error(elmJsonDiff);
      }
    }

    return treeDrift;
  }

  let drift = compareTree("root", committedSrc, tmpSrc, committedElmJson, tmpElmJson);

  for (const dir of o.nestedPkg) {
    const nestedCommittedSrc = path.resolve(cwd, dir, "src");
    const nestedTmpSrc = path.join(work, dir, "src");
    const nestedCommittedElmJson = path.resolve(cwd, dir, "elm.json");
    const nestedTmpElmJson = path.join(work, dir, "elm.json");
    if (!fs.existsSync(nestedCommittedSrc)) {
      fail(`--nested-pkg=${dir} configured but committed src dir not found at ${nestedCommittedSrc}`);
    }
    if (!fs.existsSync(nestedTmpSrc)) {
      fail(
        `--nested-pkg=${dir} configured but the fresh regen wrote nothing to ${nestedTmpSrc} — ` +
          `is the package's _iconModule.package (or equivalent) config still declared?`
      );
    }
    if (compareTree(`nested package "${dir}"`, nestedCommittedSrc, nestedTmpSrc, nestedCommittedElmJson, nestedTmpElmJson)) {
      drift = true;
    }
  }

  fs.rmSync(work, { recursive: true, force: true });

  if (drift) {
    console.error(
      "\nregen-drift: FAIL — committed output is stale. Run the brand's `gen` script and commit the result."
    );
    process.exit(1);
  }
  console.log(
    o.nestedPkg.length > 0
      ? `regen-drift: OK — committed src + elm.json (root + ${o.nestedPkg.length} nested package(s)) match a fresh regen.`
      : "regen-drift: OK — committed src + elm.json match a fresh regen."
  );
}

module.exports = { run };

// Direct invocation must do the same work as `elm-cem <subcommand>`. Without this
// guard the file loads, exports `run`, calls nothing, prints nothing and exits 0 —
// a gate reporting success without doing its work, which is precisely the failure
// these scripts exist to prevent. It nearly banked a false "verified" once: an
// agent checking elm-review-cem's neutrality gate ran this file directly, got a
// clean exit 0, and only doubted it because an expected log line never printed.
if (require.main === module) run(process.argv.slice(2));
