#!/usr/bin/env node
// Phantom gate — golden + acid harness over MULTIPLE fixture suites.
//
// Per suite: (1) run the real CLI on the fixture CEM+config, elm-format, and
// byte-diff every emitted file against expected/; (2) check the run's info
// channel against `expectInfoContains`, for decisions that are invisible in the
// emitted bytes; (3) compile the acid app against the EMITTED output (Good must
// compile; every bad/*.elm must fail).
//
// Modes:
//   node tests/phantom/gate.mjs               all suites, golden + acid
//   node tests/phantom/gate.mjs --spec        acid against the goldens themselves
//   node tests/phantom/gate.mjs --suite=native   restrict to one suite

import { execFileSync, spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { SUITES as ALL_SUITES, elm, elmFormat, here, irSrc, ownedBy, repo, walk } from "./suites.mjs";

const specMode = process.argv.includes("--spec");
const suiteArg = process.argv.find((a) => a.startsWith("--suite="))?.slice(8);

// Suite table, path constants and `walk` live in suites.mjs so this harness and
// tests/phantom/bless.mjs cannot disagree about what a golden is.
const SUITES = ALL_SUITES.filter((s) => !suiteArg || s.name === suiteArg);

let failures = 0;
const fail = (msg) => {
  console.error(`FAIL  ${msg}`);
  failures += 1;
};
const pass = (msg) => console.log(`PASS  ${msg}`);

for (const suite of SUITES) {
  console.log(`── suite: ${suite.name}`);

  // expectError mode: generator should EXIT NON-ZERO
  if (suite.expectError) {
    if (specMode) continue; // skip in --spec mode
    console.log(`   [expectError mode]`);

    const result = spawnSync(
      "node",
      [
        path.join(repo, "bin", "elm-cem.js"),
        `--flags-from=${suite.cem}`,
        `--config-from=${suite.config}`,
        `--output=/tmp/never-created-expectError-${suite.name}`,
      ],
      { encoding: "utf8" }
    );

    const output = result.stdout + result.stderr;
    if (result.status !== 0) {
      pass(`[${suite.name}] generator exited non-zero (expected)`);
      // `expectErrorContains` is a list of AND-groups: every group must have all of
      // its needles present somewhere in the generator's output. A failing run that
      // says the wrong thing is worse than useless — it teaches nothing and hides the
      // real cause — so each suite pins the substrings its diagnostic must carry.
      for (const group of suite.expectErrorContains ?? []) {
        const needles = Array.isArray(group) ? group : [group];
        const missing = needles.filter((n) => !output.includes(n));
        if (missing.length === 0) {
          pass(`[${suite.name}] error names ${needles.map((n) => JSON.stringify(n)).join(" + ")}`);
        } else {
          fail(`[${suite.name}] error missing ${missing.map((n) => JSON.stringify(n)).join(", ")}`);
        }
      }
      // Print the actual error for verification
      console.error("─── error output:");
      console.error(output.split("\n").slice(0, 50).join("\n"));
      console.error("───");
    } else {
      fail(`[${suite.name}] generator succeeded (expected failure)`);
    }
    continue;
  }

  let compileAgainst = suite.expected;

  if (!specMode) {
    const work = fs.mkdtempSync(path.join(os.tmpdir(), `phantom-${suite.name}-`));
    const outSrc = path.join(work, "src");
    fs.mkdirSync(outSrc, { recursive: true });
    let info = "";
    try {
      info = execFileSync(
        "node",
        [
          path.join(repo, "bin", "elm-cem.js"),
          `--flags-from=${suite.cem}`,
          `--config-from=${suite.config}`,
          `--output=${outSrc}`,
        ],
        { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] }
      );
    } catch (e) {
      fail(`[${suite.name}] generator crashed: ${e.stdout || ""}${e.stderr || ""}${e.message}`);
      continue;
    }
    spawnSync(elmFormat, [outSrc, "--yes"], { stdio: "pipe" });

    // `expectInfoContains` pins what a SUCCESSFUL run must SAY. The goldens
    // already pin what it emits, but some decisions are deliberately invisible in
    // the emitted bytes — a kernel-blocked attribute is omitted from every
    // surface, so its absence looks identical to "the manifest never declared
    // it". The info-channel note is the only evidence the generator noticed, and
    // an omission nobody is told about is the silent-degradation failure this
    // generator keeps having to stamp out. Same AND-group shape as
    // `expectErrorContains`.
    for (const group of suite.expectInfoContains ?? []) {
      const needles = Array.isArray(group) ? group : [group];
      const missing = needles.filter((n) => !info.includes(n));
      if (missing.length === 0) {
        pass(`[${suite.name}] info reports ${needles.map((n) => JSON.stringify(n)).join(" + ")}`);
      } else {
        fail(
          `[${suite.name}] info missing ${missing.map((n) => JSON.stringify(n)).join(", ")}\n` +
            `─── info output:\n${info}\n───`
        );
      }
    }

    const got = new Set(walk(outSrc));
    const allExpected = walk(suite.expected);
    const want = new Set(suite.filterPrefix
      ? allExpected.filter(f => f.startsWith(suite.filterPrefix) || f === suite.filterPrefix + ".elm")
      : allExpected
    );
    for (const f of want) {
      if (!got.has(f)) fail(`[${suite.name}] missing emitted file: ${f}`);
      else {
        const a = fs.readFileSync(path.join(outSrc, f), "utf8");
        const b = fs.readFileSync(path.join(suite.expected, f), "utf8");
        if (a === b) pass(`[${suite.name}] golden ${f}`);
        else {
          fail(`[${suite.name}] golden diff: ${f}`);
          const d = spawnSync("diff", ["-u", path.join(suite.expected, f), path.join(outSrc, f)], {
            encoding: "utf8",
          });
          console.error(d.stdout.split("\n").slice(0, 40).join("\n"));
        }
      }
    }
    for (const f of got) if (!want.has(f)) fail(`[${suite.name}] unexpected emitted file: ${f}`);
    compileAgainst = outSrc;
  }

  const acidWork = fs.mkdtempSync(path.join(os.tmpdir(), `phantom-acid-${suite.name}-`));
  for (const d of ["src", "bad"]) {
    fs.cpSync(path.join(suite.acid, d), path.join(acidWork, d), { recursive: true });
  }
  const elmJson = JSON.parse(fs.readFileSync(path.join(suite.acid, "elm.json"), "utf8"));
  elmJson["source-directories"] = ["src", "bad", compileAgainst, irSrc];
  fs.writeFileSync(path.join(acidWork, "elm.json"), JSON.stringify(elmJson, null, 4));

  const compile = (file) =>
    spawnSync(elm, ["make", file, "--output=/dev/null"], { cwd: acidWork, encoding: "utf8" });

  const good = compile("src/Good.elm");
  if (good.status === 0) pass(`[${suite.name}] acid Good compiles`);
  else fail(`[${suite.name}] acid Good does not compile:\n${(good.stderr || good.stdout).slice(0, 2500)}`);

  for (const f of walk(path.join(suite.acid, "bad"))) {
    const r = compile(path.join("bad", f));
    if (r.status !== 0) pass(`[${suite.name}] acid bad/${f} rejected`);
    else fail(`[${suite.name}] acid bad/${f} COMPILED (must fail)`);
  }
}

console.log("----");
console.log(failures === 0 ? "phantom gate: ALL GREEN" : `phantom gate: ${failures} failure(s)`);
process.exit(failures === 0 ? 0 : 1);
