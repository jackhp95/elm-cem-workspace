// golden.mjs — shared helper for byte-compare tests that regenerate
// brands/m3e's REAL output (not a throwaway fixture brand) and diff specific
// paths against golden reference files. Used by golden-icon-module.test.mjs
// (G2) and golden-family-package.test.mjs (G3) so both stay in lockstep with
// the same invocation.
//
// IMPORTANT — the golden reference is NOT the committed
// brands/m3e/outputs/elm-m3e/{src,elm-m3e-icons,elm-m3e-families} tree.
// Verified 2026-08-20: that committed tree has been run through elm-format
// (or similar) at some point after generation and never regenerated since —
// every module `.elm` file differs from what the CURRENT, unmodified JS
// generators (bin/gen-icon-module.js / bin/gen-family-package.js) actually
// produce right now (exposing lists collapsed to one line, doc comments
// split across two lines, in the committed copy; elm.json/README.md are
// unaffected and DO match). This is exactly the same staleness the parallel
// B1 flags-plumbing verification flagged (324 stale files, real A/B regen
// vs regen was byte-identical, only regen-vs-old-commit differs). So the
// correct byte-equality target for this port is "what the generator
// produces today," snapshotted once as fixtures BEFORE any Elm port
// touched the pipeline — not the stale git-committed tree. See
// tests/fixtures/golden-icon-module/ and tests/fixtures/golden-family-package/.

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { repo } from "./harness.mjs";

export const fixturesDir = path.join(repo, "tests", "fixtures");
export const goldenIconModuleDir = path.join(fixturesDir, "golden-icon-module");
export const goldenFamilyPackageDir = path.join(fixturesDir, "golden-family-package");

const cli = path.join(repo, "bin", "elm-cem.js");
const elmM3e = path.join(repo, "..", "..", "brands", "m3e", "outputs", "elm-m3e");

/** Run elm-cem against brands/m3e's real config, writing Face A into `outputDir`. */
export function runGoldenGenerate(outputDir) {
  return spawnSync(
    process.execPath,
    [
      cli,
      "--flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json",
      "--config-from=config/slots.json",
      "--config-from=config/native-mdn.json",
      "--config-from=config/examples.generated.json",
      `--output=${outputDir}`,
    ],
    {
      cwd: elmM3e,
      encoding: "utf8",
      env: { ...process.env, PATH: `${path.join(elmM3e, "node_modules", ".bin")}:${process.env.PATH}` },
    }
  );
}

/** Byte-compare `freshPath` against `goldenPath`; returns { ok, detail }. */
export function byteEqual(goldenPath, freshPath) {
  if (!fs.existsSync(goldenPath)) return { ok: false, detail: `golden file missing: ${goldenPath}` };
  if (!fs.existsSync(freshPath)) return { ok: false, detail: `fresh file missing: ${freshPath}` };
  const a = fs.readFileSync(goldenPath);
  const b = fs.readFileSync(freshPath);
  if (a.equals(b)) return { ok: true, detail: "byte-identical" };
  return { ok: false, detail: `DIFFERS: ${goldenPath} vs ${freshPath} (${a.length} vs ${b.length} bytes)` };
}
