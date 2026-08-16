#!/usr/bin/env node

const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");
const familyDeps = require("./family-deps");
const factsBundle = require("./facts-bundle");

const generateElm = path.resolve(__dirname, "..", "codegen", "Generate.elm");

// Temp files written while rewriting the CEM (alias inlining, config/runtime
// injection) are tracked here and removed after codegen runs — otherwise each
// invocation leaks up to three JSON files into the OS temp dir. `writeTemp`
// creates one; `cleanupTempFiles` removes them all.
const tmpFiles = [];
function writeTemp(prefix, contents) {
  const file = path.join(os.tmpdir(), `${prefix}-${process.pid}.json`);
  fs.writeFileSync(file, contents, { mode: 0o600 });
  tmpFiles.push(file);
  return file;
}
function cleanupTempFiles() {
  for (const f of tmpFiles) {
    try {
      fs.rmSync(f, { force: true });
    } catch {
      // best-effort; a leftover temp file must not fail the run
    }
  }
}
process.on("exit", cleanupTempFiles);

// --help / --version — packaging-level short-circuits that run before any of the
// generation pipeline (no CEM read, no --output deletion). Keeps the CLI usable
// without a manifest.
{
  const rawArgs = process.argv.slice(2);
  if (rawArgs.includes("--version") || rawArgs.includes("-v")) {
    console.log(require("../package.json").version);
    process.exit(0);
  }
  if (rawArgs.length === 0 || rawArgs.includes("--help") || rawArgs.includes("-h")) {
    console.log(
      [
        "elm-cem — generate type-safe Elm bindings from a Custom Elements Manifest.",
        "",
        "Usage:",
        "  elm-cem --flags-from=<custom-elements.json> --output=<dir> [--config-from=<json> ...]",
        "  elm-cem split --packages=<packages.json> --src=<dir> --out=<dir>",
        "  elm-cem regen-drift [--flags-from=<cem>] [--config-from=<json> ...]   (fail on stale committed src)",
        "  elm-cem registry-check [--elm-json=elm.json] [--dep-src=<pkg>=<dir> ...]  (registry-faithful compile)",
        "  elm-cem gate [drift/registry/acid flags]   (regen-drift + registry-check + acid)",
        "  elm-cem validate [--src=src] [--packages=packages.json]   (docs-size gate, <= 700 KB)",
        "  elm-cem check-gates                                       (assert no gate check is silently skipped)",
        "  elm-cem acid [--dir=tests/acid]   (phantom-type probes: positive compile, negative fail)",
        "  elm-cem brand-sync [--lib=<Prefix>]   (scaffold gate scripts + ci.yml + ReviewConfig + README)",
        "  elm-cem eject <brand> --elm-json=<path> [--with-review] [--write]   (pull full brand into vendor/; --dry-run default)",
        "",
        "Options (generate):",
        "  --flags-from=<path>    the Custom Elements Manifest (custom-elements.json) to read (required)",
        "  --output=<dir>         directory to write generated modules to (required).",
        "                         WARNING: existing .elm files in <dir> are DELETED first.",
        "  --config-from=<path>   optional per-component config; may be repeated (deep-merged)",
        "  --facts-bundle=<dir>   also write the M1.c facts bundle (cem-facts.json + elm-api-facts.json) to <dir>",
        "  -h, --help             show this help",
        "  -v, --version          print the elm-cem version",
        "",
        "Options (split):",
        "  --packages=<path>      packages.json describing the facet partition (required)",
        "  --src=<dir>            generated source directory to partition (required)",
        "  --out=<dir>            output directory for per-package mirror trees (required)",
        "",
        "Options (eject — pull a brand's full component surface into your tree):",
        "  <brand>               the brand key, e.g. m3e",
        "  --elm-json=<path>     the consumer elm.json to rewire (required)",
        "  --into=<dir>          vendor dir for the pulled modules (default vendor/<Brand>)",
        "  --ref=<tag|sha>       brand repo ref to pull",
        "  --web-version=<v>     the @m3e/web version to pin in package.json",
        "  --with-review         also wire the elm-review-cem rules",
        "  --write               apply in place (default --dry-run)",
        "",
        "Docs: https://github.com/jackhp95/elm-cem#readme",
      ].join("\n"),
    );
    process.exit(0);
  }

  // Subcommand: split — partition a generated src tree into per-facet mirror trees.
  if (rawArgs[0] === "split") {
    require("./split").run(rawArgs.slice(1));
    process.exit(0);
  }

  // Subcommand: regen-drift — regenerate a brand into a temp dir, elm-format, and
  // diff against the committed src/ + elm.json. Fails on any drift (issue #49,
  // finding NB5 — the gate whose absence let committed src go stale).
  if (rawArgs[0] === "regen-drift") {
    require("./regen-drift").run(rawArgs.slice(1));
    process.exit(0);
  }

  // Subcommand: registry-check — prove a publishable package compiles as it would
  // from the registry (static coverage gate + package-shaped compile whose module
  // resolution is gated by the declared deps). Catches NB1 (issue #49 / B2).
  if (rawArgs[0] === "registry-check") {
    require("./registry-check").run(rawArgs.slice(1));
    process.exit(0);
  }

  // Subcommand: gate — the full brand release gate: regen-drift + registry-check
  // + acid, in order. The one command a brand's `npm run gate` invokes (#50).
  if (rawArgs[0] === "gate") {
    require("./gate").run(rawArgs.slice(1));
    process.exit(0);
  }

  // Subcommand: validate — docs-size gate. Single-package measure, or per-split-
  // package when a packages.json is present (folds the per-brand measure-docs +
  // validate.mjs forks — issue #50).
  if (rawArgs[0] === "validate") {
    require("./validate").run(rawArgs.slice(1));
    process.exit(0);
  }

  // Subcommand: acid — the shared phantom-type ACID gate (positive probes must
  // compile, negative probes must fail). Folds the per-brand acid-probe.mjs
  // forks (issue #50).
  if (rawArgs[0] === "acid") {
    require("./acid").run(rawArgs.slice(1));
    process.exit(0);
  }

  // Subcommand: check-gates — assert no check can be silently switched off.
  // A gate that quietly drops one of its checks is worse than no gate: it
  // produces confident false assurance. See bin/check-gates.js.
  if (rawArgs[0] === "check-gates") {
    require("./check-gates").run();
    process.exit(0);
  }

  // Subcommand: brand-sync — materialize a brand's gate scripts + ci.yml +
  // ReviewConfig + README from the family template so brands carry only config
  // (issue #50).
  if (rawArgs[0] === "brand-sync") {
    require("./brand-sync").run(rawArgs.slice(1));
    process.exit(0);
  }

  // Subcommand: eject — the published-primitives → vendored-full-brand cutover
  // for a consumer's elm.json (docs/distribution-model.md). Pulls the brand's
  // component surface into vendor/<Brand>, adds it to source-directories, removes
  // the superseded published brand dep, promotes the family deps the vendored code
  // imports (detected via bin/family-deps.js), pins @m3e/web, and optionally wires
  // elm-review-cem. --dry-run (default) prints the plan; --write applies it.
  if (rawArgs[0] === "eject") {
    require("./eject").run(rawArgs.slice(1));
    process.exit(0);
  }
}

// M1.c facts bundle: `--facts-bundle=<dir>` is elm-cem's own flag (elm-codegen
// doesn't understand it), so it is stripped before anything else touches argv
// — same treatment as `--config-from`.
const { argv: rawArgvNoFactsFlag, factsBundleDir } = extractFactsBundleDir(process.argv.slice(2));

// Resolve named TS string-literal aliases (e.g. `type ButtonVariant =
// "filled" | "tonal"`) into the CEM before codegen, so attributes typed as a
// bare alias name become real Elm enums instead of falling back to String.
//
// Named (rather than one nested expression) so the facts-bundle wiring below
// can read the CEM at the RECONCILED-but-not-yet-alias-inlined stage — the
// state Face B wants (authoritative tags, still-raw `type.text`).
const afterReconcile = reconcileTagNames(rawArgvNoFactsFlag);
const afterAliases = recordTypeAliases(afterReconcile);
const afterConfig = injectConfig(afterAliases);
const afterNativeAttrs = injectNativeAttrs(afterConfig);
const args = injectFactsBundleFlag(afterNativeAttrs, Boolean(factsBundleDir));
const outputDir = parseOutput(args);
const publishShape = readPublishShape(process.argv.slice(2));

// Clear stale generated modules first, so a module that's no longer emitted
// (e.g. after a rename or an upstream change) doesn't linger in the output.
// Only `.elm` files are removed — any other files in the dir are left alone.
if (outputDir) {
  removeElmFiles(path.resolve(process.cwd(), outputDir));
}

try {
  // Prefer the elm-codegen binary from our own dependency tree, so we run the
  // pinned version rather than whatever bare `npx` might resolve or download.
  // execFileSync (no shell): args are passed as an array, so paths or flag
  // values containing spaces/quotes/shell metacharacters can't be reinterpreted.
  const local = resolveElmCodegen();
  // elm-codegen shells out to `elm`, which it finds on PATH only. When elm-cem is
  // run from a project that keeps elm in node_modules/.bin (not installed
  // globally), `elm` is absent from PATH and elm-codegen fails with an opaque
  // "Compilation failed." — *after* it has already deleted the --output dir,
  // leaving the generated library wiped. Prepend the resolved tool directory
  // (which holds both elm-codegen and elm) so `elm` is always found.
  const binDir = local ? path.dirname(local) : null;
  const runEnv = binDir
    ? { ...process.env, PATH: binDir + path.delimiter + (process.env.PATH || "") }
    : process.env;
  if (local) {
    execFileSync(local, ["run", generateElm, ...args], { stdio: "inherit", env: runEnv });
  } else {
    // Fall back to npx, but --no-install forbids the silent download of an
    // arbitrary version: if elm-codegen isn't installed, fail loudly instead.
    execFileSync("npx", ["--no-install", "elm-codegen", "run", generateElm, ...args], {
      stdio: "inherit",
      env: runEnv,
    });
  }
} catch (e) {
  if (e.code === "ENOENT") {
    console.error(
      "elm-cem: could not run elm-codegen — install it (it is a dependency of elm-cem; run your package manager's install)."
    );
  }
  process.exit(e.status || 1);
}

// Locate the elm-codegen executable inside a reachable node_modules/.bin,
// starting from this package and walking up toward the invoking project. Returns
// the absolute path, or null if not found (caller falls back to `npx`).
function resolveElmCodegen() {
  const binName = process.platform === "win32" ? "elm-codegen.cmd" : "elm-codegen";
  const roots = [__dirname, path.resolve(__dirname, ".."), process.cwd()];
  const seen = new Set();
  for (const start of roots) {
    let dir = start;
    while (dir && !seen.has(dir)) {
      seen.add(dir);
      const candidate = path.join(dir, "node_modules", ".bin", binName);
      if (fs.existsSync(candidate)) return candidate;
      const parent = path.dirname(dir);
      if (parent === dir) break;
      dir = parent;
    }
  }
  return null;
}

// After the Elm codegen step, run any supplemental Node.js generators that
// produce modules the Elm codegen cannot: currently the icon-module generator
// (WS-C), which writes <Lib>.Icon from a config-declared ligature-name catalog.
// This runs before syncExposedModules so the emitted file is included in the
// exposed-modules computation (or filtered by _internalModules as configured).
if (outputDir) {
  const configFromPaths = [];
  for (let i = 0; i < process.argv.length; i++) {
    const a = process.argv[i];
    if (a.startsWith("--config-from=")) configFromPaths.push(a.slice("--config-from=".length));
    else if (a === "--config-from" && process.argv[i + 1]) { configFromPaths.push(process.argv[i + 1]); i++; }
  }
  require("./gen-icon-module").run(process.argv.slice(2), configFromPaths, outputDir);
  // Family-grouped standalone package (item 4): re-exports the freshly generated
  // flat M3e.Component.* surface under nested M3e.Family.* paths. Runs AFTER the
  // flat gen so it re-exports the current surface; purely additive (a separate
  // package tree), never touches the flat src just written.
  require("./gen-family-package").run(process.argv.slice(2), configFromPaths, outputDir);
}

// The generator knows exactly which modules it wrote, so it owns the package's
// `exposed-modules` — consumers don't hand-maintain it or ship a helper script.
// After generation, if there's a package `elm.json` next to the output dir,
// rewrite its `exposed-modules` from the emitted `.elm` files.
if (outputDir) {
  syncExposedModules(outputDir, publishShape);
}

// M1.c facts bundle: Face B (`cem-facts.json`) built here in JS from the
// reconciled-but-not-yet-alias-inlined CEM; Face C (`elm-api-facts.json`)
// relocated from the intermediate file Generate.Phantom.Emit.factsBundleFile
// wrote into --output (see Generate.elm's `_config._emitFactsBundle` gate),
// stamped with the provenance only the CLI wrapper knows.
if (factsBundleDir) {
  writeFactsBundle({ factsBundleDir, outputDir, rawArgvNoFactsFlag, afterReconcile });
}

// Reconcile each custom-element class declaration's `tagName` against the
// authoritative `custom-element-definition` export that registers it.
//
// WHY: a CEM analyzer can emit the WRONG `tagName` on a class declaration. In
// shipped @m3e/web 2.5.13 two declarations carry a colliding sibling's tag —
// `M3eStepperNextElement.tagName` is `"m3e-stepper-previous"` and
// `M3eFabMenuItemElement.tagName` is `"m3e-menu-item"` — even though their
// `@customElement(...)` decorators are correct. Generate.elm builds components
// from class declarations, reads `.tagName`, and MERGES components that share a
// tagName (mergeComponentsByTagName). So the corrupt tags make StepperNext get merged
// into StepperPrevious and FabMenuItem into MenuItem, and those two modules are
// never emitted.
//
// The `custom-element-definition` export is the registration truth — it mirrors
// `customElements.define(name, Class)` — so we make it the source of truth for a
// class's tag: for every such export, overwrite the referenced class
// declaration's `tagName` with the export's `name`. This is a no-op wherever the
// analyzer already agrees, so it is safe and uniform across every library
// elm-cem targets, not a per-component patch. Runs as the innermost pass so the
// corrected tags flow through every later pass and into the generator.
function reconcileTagNames(argv) {
  const flagIdx = argv.findIndex((a) => a === "--flags-from" || a.startsWith("--flags-from="));
  if (flagIdx === -1) return argv;
  const cemArg = argv[flagIdx].startsWith("--flags-from=")
    ? argv[flagIdx].slice("--flags-from=".length)
    : argv[flagIdx + 1];
  if (!cemArg) return argv;
  let cem;
  try {
    cem = JSON.parse(fs.readFileSync(path.resolve(process.cwd(), cemArg), "utf8"));
  } catch {
    return argv;
  }

  // Resolve the class declaration a definition registers: prefer the module the
  // definition names (handles a re-export from another module), else match by
  // name across all modules. Preferring declModule guards the pathological
  // same-name-in-two-modules case.
  const findDeclaration = (declName, declModule) => {
    if (declModule) {
      const mm = (cem.modules || []).find((m) => m.path === declModule);
      if (mm) {
        const d = (mm.declarations || []).find((x) => x.name === declName);
        if (d) return d;
      }
    }
    for (const m of cem.modules || []) {
      const d = (m.declarations || []).find((x) => x.name === declName);
      if (d) return d;
    }
    return null;
  };

  let changed = 0;
  for (const m of cem.modules || []) {
    for (const e of m.exports || []) {
      if (e.kind !== "custom-element-definition") continue;
      const tag = e.name;
      const declName = e.declaration && e.declaration.name;
      if (!tag || !declName) continue;
      const target = findDeclaration(declName, e.declaration.module);
      // Only rewrite an actual custom-element declaration whose tag differs, so
      // the pass stays a no-op for correct analyzers (clean logs, minimal churn).
      if (target && target.customElement && target.tagName !== tag) {
        console.log(
          `elm-cem: reconciled tagName ${JSON.stringify(target.tagName)} -> ${JSON.stringify(tag)} for ${declName}`
        );
        target.tagName = tag;
        changed++;
      }
    }
  }
  if (changed === 0) return argv;

  const tmp = writeTemp("elm-cem-tag", JSON.stringify(cem));
  const out = argv.slice();
  if (out[flagIdx].startsWith("--flags-from=")) out[flagIdx] = `--flags-from=${tmp}`;
  else out[flagIdx + 1] = tmp;
  return out;
}

// Inject the bundled HTML-natural attr→element constraint table into the CEM flags
// under `_config._nativeAttrTable`. The table lives in data/native-attrs.json —
// HTML-generic data, not Elm source — so the generator stays library-agnostic.
// Libraries may override or extend the table via their own `--config-from` entry.
// If the bundled file is absent (unusual package installation), the generator
// falls back to an empty table and emits no attr setters (a loud no-op rather
// than silently wrong output — the compile-gate will catch missing attr types).
function injectNativeAttrs(argv) {
  const nativeAttrsPath = path.resolve(__dirname, "..", "data", "native-attrs.json");
  if (!fs.existsSync(nativeAttrsPath)) return argv;

  let table;
  try {
    table = JSON.parse(fs.readFileSync(nativeAttrsPath, "utf8"));
  } catch {
    return argv;
  }
  if (!Array.isArray(table) || table.length === 0) return argv;

  const flagIdx = argv.findIndex((a) => a === "--flags-from" || a.startsWith("--flags-from="));
  if (flagIdx === -1) return argv;
  const cemArg = argv[flagIdx].startsWith("--flags-from=")
    ? argv[flagIdx].slice("--flags-from=".length)
    : argv[flagIdx + 1];
  let cem;
  try {
    cem = JSON.parse(fs.readFileSync(path.resolve(process.cwd(), cemArg), "utf8"));
  } catch {
    return argv;
  }

  // Inject under _config._nativeAttrTable; create _config if absent.
  // Only inject the bundled default when _nativeAttrTable is not already
  // supplied (e.g. by a --config-from file with a custom override).
  cem._config = cem._config || {};
  if (!cem._config._nativeAttrTable) {
    cem._config._nativeAttrTable = table;
  }

  const tmp = writeTemp("elm-cem-nat", JSON.stringify(cem));
  const out = argv.slice();
  if (out[flagIdx].startsWith("--flags-from=")) out[flagIdx] = `--flags-from=${tmp}`;
  else out[flagIdx + 1] = tmp;
  return out;
}

// Inject the hand-written runtime/core modules (the IR core) into the CEM flags
// under `_runtime`, so the generator emits them verbatim when ownsRuntime = true.
//
// injectRuntime RETIRED (elm-phantom pass 1): generated brands IMPORT the
// published IR (HtmlIr.*) — the runtime-injection/rename machinery is gone.

// Merge one or more `--config-from=<json>` files (the declarative slots/overrides)
// into the CEM flags under the reserved `_config` key, and strip the flag(s)
// (elm-codegen doesn't understand them). Multiple `--config-from` are deep-merged
// per component (two levels: component key, then each component's field object;
// later files add/override individual fields rather than replacing the whole
// component entry) — so hand-authored slots and generated examples can be supplied
// separately. No `--config-from` ⇒ args pass through unchanged, so the config-free
// path (other libraries) is preserved.
function injectConfig(argv) {
  const configPaths = [];
  const out = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith("--config-from=")) { configPaths.push(a.slice("--config-from=".length)); continue; }
    if (a === "--config-from") { configPaths.push(argv[i + 1]); i++; continue; }
    out.push(a);
  }
  if (configPaths.length === 0) return argv;

  const parsedList = [];
  for (const configPath of configPaths) {
    try {
      parsedList.push(JSON.parse(fs.readFileSync(path.resolve(process.cwd(), configPath), "utf8")));
    } catch {
      console.error(`elm-cem: could not read --config-from=${configPath}`);
    }
  }

  const flagIdx = out.findIndex((a) => a === "--flags-from" || a.startsWith("--flags-from="));
  if (flagIdx === -1) return out;
  const cemArg = out[flagIdx].startsWith("--flags-from=")
    ? out[flagIdx].slice("--flags-from=".length)
    : out[flagIdx + 1];
  let cem;
  try {
    cem = JSON.parse(fs.readFileSync(path.resolve(process.cwd(), cemArg), "utf8"));
  } catch {
    return out;
  }
  cem._config = deepMergeConfigs(parsedList);
  const tmp = writeTemp("elm-cem-cfg", JSON.stringify(cem));
  console.log("elm-cem: merged --config-from");
  if (out[flagIdx].startsWith("--flags-from=")) out[flagIdx] = `--flags-from=${tmp}`;
  else out[flagIdx + 1] = tmp;
  return out;
}

// Deep-merge config objects two levels deep: top-level component keys, then each
// component's field object. Later objects add/override individual fields on a
// component without replacing the whole entry.
//
// Only PLAIN-OBJECT values are field-merged. Array- and scalar-valued top-level
// keys (`_exclude` is a `List String`; `_htmlNamespace`/`_rawNamespace` are
// strings) are assigned last-wins. Spreading an array into an object turns
// `["A","B"]` into `{ "0": "A", "1": "B" }`, which the Elm decoder then fails to
// read as `List String` and silently drops to `[]` — the bug that left `_exclude`
// inert and the leaked base-class components emitting.
function isPlainObject(v) {
  return v !== null && typeof v === "object" && !Array.isArray(v);
}
function deepMergeConfigs(objs) {
  const out = {};
  for (const o of objs) {
    for (const [comp, fields] of Object.entries(o || {})) {
      if (isPlainObject(fields) && isPlainObject(out[comp])) {
        out[comp] = { ...out[comp], ...fields };
      } else {
        out[comp] = fields;
      }
    }
  }
  return out;
}

function removeElmFiles(dir) {
  if (!fs.existsSync(dir)) return;
  for (const f of elmFiles(dir)) {
    fs.rmSync(f);
  }
}

function parseOutput(argv) {
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith("--output=")) return a.slice("--output=".length);
    if (a === "--output" && argv[i + 1]) return argv[i + 1];
  }
  return null;
}

// --- M1.c facts bundle -------------------------------------------------

function getFlagValue(argv, name) {
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith(`${name}=`)) return a.slice(name.length + 1);
    if (a === name && argv[i + 1] !== undefined) return argv[i + 1];
  }
  return null;
}

// Strip `--facts-bundle=<dir>` (elm-codegen doesn't understand it, same
// treatment as `--config-from`), returning both the cleaned argv and the dir.
function extractFactsBundleDir(argv) {
  const dir = getFlagValue(argv, "--facts-bundle");
  const out = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith("--facts-bundle=")) continue;
    if (a === "--facts-bundle") {
      i++; // also skip its value
      continue;
    }
    out.push(a);
  }
  return { argv: out, factsBundleDir: dir };
}

// Merge `_config._emitFactsBundle = true` into the CEM flags so
// Generate.elm's decodeEmitFactsBundleFlag gate fires — the trigger for
// Generate.Phantom.Emit.factsBundleFile (Face C). A no-op (argv unchanged)
// when `enabled` is false, so a caller that never asks for the bundle also
// never pays for an extra temp-file rewrite.
function injectFactsBundleFlag(argv, enabled) {
  if (!enabled) return argv;
  const flagIdx = argv.findIndex((a) => a === "--flags-from" || a.startsWith("--flags-from="));
  if (flagIdx === -1) return argv;
  const cemArg = argv[flagIdx].startsWith("--flags-from=")
    ? argv[flagIdx].slice("--flags-from=".length)
    : argv[flagIdx + 1];
  let cem;
  try {
    cem = JSON.parse(fs.readFileSync(path.resolve(process.cwd(), cemArg), "utf8"));
  } catch {
    return argv;
  }
  cem._config = cem._config || {};
  cem._config._emitFactsBundle = true;
  const tmp = writeTemp("elm-cem-facts-flag", JSON.stringify(cem));
  const out = argv.slice();
  if (out[flagIdx].startsWith("--flags-from=")) out[flagIdx] = `--flags-from=${tmp}`;
  else out[flagIdx + 1] = tmp;
  return out;
}

// Best-effort git HEAD commit of `dir` (or null). Resolves one level of
// symbolic ref (`ref: refs/heads/main`); never throws.
function tryGitHead(dir) {
  try {
    const headPath = path.join(dir, ".git", "HEAD");
    const head = fs.readFileSync(headPath, "utf8").trim();
    const m = head.match(/^ref:\s*(.+)$/);
    if (!m) return head || null;
    const refPath = path.join(dir, ".git", m[1]);
    return fs.readFileSync(refPath, "utf8").trim() || null;
  } catch {
    return null;
  }
}

// Walk upward from `dir` looking for the nearest `package.json` — used to
// find the upstream component library's own package.json (name/version/
// repository) from the directory its manifest/`.d.ts` tree was scanned in.
function findPackageJsonUp(dir, maxLevels = 6) {
  let cur = path.resolve(dir);
  for (let i = 0; i < maxLevels; i++) {
    const candidate = path.join(cur, "package.json");
    if (fs.existsSync(candidate)) {
      try {
        return JSON.parse(fs.readFileSync(candidate, "utf8"));
      } catch {
        return null;
      }
    }
    const parent = path.dirname(cur);
    if (parent === cur) break;
    cur = parent;
  }
  return null;
}

function writeFactsBundle({ factsBundleDir, outputDir, rawArgvNoFactsFlag, afterReconcile }) {
  const absFactsBundleDir = path.resolve(process.cwd(), factsBundleDir);
  fs.mkdirSync(absFactsBundleDir, { recursive: true });

  const origFlagsFrom = getFlagValue(rawArgvNoFactsFlag, "--flags-from");
  const origManifestPath = path.resolve(process.cwd(), origFlagsFrom);
  const origCem = JSON.parse(fs.readFileSync(origManifestPath, "utf8"));

  const reconciledFlagsFrom = getFlagValue(afterReconcile, "--flags-from") || origFlagsFrom;
  const reconciledCem = JSON.parse(fs.readFileSync(path.resolve(process.cwd(), reconciledFlagsFrom), "utf8"));

  const dtsDir = path.dirname(origManifestPath);
  const pkg = findPackageJsonUp(dtsDir);
  const generatorVersion = require("../package.json").version;
  const generatorCommit = tryGitHead(path.resolve(__dirname, ".."));

  const faceBProvenance = {
    generator: { name: "elm-cem", version: generatorVersion, commit: generatorCommit },
    source: {
      package: pkg && pkg.name ? pkg.name : "unknown",
      version: pkg && pkg.version ? pkg.version : "unknown",
      sha: null,
      manifestPath: path.relative(process.cwd(), origManifestPath),
      upstreamRepo: pkg && pkg.repository ? pkg.repository.url || pkg.repository : null,
      integrity: null,
    },
    dts: { dir: path.relative(process.cwd(), dtsDir), fileCount: factsBundle.dtsFiles(dtsDir).length, aliasCount: 0 },
  };

  const faceB = factsBundle.buildFaceB(reconciledCem, origCem, { dtsDir, provenance: faceBProvenance });
  faceBProvenance.dts.aliasCount = faceB.stats.aliasesCollected; // patch in place (shared reference)

  fs.writeFileSync(path.join(absFactsBundleDir, "cem-facts.json"), JSON.stringify(faceB, null, 2) + "\n");
  console.log(
    `elm-cem: wrote facts bundle Face B (${faceB.components.length} components, ${faceB.stats.attributes} attributes) to ${path.join(absFactsBundleDir, "cem-facts.json")}`
  );

  const intermediatePath = path.resolve(process.cwd(), outputDir, "elm-api-facts.generated.json");
  if (!fs.existsSync(intermediatePath)) {
    console.error(
      `elm-cem: --facts-bundle requested but ${intermediatePath} was not emitted — Face C was not written.`
    );
    return;
  }
  const faceC = JSON.parse(fs.readFileSync(intermediatePath, "utf8"));
  fs.rmSync(intermediatePath);

  const configFiles = [];
  for (let i = 0; i < rawArgvNoFactsFlag.length; i++) {
    const a = rawArgvNoFactsFlag[i];
    if (a.startsWith("--config-from=")) configFiles.push(a.slice("--config-from=".length));
    else if (a === "--config-from" && rawArgvNoFactsFlag[i + 1]) configFiles.push(rawArgvNoFactsFlag[++i]);
  }

  faceC.provenance = {
    producer: { elmCem: { version: generatorVersion, commit: generatorCommit } },
    brand: {
      name: path.basename(process.cwd()),
      lib: faceC.lib || null,
      commit: tryGitHead(process.cwd()),
      configFiles,
    },
    source: { package: faceBProvenance.source.package, version: faceBProvenance.source.version, sha: null },
  };

  fs.writeFileSync(path.join(absFactsBundleDir, "elm-api-facts.json"), JSON.stringify(faceC, null, 2) + "\n");
  console.log(
    `elm-cem: wrote facts bundle Face C (${Object.keys(faceC.components).length} components) to ${path.join(absFactsBundleDir, "elm-api-facts.json")}`
  );
}

// Read the publish shape from --config-from JSON files (raw, so it is independent
// of what reaches elm-codegen). `_publishGeneralOnly: true` restricts the
// published `exposed-modules` to the brand's general/-html primitives layer; the
// full component surface stays generated (for eject) but unexposed. `_brand` names
// the barrel/library prefix. See docs/distribution-model.md.
function readPublishShape(argv) {
  const paths = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith("--config-from=")) paths.push(a.slice("--config-from=".length));
    else if (a === "--config-from" && argv[i + 1]) { paths.push(argv[i + 1]); i++; }
  }
  let brand = null;
  let generalOnly = false;
  const internalModules = new Set();
  for (const p of paths) {
    if (!/\.json$/.test(p)) continue; // only JSON configs carry these keys
    try {
      const c = JSON.parse(fs.readFileSync(path.resolve(process.cwd(), p), "utf8"));
      if (c && typeof c === "object") {
        if (c._brand) brand = c._brand;
        if (c._publishGeneralOnly) generalOnly = true;
        // `_internalModules` — modules that ARE generated (component modules import
        // them) but are NOT exposed in the published package's `exposed-modules`.
        // Declared in config so the exclusion is explicit and diff-visible, not
        // hardcoded. Example: `"_internalModules": ["M3e.Html"]` internalizes the
        // loose elm/html-like producer layer (WS-B: spec §3.1).
        if (Array.isArray(c._internalModules)) {
          for (const m of c._internalModules) internalModules.add(m);
        }
      }
    } catch {
      /* unreadable/invalid config-from is not this function's error */
    }
  }
  return { brand, generalOnly, internalModules };
}

function syncExposedModules(output, publishShape) {
  const srcDir = path.resolve(process.cwd(), output);
  const elmJsonPath = path.resolve(srcDir, "..", "elm.json");
  if (!fs.existsSync(elmJsonPath)) return;

  let raw;
  let elmJson;
  try {
    raw = fs.readFileSync(elmJsonPath, "utf8");
    elmJson = JSON.parse(raw);
  } catch {
    return;
  }
  if (elmJson.type !== "package") return;

  let modules = elmFiles(srcDir)
    .map((f) => path.relative(srcDir, f).replace(/\.elm$/, "").split(path.sep).join("."))
    // Never publish `*.Internal` modules. They carry the phantom-row forging
    // primitives (Element.Internal.fromNode, Content.Internal.slot,
    // Token.Core.Internal.token, Html.Attr.Internal.forget, …) whose safety is
    // enforced only INSIDE this package by NoInternalImportOutsideAllowed. A
    // downstream repo is a different package: if these were exposed, external
    // code could import them and forge any capability/slot/tag row, defeating the
    // whole type-safety boundary (issue #37 H2). Excluded from `exposed-modules`
    // so they are unreachable across the package boundary.
    .filter((m) => !/(^|\.)Internal(\.|$)/.test(m))
    // Expose the generated `<Lib>.Review.Facts` module but NOT any other
    // `<Lib>.Review.*` scaffolding. `Review.Facts` is the elm-review-cem
    // contract: it emits `facts : List Fact` and imports the `Fact`/`Facet`
    // types from the zero-dep `jackhp95/elm-cem-facts` package (module
    // `Cem.Facts`). A consuming review config imports `<Lib>.Review.Facts` to
    // pass the library's facts into the rules; that only type-unifies across
    // the package boundary if the module is EXPOSED (issue #42, root cause of
    // NB3/B8 — an unexposed or empty-exposed facts module is unreachable and
    // unpublishable). Exposing it means the published package must declare a
    // dependency on `jackhp95/elm-cem-facts`, so that `elm make --docs` can
    // resolve `Cem.Facts`; that dep-stamping is the Stage-F cutover (issue #48).
    // Until then, regenerated brands compile `Review.Facts` via an application
    // whose source-directories reach the canonical `elm-cem/facts/src`. Any
    // OTHER `<Lib>.Review.*` module stays unexposed, mirroring `Internal`.
    .filter((m) => /(^|\.)Review\.Facts$/.test(m) || !/(^|\.)Review(\.|$)/.test(m))
    .sort();
  if (modules.length === 0) return;

  // Primitives publish shape (docs/distribution-model.md): a brand publishes only
  // its general/-html layer; the full component surface is generated (for eject)
  // but NOT exposed, so the registry docs.json stays under the 700 KB cap. The
  // deps stamped below still come from the FULL src, since every module (exposed
  // or not) must compile when the package is published.
  if (publishShape && publishShape.generalOnly && publishShape.brand) {
    const prim = require("./classify").primitivesExposed(srcDir, publishShape.brand);
    if (prim && prim.length) modules = prim;
  }

  // Config-declared internal modules: generated (so component modules may import
  // them), but not exposed in the published package API. Declared in config via
  // `_internalModules: ["<ModuleName>", ...]` rather than hardcoded here, so the
  // choice is explicit and diff-visible. Applied AFTER generalOnly so that a
  // module excluded here is excluded even from the general-only surface.
  if (publishShape && publishShape.internalModules && publishShape.internalModules.size > 0) {
    const internalized = modules.filter((m) => publishShape.internalModules.has(m));
    modules = modules.filter((m) => !publishShape.internalModules.has(m));
    if (internalized.length > 0) {
      console.log(
        `elm-cem: internalized ${internalized.length} module(s) (generated but not exposed): ${internalized.join(", ")}`
      );
    }
  }

  // Stamp the family dependencies the emitted src actually imports (issue #48,
  // finding NB1): a brand whose src imports `HtmlIr.*` MUST declare
  // `jackhp95/elm-html-intermediate-representation`, and one that exposes
  // `<Brand>.Review.Facts` (which `import Cem.Facts`) MUST declare
  // `jackhp95/elm-cem-facts`. Five of seven published packages omitted the IR dep
  // and failed to compile in the registry; this closes that at the generator.
  // The decision is import-driven (family-deps.js), so it stays correct as the
  // emitted module set changes. Existing dep entries (and their ranges) are left
  // untouched — only missing family deps are added, with single-sourced ranges.
  // Pre-Stage-F these deps are unpublished, so the brand's own standalone
  // `elm make` still can't resolve them; that is expected (STAGE-F-FACTS-CUTOVER).
  const deps = elmJson.dependencies && typeof elmJson.dependencies === "object" ? elmJson.dependencies : {};
  const required = familyDeps.requiredFamilyDeps(srcDir);
  const addedDeps = [];
  for (const [pkg, range] of Object.entries(required)) {
    if (!(pkg in deps)) {
      deps[pkg] = range;
      addedDeps.push(pkg);
    }
  }

  // No-op when the exposed set AND the dependency set already match — don't churn
  // the file (or its VCS diff) on every generate when nothing changed.
  const current = Array.isArray(elmJson["exposed-modules"]) ? elmJson["exposed-modules"] : [];
  const exposedUnchanged =
    current.length === modules.length && current.every((m, i) => m === modules[i]);
  if (exposedUnchanged && addedDeps.length === 0) {
    return;
  }

  elmJson["exposed-modules"] = modules;
  elmJson.dependencies = deps;
  // Preserve the file's existing indentation instead of forcing 4 spaces.
  fs.writeFileSync(elmJsonPath, JSON.stringify(elmJson, null, detectIndent(raw)) + "\n");
  const parts = [];
  if (!exposedUnchanged) parts.push(`set ${modules.length} exposed module(s)`);
  if (addedDeps.length) parts.push(`stamped dep(s) ${addedDeps.join(", ")}`);
  console.log(`elm-cem: ${parts.join("; ")} in ${elmJsonPath}`);
}

// Infer the indentation used by an existing JSON file (spaces or a tab),
// defaulting to 4 spaces. Only the first indented line is inspected.
function detectIndent(raw) {
  const m = raw.match(/\n([ \t]+)\S/);
  if (!m) return 4;
  return m[1][0] === "\t" ? "\t" : m[1].length;
}

function elmFiles(dir) {
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...elmFiles(full));
    else if (entry.name.endsWith(".elm")) out.push(full);
  }
  return out;
}

// A Custom Elements Manifest often types an enum attribute as a bare TypeScript
// alias name (`{ "type": { "text": "ButtonVariant" } }`) rather than an inlined
// literal union. The codegen only recognises a union when the text contains
// `|`, so such attributes silently degrade to `String`. Here we scan the
// package's shipped `.d.ts` declarations for pure string-literal aliases and
// inline them into a temp copy of the CEM, leaving every other arg untouched.
function recordTypeAliases(argv) {
  const flagIdx = argv.findIndex(
    (a) => a === "--flags-from" || a.startsWith("--flags-from=")
  );
  if (flagIdx === -1) return argv;
  const cemArg = argv[flagIdx].startsWith("--flags-from=")
    ? argv[flagIdx].slice("--flags-from=".length)
    : argv[flagIdx + 1];
  if (!cemArg) return argv;

  const cemPath = path.resolve(process.cwd(), cemArg);
  let cem;
  try {
    cem = JSON.parse(fs.readFileSync(cemPath, "utf8"));
  } catch {
    return argv;
  }

  // The `.d.ts` sources live beside the *original* CEM in the installed package.
  // An earlier pass (reconcileTagNames) may have repointed `--flags-from` at a
  // temp copy of the CEM in os.tmpdir; scanning that dir for `.d.ts` would find
  // none (silently dropping every enum-alias inline) and can even hit unreadable
  // system temp folders. Derive the search root from the process's ORIGINAL
  // `--flags-from` so alias discovery is stable regardless of upstream rewrites.
  const origIdx = process.argv.findIndex(
    (a) => a === "--flags-from" || a.startsWith("--flags-from=")
  );
  const origArg =
    origIdx === -1
      ? cemArg
      : process.argv[origIdx].startsWith("--flags-from=")
        ? process.argv[origIdx].slice("--flags-from=".length)
        : process.argv[origIdx + 1];
  const dtsDir = path.dirname(path.resolve(process.cwd(), origArg || cemArg));

  const aliases = collectLiteralAliases(dtsDir);
  if (Object.keys(aliases).length === 0) return argv;

  let changed = 0;
  const visit = (node) => {
    if (Array.isArray(node)) {
      node.forEach(visit);
      return;
    }
    if (node && typeof node === "object") {
      if (node.type && typeof node.type.text === "string") {
        // Alias-RECORDING (phantom pipeline): before resolving, remember which
        // alias name the type came from. The resolved union is what the Elm
        // enum classifier needs; the NAME is docs provenance the emitters keep
        // (`type alias Variant = …  -- from ButtonVariant`). Never overwrite a
        // manually-authored aliasName (test fixtures set it directly).
        const aliasPart = node.type.text
          .split("|")
          .map((s) => s.trim())
          .find((p) => aliases[p]);
        const resolved = resolveAlias(node.type.text, aliases);
        if (resolved && resolved !== node.type.text) {
          node.type.text = resolved;
          if (aliasPart && node.type.aliasName === undefined) {
            node.type.aliasName = aliasPart;
          }
          changed++;
        }
      }
      for (const key of Object.keys(node)) visit(node[key]);
    }
  };
  visit(cem);
  if (changed === 0) return argv;

  const tmp = writeTemp("elm-cem-cem", JSON.stringify(cem));
  console.log(`elm-cem: recorded+resolved ${changed} TS type-alias reference(s) from .d.ts`);

  const next = argv.slice();
  if (next[flagIdx].startsWith("--flags-from=")) next[flagIdx] = `--flags-from=${tmp}`;
  else next[flagIdx + 1] = tmp;
  return next;
}

// Strip `//` line comments and `/* … */` block comments from TypeScript source,
// so a multiline / commented string-literal union still matches (issue #26).
function stripTsComments(src) {
  return src
    .replace(/\/\*[\s\S]*?\*\//g, "")
    .replace(/\/\/[^\n]*/g, "");
}

// Map of `AliasName -> <literal union>` for every enum-like literal type declared
// in any `.d.ts` under `rootDir`. Two declaration shapes are recognised:
//
//   1. A pure literal-union type alias — string unions (`"a" | "b"`) and numeric
//      unions (`1 | 2 | 3`, `100 | 200 | 700`). Numeric aliases like
//      `HeadingLevel`/`IconWeight`/`ElevationLevel` are inlined so the Elm
//      classifier types them as `Int` instead of degrading to `String`.
//
//   2. A FAST/Fluent-style const-object enum — the values are declared on a
//      `const` object and the exported type only refers back to it via
//      `ValuesOf<typeof X>` (which is NOT a literal union, so shape 1 misses it):
//
//        export declare const ButtonType: {
//            readonly submit: "submit";
//            readonly reset: "reset";
//        };
//        export type ButtonType = ValuesOf<typeof ButtonType>;
//
//      We harvest the string/numeric literal VALUES from such all-literal const
//      objects → `ButtonType = "submit" | "reset"`. Without this the CEM's
//      `{ "type": { "text": "ButtonType" } }` never resolves and every Fluent
//      enum attribute silently degrades to `String` (no `<Lib>.Values` emitted).
//
// A shape-1 literal-union alias always WINS over a shape-2 const of the same name
// (the explicit union is authoritative). Both handle multiline bodies, an
// optional leading `|`, and ignore comments (issue #26).
function collectLiteralAliases(rootDir) {
  const map = {};
  const constMap = {};
  const typeRe = /\b(?:export\s+)?(?:declare\s+)?type\s+([A-Za-z_$][\w$]*)\s*=\s*([^;]+);/g;
  // A member is a quoted string literal OR a numeric literal.
  const member = `(?:"[^"]*"|'[^']*'|-?\\d+(?:\\.\\d+)?)`;
  // Optional leading `|`, then one-or-more literal members separated by `|`.
  const onlyLiteralUnion = new RegExp(`^\\|?\\s*${member}(?:\\s*\\|\\s*${member})*$`);
  // A const-object enum: `const Name: { … }`. The `[^{}]*` body deliberately does
  // NOT span nested braces — a const with a nested object value leaves a non-empty
  // remainder after member stripping and is skipped (correctly, not a flat enum).
  const constRe = /\b(?:export\s+)?(?:declare\s+)?const\s+([A-Za-z_$][\w$]*)\s*:\s*\{([^{}]*)\}/g;
  // A `readonly? key: <literal>;` member of a const-object enum.
  const constMemberRe = new RegExp(`(?:readonly\\s+)?[A-Za-z_$][\\w$]*\\s*:\\s*(${member})\\s*;?`, "g");
  for (const file of dtsFiles(rootDir)) {
    let src;
    try {
      src = fs.readFileSync(file, "utf8");
    } catch {
      continue;
    }
    src = stripTsComments(src);
    let m;
    while ((m = typeRe.exec(src))) {
      const name = m[1];
      const body = m[2].replace(/\s+/g, " ").trim();
      if (onlyLiteralUnion.test(body)) {
        // Normalise to double quotes and drop any leading `|`.
        map[name] = body.replace(/^\|\s*/, "").replace(/'/g, '"');
      }
    }
    while ((m = constRe.exec(src))) {
      const name = m[1];
      const body = m[2];
      const values = [];
      let mm;
      constMemberRe.lastIndex = 0;
      while ((mm = constMemberRe.exec(body))) values.push(mm[1].replace(/'/g, '"'));
      // Accept only when EVERY member is a literal (nothing but members remains).
      const remainder = body.replace(constMemberRe, "").replace(/[\s;,]/g, "");
      if (values.length > 0 && remainder === "") {
        constMap[name] = [...new Set(values)].join(" | ");
      }
    }
  }
  // Shape-1 unions win; fill in const-object enums only where no union exists.
  for (const name of Object.keys(constMap)) {
    if (!(name in map)) map[name] = constMap[name];
  }
  return map;
}

// Expand a CEM `type.text` if (any of) its `|`-separated parts name a known
// string-literal alias. Returns null when nothing resolves. Keeps non-alias
// parts (e.g. `undefined`) so a nullable alias still yields a literal union.
function resolveAlias(text, aliases) {
  const parts = text.split("|").map((s) => s.trim());
  if (!parts.some((p) => aliases[p])) return null;
  return parts.map((p) => aliases[p] || p).join(" | ");
}

function dtsFiles(dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...dtsFiles(full));
    else if (entry.name.endsWith(".d.ts")) out.push(full);
  }
  return out;
}
