#!/usr/bin/env node
// _exclude end-to-end gate (regen-migration).
//
// The elm-test suite asserts `_exclude` at the Elm level (GoldenTest:
// "_exclude config drops leaked base-class components") and passes — but it calls
// Generate.generateFromManifest with an already-decoded `exclude` list, so it
// never exercises the CLI's `--config-from` merge. That merge (bin/elm-cem.js
// `deepMergeConfigs`) is where `_exclude` actually broke: it spread the top-level
// value with `{ ...(out[key] || {}), ...value }`, which turns the JSON ARRAY
// `["ActionElementBase", …]` into the OBJECT `{ "0": "ActionElementBase", … }`.
// The Elm decoder then fails to read that object as `List String` and silently
// falls back to `[]`, so nothing is excluded and the four leaked m3e base classes
// (ActionElementBase, MenuItemElementBase, ProgressElementIndicatorBase,
// TooltipElementBase) kept emitting + barreling.
//
// This test runs the REAL CLI with a `--config-from` file carrying `_exclude`
// and asserts the excluded declaration emits NO modules while a non-excluded one
// still does. Run standalone: `node tests/exclude-cli.test.mjs`. Wired into
// `npm test`.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, "..");
const manifest = path.join(here, "fixtures", "wc-widgets.cem.json");

function fail(msg) {
  console.error(`\nexclude-cli: FAIL — ${msg}`);
  process.exit(1);
}

const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-exclude-"));
const outSrc = path.join(work, "src");
fs.mkdirSync(outSrc, { recursive: true });

// A package elm.json next to src/ so the CLI's `syncExposedModules` runs (it only
// touches `type: package`). This exercises the issue #42 contract: the generated
// `<Lib>/Review/Facts.elm` module IS listed in `exposed-modules` (a consuming
// review config imports it), while every other `<Lib>/Review/*` and `*/Internal`
// module stays out. Review.Facts imports `Cem.Facts` from the zero-dep
// `jackhp95/elm-cem-facts` package, which the brand must dep at Stage F (#48).
// Seeded empty; the CLI rewrites it.
fs.writeFileSync(
  path.join(work, "elm.json"),
  JSON.stringify(
    {
      type: "package",
      name: "wc/widgets",
      summary: "exclude-cli fixture",
      license: "BSD-3-Clause",
      version: "1.0.0",
      "exposed-modules": [],
      "elm-version": "0.19.0 <= v < 0.20.0",
      dependencies: {
        "elm/core": "1.0.0 <= v < 2.0.0",
        "elm/html": "1.0.0 <= v < 2.0.0",
        "elm/json": "1.0.0 <= v < 2.0.0",
        "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
      },
      "test-dependencies": {},
    },
    null,
    4,
  ) + "\n",
);

// A config file carrying the top-level `_exclude` array and `_phantom: true`
// (the legacy pipeline is retired; all callers must opt into phantom). Passed via
// --config-from so it travels through deepMergeConfigs exactly as slots.json does.
const configPath = path.join(work, "exclude.json");
fs.writeFileSync(configPath, JSON.stringify({ _phantom: true, _exclude: ["WcMenuTrigger"] }) + "\n");

try {
  execFileSync(
    "node",
    [
      path.join(repo, "bin", "elm-cem.js"),
      `--flags-from=${manifest}`,
      `--config-from=${configPath}`,
      `--output=${outSrc}`,
    ],
    { stdio: "inherit" },
  );
} catch (e) {
  fail(`generator crashed with a --config-from _exclude: ${e.message}`);
}

const walk = (dir) =>
  fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) => {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) return walk(full);
    return e.name.endsWith(".elm") ? [full] : [];
  });

const modules = walk(outSrc).map((m) => path.relative(outSrc, m).split(path.sep).join("/"));
if (modules.length === 0) fail("generator produced no .elm modules");

const leaked = modules.filter((m) => m.includes("MenuTrigger"));
const kept = modules.filter((m) => m.includes("Widget"));

if (leaked.length > 0) {
  fail(
    `_exclude did NOT drop the excluded declaration — these modules leaked:\n  ` +
      leaked.join("\n  "),
  );
}
if (kept.length === 0) {
  fail("a non-excluded declaration (WcWidget) emitted no modules — _exclude over-matched");
}

// Issue #42: the review-only Facts module must be emitted to src/ AND now be
// listed in exposed-modules (it is the elm-review-cem contract — a consuming
// review config imports `<Lib>.Review.Facts` for its `facts : List Fact`). It
// imports `Cem.Facts` from the zero-dep `jackhp95/elm-cem-facts` package, so
// the published brand must dep that package at Stage F (issue #48). Every OTHER
// `<Lib>.Review.*` module (and every `*.Internal` module) must stay unexposed.
const factsEmitted = modules.some((m) => m.endsWith("/Review/Facts.elm"));
if (!factsEmitted) {
  fail("expected the generator to emit a <Lib>/Review/Facts.elm module, but none was found");
}
const exposedAfter = JSON.parse(fs.readFileSync(path.join(work, "elm.json"), "utf8"))["exposed-modules"];
const factsExposed = exposedAfter.filter((m) => /(^|\.)Review\.Facts$/.test(m));
if (factsExposed.length === 0) {
  fail("expected <Lib>.Review.Facts to be listed in exposed-modules (issue #42), but it was not");
}
const leakedReview = exposedAfter.filter(
  (m) => /(^|\.)Review(\.|$)/.test(m) && !/(^|\.)Review\.Facts$/.test(m),
);
if (leakedReview.length > 0) {
  fail(
    `a non-Facts review module leaked into exposed-modules (elm publish / elm make --docs would break):\n  ` +
      leakedReview.join("\n  "),
  );
}
const leakedInternal = exposedAfter.filter((m) => /(^|\.)Internal(\.|$)/.test(m));
if (leakedInternal.length > 0) {
  fail(`an Internal module leaked into exposed-modules:\n  ` + leakedInternal.join("\n  "));
}

console.log(
  `exclude-cli: OK — WcMenuTrigger excluded via --config-from (0 leaked modules), ` +
    `WcWidget still emitted (${kept.length} module(s)); ` +
    `${factsExposed.join(", ")} now exposed, other Review/Internal modules kept out (${exposedAfter.length} exposed).`,
);
fs.rmSync(work, { recursive: true, force: true });
