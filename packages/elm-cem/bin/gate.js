// elm-cem gate — the one release gate a brand runs (issue #50).
//
// Runs, in order, the three checks that must all hold before a brand is
// publishable, each already centralized in elm-cem:
//
//   1. regen-drift    — committed src/ + elm.json match a fresh regen (NB5).
//   2. registry-check — the package compiles registry-faithfully from its
//                       declared deps only (NB1/B2).
//   3. acid           — phantom-type probes discriminate (positive compile,
//                       negative fail).
//
// A brand's package.json simply calls `elm-cem gate` with whatever drift needs
// (its CEM / config files); everything else is defaulted. Flags are routed to
// the relevant sub-gate:
//   drift    ← --flags-from, --config-from (repeatable), --src, --elm-json
//   registry ← --elm-json, --dep-src (repeatable), --elm, --no-audit
//   acid     ← --acid-dir (→ --dir), --elm
// Any sub-gate can be skipped with --skip-drift / --skip-registry / --skip-acid
// (a brand that ships no acid probes can pass --skip-acid, though acid also
// passes cleanly with an empty probe set).
//
// Usage (from a brand repo root):
//   elm-cem gate [drift/registry/acid flags] [--skip-drift|--skip-registry|--skip-acid]

"use strict";

function fail(msg) {
  console.error(`gate: ${msg}`);
  process.exit(1);
}

function usage() {
  console.log(
    [
      "elm-cem gate — run regen-drift + registry-check + acid (the full brand release gate).",
      "",
      "Run from a brand repo root. Flags route to the relevant sub-gate:",
      "  drift:    --flags-from, --config-from (repeatable), --src, --elm-json",
      "  registry: --elm-json, --dep-src (repeatable), --elm, --no-audit",
      "  acid:     --acid-dir (→ --dir), --elm",
      "Skip any stage: --skip-drift | --skip-registry | --skip-acid",
    ].join("\n")
  );
}

function run(argv) {
  if (argv.includes("-h") || argv.includes("--help")) {
    usage();
    process.exit(0);
  }

  const skip = { drift: false, registry: false, acid: false };
  const driftArgs = [];
  const registryArgs = [];
  const acidArgs = [];

  for (const a of argv) {
    if (a === "--skip-drift") skip.drift = true;
    else if (a === "--skip-registry") skip.registry = true;
    else if (a === "--skip-acid") skip.acid = true;
    else if (a.startsWith("--flags-from=")) driftArgs.push(a);
    else if (a.startsWith("--config-from=")) driftArgs.push(a);
    else if (a.startsWith("--src=")) driftArgs.push(a);
    else if (a.startsWith("--elm-json=")) {
      driftArgs.push(a);
      registryArgs.push(a);
    } else if (a.startsWith("--dep-src=")) registryArgs.push(a);
    else if (a === "--no-audit") registryArgs.push(a);
    else if (a.startsWith("--elm=")) {
      registryArgs.push(a);
      acidArgs.push(a);
    } else if (a.startsWith("--acid-dir=")) acidArgs.push(`--dir=${a.slice("--acid-dir=".length)}`);
    else fail(`unknown argument: ${a}`);
  }

  const stages = [];
  if (!skip.drift) stages.push(["regen-drift", "./regen-drift", driftArgs]);
  if (!skip.registry) stages.push(["registry-check", "./registry-check", registryArgs]);
  if (!skip.acid) stages.push(["acid", "./acid", acidArgs]);

  for (const [label, mod, args] of stages) {
    console.log(`\n── gate: ${label} ──────────────────────────────────────────────`);
    // Each sub-gate's run() exits(1) on failure, which fails the whole gate.
    require(mod).run(args);
  }

  console.log("\ngate: OK — drift, registry-check, and acid all passed.");
}

module.exports = { run };

// Direct invocation must do the same work as `elm-cem <subcommand>`. Without this
// guard the file loads, exports `run`, calls nothing, prints nothing and exits 0 —
// a gate reporting success without doing its work, which is precisely the failure
// these scripts exist to prevent. It nearly banked a false "verified" once: an
// agent checking elm-review-cem's neutrality gate ran this file directly, got a
// clean exit 0, and only doubted it because an expected log line never printed.
if (require.main === module) run(process.argv.slice(2));
