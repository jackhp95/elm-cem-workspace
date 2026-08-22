// golden.mjs — shared helper for byte-compare tests that regenerate
// brands/m3e's REAL output (not a throwaway fixture brand) and diff specific
// paths against golden reference files. Used by golden-icon-module.test.mjs
// (G2).
//
// golden-family-package.test.mjs (G3) used to share this helper too, but was
// deleted 2026-08-22: the reconcile work of 2026-08-21 (74fad9d9 "land Side A
// naming config onto Side B Elm generator") changed `_families.package.dir`
// from a bare `"elm-m3e-families"` to `"../elm-m3e-components"` — a rename
// AND a newly-doubled `../` escape (the emitter already prepends its own
// `"../"`, so the fresh tree now lands TWO directory levels above `--output`
// instead of one). That silently writes the fresh sibling package outside
// the test's own `mkdtempSync` work dir entirely, onto the shared
// `os.tmpdir()/elm-m3e-*` path — a real, separate latent bug (global tmp
// pollution / directory-escape depth drift), not something a fixture
// re-bless could paper over. The test was never wired into any `test:*`
// script or CI gate; superseding coverage of `elm-m3e-components` byte
// fidelity lives in brands/m3e's own `check:cem`/`check:families` gates
// (`elm-cem regen-drift --nested-pkg=../elm-m3e-components`), which ARE wired
// into that brand's real `gate`.
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

const cli = path.join(repo, "bin", "elm-cem.js");
const elmM3e = path.join(repo, "..", "..", "brands", "m3e", "generated", "package", "elm-m3e");

/** Run elm-cem against brands/m3e's real config, writing Face A into `outputDir`. */
export function runGoldenGenerate(outputDir) {
  return spawnSync(
    process.execPath,
    [
      cli,
      "--flags-from=../../docs/elm-m3e-docs/node_modules/@m3e/web/dist/custom-elements.json",
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

/** Path to the real elm-m3e workspace root's LICENSE file. */
export const elmM3eLicensePath = path.join(elmM3e, "LICENSE");

/**
 * Copy the real elm-m3e workspace root's LICENSE into a throwaway `workDir`
 * (the directory ONE level above the test's `--output` tmp dir), so
 * `bin/elm-cem.js`'s `injectPackageLicense` — which reads
 * `<repoRoot>/LICENSE`, where `repoRoot` is computed as `dirname(--output)` —
 * finds one at the tmp `repoRoot` a test actually generates against. Without
 * this, a fresh mkdtempSync work dir has no LICENSE at that location and the
 * icon/family package emitters correctly (per their own designed behavior)
 * skip emitting LICENSE — which would make the golden tests pass trivially
 * without ever exercising the LICENSE emission path at all.
 */
export function seedWorkRootLicense(workDir) {
  fs.copyFileSync(elmM3eLicensePath, path.join(workDir, "LICENSE"));
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
