#!/usr/bin/env node
// Golden byte-compare for G3: <Lib>.Family.* ported from
// bin/gen-family-package.js (which fragilely regex-reparses its own rendered
// M3e.Component.* text, gen-family-package.js:101-153) into
// Generate.Phantom.Emit.FamilyPackage. The golden reference is a fixture
// snapshot (tests/fixtures/golden-family-package/) captured from the
// CURRENT, unmodified bin/gen-family-package.js — NOT the committed
// brands/m3e/outputs/elm-m3e/elm-m3e-families tree, which was found to be
// stale (see golden.mjs's doc comment for the verification).

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { makeCheck } from "./lib/harness.mjs";
import { goldenFamilyPackageDir, runGoldenGenerate, byteEqual, seedWorkRootLicense } from "./lib/golden.mjs";

const { check, finish } = makeCheck("golden-family-package");

const goldenFamilyDir = path.join(goldenFamilyPackageDir, "src", "M3e", "Family");
const familyFiles = fs.readdirSync(goldenFamilyDir).filter((f) => f.endsWith(".elm")).sort();
check(familyFiles.length > 0, "golden elm-m3e-families fixture tree is non-empty (test setup sanity)");

const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-golden-family-"));
const outDir = path.join(work, "out");
fs.mkdirSync(outDir, { recursive: true });
seedWorkRootLicense(work);

const gen = runGoldenGenerate(outDir);
check(gen.status === 0, "elm-cem generation exits 0 against brands/m3e's real config", gen.stdout + gen.stderr);

if (gen.status === 0) {
  const repoRootFresh = path.dirname(outDir);
  const freshFamilyDir = path.join(repoRootFresh, "elm-m3e-families", "src", "M3e", "Family");

  for (const f of familyFiles) {
    const result = byteEqual(path.join(goldenFamilyDir, f), path.join(freshFamilyDir, f));
    check(result.ok, `fresh M3e/Family/${f} is byte-identical to the golden fixture`, result.detail);
  }

  const elmJson = byteEqual(
    path.join(goldenFamilyPackageDir, "elm.json"),
    path.join(repoRootFresh, "elm-m3e-families", "elm.json")
  );
  check(elmJson.ok, "fresh elm-m3e-families/elm.json is byte-identical to the golden fixture", elmJson.detail);

  const readme = byteEqual(
    path.join(goldenFamilyPackageDir, "README.md"),
    path.join(repoRootFresh, "elm-m3e-families", "README.md")
  );
  check(readme.ok, "fresh elm-m3e-families/README.md is byte-identical to the golden fixture", readme.detail);

  const license = byteEqual(
    path.join(goldenFamilyPackageDir, "LICENSE"),
    path.join(repoRootFresh, "elm-m3e-families", "LICENSE")
  );
  check(license.ok, "fresh elm-m3e-families/LICENSE is byte-identical to the golden fixture", license.detail);

  // No file must exist in the fresh tree that isn't in the golden set (proves
  // the port's clean-then-write behavior, ported from
  // gen-family-package.js:413-423's fs.rmSync of the owned src/ subtree,
  // still fires — a stale leftover family module would silently pass the
  // per-file loop above but fail this check).
  const freshFiles = fs.existsSync(freshFamilyDir) ? fs.readdirSync(freshFamilyDir).filter((f) => f.endsWith(".elm")).sort() : [];
  check(
    JSON.stringify(freshFiles) === JSON.stringify(familyFiles),
    "fresh M3e/Family/ directory listing exactly matches the golden set (no extra/missing modules)",
    `golden: ${familyFiles.join(",")} | fresh: ${freshFiles.join(",")}`
  );
}

fs.rmSync(work, { recursive: true, force: true });
finish("golden-family-package: all checks passed");
