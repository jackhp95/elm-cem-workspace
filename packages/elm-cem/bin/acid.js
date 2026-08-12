// elm-cem acid — the shared phantom-type ACID gate (issue #50).
//
// Promotes the per-brand acid-probe.mjs / acid.mjs forks (four divergent copies)
// into one harness. A brand keeps only its probe FILES as config; the compile
// machinery lives here.
//
// Convention (all brands converge to it):
//   tests/acid/**/*.elm are probes.
//     - POSITIVE probe  → MUST compile   (e.g. Positive.elm, Good.elm, app/Good.elm)
//     - NEGATIVE probe  → MUST fail       (basename starts with "Negative", or the
//                          file sits under a `bad/` directory)
//   Each probe is a self-contained module (distinct module name). The harness
//   stages the brand's generated src/ + the unpublished IR source onto the
//   compile path (a bare `elm make` cannot resolve HtmlIr.*), then compiles each
//   probe in isolation and checks its exit status against its polarity.
//
// A brand with no probe directory (e.g. a docs-app brand) passes with a notice — there is
// nothing to disprove, so the uniform `elm-cem gate` still runs everywhere.
//
// Usage (from a brand repo root):
//   elm-cem acid [--dir=tests/acid] [--elm=<path>]
//
// Exit 0 = every positive compiled and every negative failed. Exit 1 otherwise.

"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawnSync } = require("child_process");
const shared = require("./shared");

function fail(msg) {
  console.error(`acid: FAIL — ${msg}`);
  process.exit(1);
}

function usage() {
  console.log(
    [
      "elm-cem acid — phantom-type ACID gate (positive probes compile, negative probes fail).",
      "",
      "Run from a brand repo root. Probes live under tests/acid/ (override --dir):",
      "  a probe is NEGATIVE if its basename starts with 'Negative' or it sits under a",
      "  'bad/' dir; otherwise POSITIVE. The brand src/ + IR source are staged onto the",
      "  compile path automatically.",
      "",
      "Options:",
      "  --dir=<dir>   probe directory (default: tests/acid)",
      "  --elm=<path>  elm 0.19.1 binary (auto-resolved from node_modules)",
      "  -h, --help    show this help",
    ].join("\n")
  );
}

function parseArgs(argv) {
  const o = {};
  for (const a of argv) {
    if (a === "-h" || a === "--help") o.help = true;
    else if (a.startsWith("--dir=")) o.dir = a.slice("--dir=".length);
    else if (a.startsWith("--elm=")) o.elm = a.slice("--elm=".length);
    else fail(`unknown argument: ${a}`);
  }
  return o;
}

// All .elm probe files under dir, skipping elm-stuff build artifacts.
function collectProbes(dir) {
  const out = [];
  const walk = (d) => {
    for (const entry of fs.readdirSync(d, { withFileTypes: true })) {
      if (entry.name === "elm-stuff") continue;
      const full = path.join(d, entry.name);
      if (entry.isDirectory()) walk(full);
      else if (entry.name.endsWith(".elm")) out.push(full);
    }
  };
  walk(dir);
  return out;
}

function isNegative(probePath, probeRoot) {
  const rel = path.relative(probeRoot, probePath).split(path.sep);
  const base = rel[rel.length - 1];
  if (/^Negative/.test(base)) return true;
  return rel.slice(0, -1).some((seg) => seg.toLowerCase() === "bad");
}

function run(argv) {
  const o = parseArgs(argv);
  if (o.help) {
    usage();
    process.exit(0);
  }

  const cwd = process.cwd();
  const probeRoot = path.resolve(cwd, o.dir || "tests/acid");
  if (!fs.existsSync(probeRoot)) {
    console.log(`acid: no probe directory at ${path.relative(cwd, probeRoot) || probeRoot} — nothing to prove (OK).`);
    return;
  }
  const probes = collectProbes(probeRoot);
  if (probes.length === 0) {
    console.log(`acid: no .elm probes under ${path.relative(cwd, probeRoot)} — nothing to prove (OK).`);
    return;
  }

  const elm = o.elm ? path.resolve(cwd, o.elm) : shared.resolveBin("elm");
  if (!elm || !fs.existsSync(elm)) {
    fail("elm binary not found — pass --elm=<path> or run `elm-tooling install`.");
  }

  const srcDir = path.resolve(cwd, "src");
  if (!fs.existsSync(srcDir)) fail(`no src/ at ${srcDir}`);
  const irSrc = shared.resolveIrSrc();
  if (!irSrc) {
    fail("IR source not found — set IR_SRC or place elm-html-intermediate-representation as a sibling.");
  }

  // Scratch application: lib/ holds the brand src + IR (structure preserved so
  // HtmlIr.* resolves); probes/ holds every probe flattened to <Module>.elm.
  const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-acid-"));
  const lib = path.join(scratch, "lib");
  const probeDir = path.join(scratch, "probes");
  fs.mkdirSync(lib, { recursive: true });
  fs.mkdirSync(probeDir, { recursive: true });
  shared.copyDir(srcDir, lib, (rel, isDir) => isDir || rel.endsWith(".elm"));
  shared.copyDir(irSrc, lib, (rel, isDir) => isDir || rel.endsWith(".elm"));

  const staged = [];
  for (const p of probes) {
    const base = path.basename(p);
    const dest = path.join(probeDir, base);
    if (fs.existsSync(dest)) {
      fail(`two probes share the module file name ${base} — probe module names must be unique.`);
    }
    fs.copyFileSync(p, dest);
    staged.push({ file: base, negative: isNegative(p, probeRoot), rel: path.relative(cwd, p) });
  }

  const appElmJson = {
    type: "application",
    "source-directories": ["lib", "probes"],
    "elm-version": "0.19.1",
    dependencies: {
      direct: {
        "elm/core": "1.0.5",
        "elm/html": "1.0.0",
        "elm/json": "1.1.4",
        "elm/virtual-dom": "1.0.3",
      },
      indirect: {
        "elm/parser": "1.1.0",
        "elm/random": "1.0.0",
        "elm/time": "1.0.0",
      },
    },
    "test-dependencies": { direct: {}, indirect: {} },
  };
  fs.writeFileSync(path.join(scratch, "elm.json"), JSON.stringify(appElmJson, null, 2) + "\n");

  let failures = 0;
  const pos = staged.filter((s) => !s.negative);
  const neg = staged.filter((s) => s.negative);
  console.log(`acid: ${pos.length} positive probe(s) must compile, ${neg.length} negative probe(s) must fail.`);

  for (const s of staged) {
    const r = spawnSync(elm, ["make", path.join("probes", s.file), "--output=/dev/null"], {
      cwd: scratch,
      encoding: "utf8",
      stdio: "pipe",
    });
    const compiled = r.status === 0;
    if (s.negative) {
      if (!compiled) console.log(`  PASS  ${s.rel} (correctly rejected)`);
      else {
        console.error(`  FAIL  ${s.rel} — NEGATIVE probe compiled but must be rejected`);
        failures++;
      }
    } else {
      if (compiled) console.log(`  PASS  ${s.rel} (compiled)`);
      else {
        console.error(`  FAIL  ${s.rel} — POSITIVE probe must compile:`);
        console.error((r.stdout || "").slice(0, 1500) + (r.stderr || "").slice(0, 1500));
        failures++;
      }
    }
  }

  fs.rmSync(scratch, { recursive: true, force: true });

  if (failures) fail(`${failures} probe(s) behaved incorrectly.`);
  console.log("acid: OK — all probes behaved as specified.");
}

module.exports = { run };

// Direct invocation must do the same work as `elm-cem <subcommand>`. Without this
// guard the file loads, exports `run`, calls nothing, prints nothing and exits 0 —
// a gate reporting success without doing its work, which is precisely the failure
// these scripts exist to prevent. It nearly banked a false "verified" once: an
// agent checking elm-review-cem's neutrality gate ran this file directly, got a
// clean exit 0, and only doubted it because an expected log line never printed.
if (require.main === module) run(process.argv.slice(2));
