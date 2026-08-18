#!/usr/bin/env node
// No bin/ entry point may be a SILENT NO-OP when invoked directly.
//
// Every subcommand in bin/ is written as `function run(argv)` + `module.exports =
// { run }`, and `bin/elm-cem.js` dispatches to it. That refactor dropped the
// execution path: running the file directly loaded it, exported `run`, called
// nothing, printed nothing, and exited 0.
//
//     $ node bin/check-gates.js ; echo $?
//     0
//
// A gate that reports success without doing its work is the exact failure this
// family of scripts exists to prevent — and it was not hypothetical: an agent
// working elm-review-cem's neutrality gate nearly recorded a false "verified"
// against it, and only noticed because a log line it expected never appeared.
// Anything that shells out to `node bin/<sub>.js` — a README snippet, a CI step, a
// human debugging one stage in isolation — gets a confident green for free.
//
// The property asserted is deliberately weak and therefore general: invoked with
// no arguments in an empty directory, an entry point must SAY SOMETHING. What it
// says is each script's own business (usage, or a real failure); saying nothing at
// all is the bug. Entry points are discovered from the source rather than listed,
// so a new subcommand is covered the day it is written.
//
// Run standalone: `node tests/bin-entrypoints.test.mjs`

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { repo, makeCheck } from "./lib/harness.mjs";

const binDir = path.join(repo, "bin");

const { check, finish } = makeCheck("bin-entrypoints-test");

// A bin file is an ENTRY POINT if it exports a `run`. `bin/elm-cem.js` is the
// dispatcher itself (no `run` export, always executes) and is covered by every
// other test in this suite; the library-shaped files (shared, classify,
// family-deps) export helpers only and are not meant to be executed.
const entryPoints = fs
  .readdirSync(binDir)
  .filter((f) => f.endsWith(".js"))
  .filter((f) => /module\.exports\s*=\s*\{[^}]*\brun\b/s.test(fs.readFileSync(path.join(binDir, f), "utf8")))
  .sort();

check(entryPoints.length > 0, `discovered ${entryPoints.length} run-exporting entry point(s) in bin/`);

const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-entrypoints-"));
try {
  for (const f of entryPoints) {
    // A fresh empty cwd per script: several of these WRITE (brand-sync scaffolds,
    // eject rewrites elm.json), and none of them may be pointed at a real repo.
    const cwd = fs.mkdtempSync(path.join(scratch, "run-"));
    const r = spawnSync("node", [path.join(binDir, f)], {
      cwd,
      encoding: "utf8",
      timeout: 120000,
    });
    const said = `${r.stdout ?? ""}${r.stderr ?? ""}`.trim();
    check(
      said.length > 0,
      `bin/${f} run directly does something (exit ${r.status}, ${said.length} bytes of output)`,
      said.length === 0 ? "  it printed nothing at all — the silent no-op" : ""
    );
  }
} finally {
  fs.rmSync(scratch, { recursive: true, force: true });
}

// The original sighting, pinned by name: check-gates is the one whose whole job is
// to notice silently-skipped work, so a silent skip of its OWN work is the sharpest
// case. Directly and through the dispatcher must agree.
{
  const direct = spawnSync("node", [path.join(binDir, "check-gates.js")], { cwd: repo, encoding: "utf8" });
  const viaCli = spawnSync("node", [path.join(binDir, "elm-cem.js"), "check-gates"], { cwd: repo, encoding: "utf8" });
  check(
    direct.stdout.trim() === viaCli.stdout.trim() && direct.status === viaCli.status,
    "check-gates direct invocation matches `elm-cem check-gates` (same output, same exit)",
    `direct(${direct.status}): ${JSON.stringify(direct.stdout.trim())}\n` +
      `  cli(${viaCli.status}): ${JSON.stringify(viaCli.stdout.trim())}`
  );
}

finish("\nbin-entrypoints-test: ALL ENTRY POINTS EXECUTE");
