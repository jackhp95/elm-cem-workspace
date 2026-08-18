#!/usr/bin/env node
// Published-primitives → vendored-full-brand eject (bin/eject.js).
//
// Eject must:
//   1. Detect the family deps the vendored brand IMPORTS (IR always; facts only
//      when Review.Facts is present) — never the brand itself, never hardcoded.
//   2. Add the vendored source-directory; remove the superseded brand dep.
//   3. Promote detected deps to direct with the version single-sourced from
//      family-deps.js (exact lower bound for an app).
//   4. Be idempotent: a second run is a no-op.
//   5. Pin @m3e/web in package.json.
//   6. Wire review: scaffold a fresh review/, or (existing) plan a safe merge +
//      hand-off instructions; the ReviewConfig is the Cem.all one-liner.
//
// Portable: synthetic vendor trees in a temp dir; needs neither elm nor git.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { createRequire } from "node:module";
import { repo, makeCheck } from "./lib/harness.mjs";

const require = createRequire(import.meta.url);
const eject = require(path.join(repo, "bin", "eject.js"));

const IR = "jackhp95/elm-html-intermediate-representation";
const FACTS = "jackhp95/elm-cem-facts";
const M3E = "jackhp95/elm-m3e";
const brand = eject.BRANDS.m3e;

const { check, finish } = makeCheck("eject-test");

// Build a synthetic vendored M3e tree. `withReviewFacts` includes the one module
// that imports Cem.Facts.
function makeVendorTree(withReviewFacts) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "eject-vendor-"));
  const write = (rel, src) => {
    const p = path.join(dir, rel);
    fs.mkdirSync(path.dirname(p), { recursive: true });
    fs.writeFileSync(p, src);
  };
  // barrel + a component + a general module — all import HtmlIr + internal M3e.*
  write("M3e.elm", "module M3e exposing (button)\nimport HtmlIr.Element\nimport M3e.Button\n");
  write("M3e/Button.elm", "module M3e.Button exposing (view)\nimport HtmlIr.Element\nimport M3e.Html\n");
  write("M3e/Html.elm", "module M3e.Html exposing (button)\nimport HtmlIr.Internal\n");
  if (withReviewFacts) {
    write("M3e/Review/Facts.elm", "module M3e.Review.Facts exposing (facts)\nimport Cem.Facts exposing (Fact)\n");
  }
  return dir;
}

// ── 1. detection ─────────────────────────────────────────────────────────────
{
  const withReview = makeVendorTree(true);
  const deps = eject.detectFamilyDeps(withReview, brand.package);
  check(deps.has(IR), "detects IR from HtmlIr.* imports");
  check(deps.has(FACTS), "detects facts from M3e.Review.Facts → Cem.Facts");
  check(!deps.has(M3E), "does NOT list the brand itself (M3e.* imports are internal)");
  fs.rmSync(withReview, { recursive: true, force: true });

  const noReview = makeVendorTree(false);
  const deps2 = eject.detectFamilyDeps(noReview, brand.package);
  check(deps2.has(IR) && !deps2.has(FACTS), "without Review.Facts: IR only, no facts dep");
  fs.rmSync(noReview, { recursive: true, force: true });
}

// ── 2/3. elm.json plan + apply (application) ─────────────────────────────────
{
  const elmJson = {
    type: "application",
    "source-directories": ["src"],
    dependencies: {
      direct: { "elm/core": "1.0.5", [M3E]: "1.0.0" },
      indirect: { [IR]: "1.0.0", [FACTS]: "1.0.0" },
    },
  };
  const detected = new Set([IR, FACTS]);
  const plan = eject.planEject(elmJson, "vendor/M3e", detected, brand);
  check(plan.addSrcDir === "vendor/M3e", "plans to add vendor/M3e to source-directories");
  check(plan.removeDep === M3E, "plans to remove the elm-m3e primitives dep");
  check(plan.addDeps.map((d) => d.package).join(",") === `${IR},${FACTS}`, "promotes IR + facts, ordered");
  check(plan.addDeps.every((d) => d.value === "1.0.0"), "application pins exact lower-bound versions");

  eject.applyEject(elmJson, plan);
  const direct = elmJson.dependencies.direct;
  check(direct[M3E] === undefined, "apply: elm-m3e removed from direct");
  check(direct[IR] === "1.0.0" && direct[FACTS] === "1.0.0", "apply: IR + facts now direct");
  check(elmJson.dependencies.indirect[IR] === undefined, "apply: promoted deps dropped from indirect");
  check(elmJson["source-directories"].includes("vendor/M3e"), "apply: vendor dir added");

  // idempotency
  const plan2 = eject.planEject(elmJson, "vendor/M3e", detected, brand);
  check(plan2.addSrcDir === null, "idempotent: source-dir already present");
  check(eject.pendingDeps(elmJson, plan2).length === 0, "idempotent: deps already declared");
}

// ── 4. package.json pin ──────────────────────────────────────────────────────
{
  const pkg = { devDependencies: { "@m3e/web": "2.5.14" } };
  const plan = eject.planPkg(pkg, brand, "2.6.2");
  check(plan.change && plan.current === "2.5.14" && plan.version === "2.6.2", "plans @m3e/web 2.5.14 → 2.6.2");
  eject.applyPkg(pkg, plan);
  check(pkg.devDependencies["@m3e/web"] === "2.6.2", "apply: @m3e/web pinned");

  const noWeb = { devDependencies: {} };
  const plan2 = eject.planPkg(noWeb, brand, "2.6.2");
  check(plan2.change && plan2.current === null, "adds @m3e/web when absent");
}

// ── 5/6. review wiring ───────────────────────────────────────────────────────
{
  const cfg = eject.reviewConfigSource(brand);
  check(cfg.includes("Cem.all M3e.Review.Facts.facts"), "ReviewConfig is the Cem.all one-liner");
  check(cfg.includes("import Cem") && cfg.includes("import M3e.Review.Facts"), "ReviewConfig imports Cem + brand facts");

  const scaffold = eject.planReview({ withReview: true, reviewExists: false, brand, vendorFromReview: "../vendor/M3e" });
  check(scaffold.mode === "scaffold", "no review/ → scaffold");
  check(scaffold.elmJson.dependencies.direct["jackhp95/elm-review-cem"] !== undefined, "scaffold elm.json declares elm-review-cem");
  check(scaffold.elmJson["source-directories"].includes("../vendor/M3e"), "scaffold source-dirs reach the vendored facts");

  const merge = eject.planReview({ withReview: true, reviewExists: true, brand, vendorFromReview: "../vendor/M3e" });
  check(merge.mode === "merge", "existing review/ → merge, not overwrite");
  check(merge.addDeps["jackhp95/elm-cem-facts"] !== undefined, "merge adds facts dep to review/elm.json");
  check(merge.instructions.includes("++ Cem.all M3e.Review.Facts.facts"), "merge prints the ReviewConfig hand-off snippet");

  const skip = eject.planReview({ withReview: false, reviewExists: false, brand, vendorFromReview: "x" });
  check(skip.mode === "skip", "no --with-review → skip");
}

finish("\neject-test: ALL TESTS PASSED", "FAILED");
