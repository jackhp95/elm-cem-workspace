#!/usr/bin/env node
// Golden byte-compare for G2: <Lib>.Icon ported from bin/gen-icon-module.js
// into Generate.Phantom.Emit.IconModule. The golden reference is a fixture
// snapshot (tests/fixtures/golden-icon-module/) captured from the CURRENT,
// unmodified bin/gen-icon-module.js — NOT the committed
// brands/m3e/outputs/elm-m3e tree, which was found to be stale (run through
// elm-format at some point, never regenerated since — see golden.mjs's doc
// comment for the verification). Until the Elm port lands, this test is
// GREEN under the OLD (JS) implementation (sanity baseline); the port
// (Task 5) must keep it green with gen-icon-module.js's call removed.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { makeCheck } from "./lib/harness.mjs";
import { goldenIconModuleDir, runGoldenGenerate, byteEqual, seedWorkRootLicense } from "./lib/golden.mjs";

const { check, finish } = makeCheck("golden-icon-module");

const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-golden-icon-"));
const outDir = path.join(work, "out");
fs.mkdirSync(outDir, { recursive: true });
seedWorkRootLicense(work);

const gen = runGoldenGenerate(outDir);
check(gen.status === 0, "elm-cem generation exits 0 against brands/m3e's real config", gen.stdout + gen.stderr);

if (gen.status === 0) {
  const mainIcon = byteEqual(path.join(goldenIconModuleDir, "M3e", "Icon.elm"), path.join(outDir, "M3e", "Icon.elm"));
  check(mainIcon.ok, "fresh src/M3e/Icon.elm is byte-identical to the golden fixture", mainIcon.detail);

  // The standalone elm-m3e-icons/ package: repoRoot (gen-icon-module.js:503
  // and, post-port, the Elm emitter's equivalent) is ONE level above --output.
  const repoRootFresh = path.dirname(outDir);
  const pkgIcon = byteEqual(
    path.join(goldenIconModuleDir, "elm-m3e-icons", "src", "M3e", "Icon.elm"),
    path.join(repoRootFresh, "elm-m3e-icons", "src", "M3e", "Icon.elm")
  );
  check(pkgIcon.ok, "fresh elm-m3e-icons/src/M3e/Icon.elm is byte-identical to the golden fixture", pkgIcon.detail);

  const pkgElmJson = byteEqual(
    path.join(goldenIconModuleDir, "elm-m3e-icons", "elm.json"),
    path.join(repoRootFresh, "elm-m3e-icons", "elm.json")
  );
  check(pkgElmJson.ok, "fresh elm-m3e-icons/elm.json is byte-identical to the golden fixture", pkgElmJson.detail);

  const pkgReadme = byteEqual(
    path.join(goldenIconModuleDir, "elm-m3e-icons", "README.md"),
    path.join(repoRootFresh, "elm-m3e-icons", "README.md")
  );
  check(pkgReadme.ok, "fresh elm-m3e-icons/README.md is byte-identical to the golden fixture", pkgReadme.detail);

  const pkgLicense = byteEqual(
    path.join(goldenIconModuleDir, "elm-m3e-icons", "LICENSE"),
    path.join(repoRootFresh, "elm-m3e-icons", "LICENSE")
  );
  check(pkgLicense.ok, "fresh elm-m3e-icons/LICENSE is byte-identical to the golden fixture", pkgLicense.detail);
}

fs.rmSync(work, { recursive: true, force: true });
finish("golden-icon-module: all checks passed");
