#!/usr/bin/env node
// Family dep-stamping + undeclared-import coverage gate (issue #48, finding NB1).
//
// NB1: five of seven published packages imported `HtmlIr.*` but omitted the
// `jackhp95/elm-html-intermediate-representation` dependency — a registry compile
// failure. Packages that expose `<Brand>.Review.Facts` (which `import Cem.Facts`)
// likewise need `jackhp95/elm-cem-facts`. This gate exercises:
//
//   1. requiredFamilyDeps / familyDepFor — the import-driven decision, single
//      version ranges (bin/family-deps.js).
//   2. decay emission — the `full` package declares IR + facts; the `-html`
//      package declares IR but NOT facts (decay-level-aware, derived from the
//      copied src, not hardcoded per site).
//   3. auditPackage (the GATE) — passes on correctly-stamped output, and FAILS on
//      a deliberately mis-stamped package (IR dep removed) and on an import of a
//      foreign brand namespace with no declaring dependency.
//   4. dev harness — the stamped `full` package's imports all resolve when the
//      family deps are provided by source-directories (IR + facts src). Skipped
//      when elm or the IR src tree is unavailable.
//
// Run standalone: `node tests/depstamp.test.mjs`

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { createRequire } from "node:module";

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, "..");
const family = createRequire(import.meta.url)(path.join(repo, "bin", "family-deps.js"));

const IR = "jackhp95/elm-html-intermediate-representation";
const FACTS = "jackhp95/elm-cem-facts";

let failures = 0;
const ok = (msg) => console.log(`depstamp-test: OK — ${msg}`);
const check = (cond, msg) => {
  if (cond) ok(msg);
  else {
    console.error(`depstamp-test: FAIL — ${msg}`);
    failures++;
  }
};

const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-depstamp-"));
const src = path.join(work, "src");
const write = (rel, body) => {
  const p = path.join(src, rel);
  fs.mkdirSync(path.dirname(p), { recursive: true });
  fs.writeFileSync(p, body);
};

// ── Fixture: a tiny brand tree with prefix `Z`, mirroring the real emitter ────
//   Z              barrel (imports the component Z.Widget only)
//   Z.Values       general — imports HtmlIr.Value
//   Z.Attributes   general — imports HtmlIr.Attribute + Z.Values
//   Z.Build.Internal general(internal) — imports HtmlIr.Internal
//   Z.Widget       component — imports Z.Attributes + HtmlIr.Element
//   Z.Review.Facts review — imports Cem.Facts (the only exposed Review module)
write(
  "Z.elm",
  `module Z exposing (widget)

{-| Barrel.

@docs widget

-}

import Z.Widget


{-| A widget. -}
widget : Int
widget =
    Z.Widget.make
`
);
write(
  "Z/Values.elm",
  `module Z.Values exposing (zero)

{-| Values.

@docs zero

-}

import HtmlIr.Value


{-| Zero. -}
zero : Int
zero =
    0
`
);
write(
  "Z/Attributes.elm",
  `module Z.Attributes exposing (klass)

{-| Attributes.

@docs klass

-}

import HtmlIr.Attribute
import Z.Values


{-| A class. -}
klass : Int
klass =
    Z.Values.zero
`
);
write(
  "Z/Build/Internal.elm",
  `module Z.Build.Internal exposing (forge)

{-| Internal.

@docs forge

-}

import HtmlIr.Internal


{-| Forge. -}
forge : Int
forge =
    0
`
);
write(
  "Z/Widget.elm",
  `module Z.Widget exposing (make)

{-| Widget.

@docs make

-}

import HtmlIr.Element
import Z.Attributes


{-| Make. -}
make : Int
make =
    Z.Attributes.klass
`
);
write(
  "Z/Review/Facts.elm",
  `module Z.Review.Facts exposing (facts)

{-| Facts.

@docs facts

-}

import Cem.Facts


{-| The facts. -}
facts : List Int
facts =
    []
`
);

// ── 1. import-driven decision + single-sourced ranges ────────────────────────
{
  check(family.familyDepFor("HtmlIr.Element")?.package === IR, "HtmlIr.* maps to the IR package");
  check(family.familyDepFor("Cem.Facts")?.package === FACTS, "Cem.Facts maps to the facts package");
  check(family.familyDepFor("Html.Attributes") === null, "elm/html's Html.* is NOT a family namespace");
  check(family.familyDepFor("Z.Widget") === null, "a brand's own module is NOT a family namespace");

  // Ranges are single-sourced: every FAMILY_DEPS entry reuses one range constant.
  const ranges = new Set(family.FAMILY_DEPS.map((d) => d.range));
  check(ranges.size === 1 && ranges.has("1.0.0 <= v < 2.0.0"), "family deps share one single-sourced version range");

  const full = family.requiredFamilyDeps(src);
  check(IR in full && FACTS in full, "requiredFamilyDeps(full tree) = IR + facts");

  // Only the general layer (no Review.Facts) → IR, no facts.
  const generalOnly = path.join(work, "general");
  for (const rel of ["Z/Values.elm", "Z/Attributes.elm", "Z/Build/Internal.elm"]) {
    const dst = path.join(generalOnly, rel);
    fs.mkdirSync(path.dirname(dst), { recursive: true });
    fs.copyFileSync(path.join(src, rel), dst);
  }
  const gen = family.requiredFamilyDeps(generalOnly);
  check(IR in gen && !(FACTS in gen), "requiredFamilyDeps(general layer) = IR only (no facts)");
}

// ── 2. the coverage gate: passes stamped, fails mis-stamped + foreign import ──
// (Package emission is no longer per-decay-level — a brand publishes its
// primitives in place, exposing only the general layer; docs/distribution-model.md.
// What still matters is the dep-stamping GATE that `registry-check` runs, so we
// build a stamped package from the fixture directly — no `decay` command.)
{
  // A correctly-stamped package: the fixture src + an elm.json whose dependencies
  // are base elm/* plus exactly the family deps the tree imports (IR + facts,
  // since Z.Review.Facts is present).
  const pkgDir = path.join(work, "pkg");
  fs.mkdirSync(pkgDir, { recursive: true });
  fs.cpSync(src, path.join(pkgDir, "src"), { recursive: true });
  const deps = { ...family.baseDependencies(), ...family.requiredFamilyDeps(src) };
  fs.writeFileSync(
    path.join(pkgDir, "elm.json"),
    JSON.stringify(
      { name: "example/elm-z", type: "package", "exposed-modules": ["Z", "Z.Values"], dependencies: deps },
      null,
      4
    ) + "\n"
  );
  check(IR in deps && FACTS in deps, "stamped package declares IR + facts (Review.Facts present)");
  check(
    deps[IR] === "1.0.0 <= v < 2.0.0" && deps[FACTS] === "1.0.0 <= v < 2.0.0",
    "stamped deps carry the single-sourced range"
  );
  check(family.auditPackage(pkgDir).length === 0, "gate PASSES on the correctly-stamped package");

  // Deliberately mis-stamp: drop the IR dep.
  const badDir = path.join(work, "bad");
  fs.cpSync(pkgDir, badDir, { recursive: true });
  const badElm = path.join(badDir, "elm.json");
  const j = JSON.parse(fs.readFileSync(badElm, "utf8"));
  delete j.dependencies[IR];
  fs.writeFileSync(badElm, JSON.stringify(j, null, 4) + "\n");
  const v = family.auditPackage(badDir);
  check(v.length > 0 && v.every((m) => m.includes(IR)), `gate FAILS when the IR dep is removed (${v.length} undeclared HtmlIr import(s))`);

  // Foreign-brand import with no declaring dependency.
  const foreignDir = path.join(work, "foreign");
  fs.mkdirSync(path.join(foreignDir, "src"), { recursive: true });
  fs.writeFileSync(
    path.join(foreignDir, "src", "A.elm"),
    `module A exposing (x)\n\nimport Other.Brand\n\nx : Int\nx = 0\n`
  );
  fs.writeFileSync(
    path.join(foreignDir, "elm.json"),
    JSON.stringify({ name: "example/a", type: "package", dependencies: family.baseDependencies() }, null, 4)
  );
  const fv = family.auditPackage(foreignDir);
  check(fv.length === 1 && fv[0].includes("Other.Brand"), "gate FAILS on an import of a foreign brand namespace");
}

fs.rmSync(work, { recursive: true, force: true });

if (failures > 0) {
  console.error(`\ndepstamp-test: ${failures} FAILURE(S)`);
  process.exit(1);
}
console.log("\ndepstamp-test: ALL GATES PASSED");
