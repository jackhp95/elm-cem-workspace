#!/usr/bin/env node
// Re-bless the phantom golden fixtures from a real generator run.
//
// The goldens had no update path, so an intentional emitter change meant
// hand-patching every fixture — error-prone, and it silently invites patching a
// fixture to match a BUG. This regenerates them the same way `gate.mjs`
// verifies them, then leaves `gate.mjs` to prove byte-equality.
//
//   node tests/phantom/bless.mjs                 all suites
//   node tests/phantom/bless.mjs --suite=native   one suite
//
// ALWAYS read the resulting `git diff` before committing: this tool cannot tell
// an intended change from a regression.

import { execFileSync, spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

import { SUITES, elmFormat, ownedBy, repo, walk } from "./suites.mjs";

const suiteArg = process.argv.find((a) => a.startsWith("--suite="))?.slice(8);
const suites = SUITES.filter((s) => !s.expectError).filter((s) => !suiteArg || s.name === suiteArg);

if (suites.length === 0) {
  console.error(`no such suite: ${suiteArg}`);
  process.exit(1);
}

let written = 0;
let added = 0;
let removed = 0;

for (const suite of suites) {
  const work = fs.mkdtempSync(path.join(os.tmpdir(), `bless-${suite.name}-`));
  const outSrc = path.join(work, "src");
  fs.mkdirSync(outSrc, { recursive: true });

  try {
    execFileSync(
      "node",
      [
        path.join(repo, "bin", "elm-cem.js"),
        `--flags-from=${suite.cem}`,
        `--config-from=${suite.config}`,
        `--output=${outSrc}`,
      ],
      { stdio: "pipe" },
    );
  } catch (e) {
    console.error(`[${suite.name}] generator crashed: ${e.stdout || ""}${e.stderr || ""}${e.message}`);
    process.exit(1);
  }
  spawnSync(elmFormat, [outSrc, "--yes"], { stdio: "pipe" });

  const got = walk(outSrc);
  // Only this suite's files: three suites share `expected/`.
  const mine = ownedBy(suite, got);
  const existing = new Set(ownedBy(suite, walk(suite.expected)));

  for (const rel of mine) {
    const dest = path.join(suite.expected, rel);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    const next = fs.readFileSync(path.join(outSrc, rel), "utf8");
    const prev = existing.has(rel) ? fs.readFileSync(dest, "utf8") : null;
    if (prev !== next) {
      fs.writeFileSync(dest, next);
      written += 1;
      if (prev === null) {
        added += 1;
        console.log(`  ADD   [${suite.name}] ${rel}`);
      } else {
        console.log(`  BLESS [${suite.name}] ${rel}`);
      }
    }
    existing.delete(rel);
  }

  // Anything left is a golden the generator no longer emits.
  for (const rel of existing) {
    fs.rmSync(path.join(suite.expected, rel), { force: true });
    removed += 1;
    console.log(`  DROP  [${suite.name}] ${rel}`);
  }

  fs.rmSync(work, { recursive: true, force: true });
}

console.log(
  `\nblessed ${written} file(s) across ${suites.length} suite(s) — ${added} added, ${removed} removed.\n` +
    `Review 'git diff' before committing, then run 'node tests/phantom/gate.mjs'.`,
);
