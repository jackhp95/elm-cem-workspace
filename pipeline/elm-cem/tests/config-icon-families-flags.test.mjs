#!/usr/bin/env node
// Proves _iconModule and _families reach Elm's decoded _config (G1). Before
// this test, `grep -rn "_families\|_iconModule" core/elm-cem/codegen/` finds
// NOTHING — the two JS generators read a second, independent JSON.parse of
// the same config files and Elm's decoder never sees these keys at all.
//
// This test has two parts:
//
//   1. A direct unit test of `bin/config-merge.js`'s `deepMergeConfigs` — the
//      function `elm-cem.js`'s `injectConfig` calls to build flags._config
//      from N `--config-from` files. Testing it directly (rather than trying
//      to recover elm-cem.js's merged temp file after the fact) sidesteps a
//      real race: `writeTemp`'s files are removed by a `process.on("exit", ...)`
//      hook the instant the CLI process exits, before a parent process could
//      ever read them back.
//   2. An end-to-end CLI smoke check that a real `--config-from` file carrying
//      `_iconModule`/`_families` doesn't make the CLI itself reject/drop them
//      before generation runs (it currently fails later, in the JS
//      `gen-icon-module`/`gen-family-package` steps that G2/G3 replace — this
//      only proves the CLI-level merge step succeeds, which is Task 1's scope).

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { repo, makeCheck } from "./lib/harness.mjs";
import { deepMergeConfigs } from "../bin/config-merge.js";

const cli = path.join(repo, "bin", "elm-cem.js");
const { check, finish } = makeCheck("config-icon-families-flags");

// ── Part 1: unit test of deepMergeConfigs ────────────────────────────────────

{
  const single = deepMergeConfigs([
    {
      _iconModule: {
        lib: "Wc",
        iconComp: "Icon",
        catalogFrom: "config/icons-catalog.json",
        tag: "wc-icon",
        iconFamily: "Test Icons",
      },
      _families: {
        lib: "Wc",
        namespace: "Family",
        families: { Widget: { root: "Widget", members: [] } },
      },
    },
  ]);
  check(
    typeof single._iconModule === "object" && single._iconModule.tag === "wc-icon",
    "_iconModule survives a single-object merge unchanged",
    JSON.stringify(single)
  );
  check(
    typeof single._families === "object" && single._families.namespace === "Family",
    "_families survives a single-object merge unchanged",
    JSON.stringify(single)
  );
}

// Regression proof: the pre-fix `deepMergeConfigs` merged top-level keys ONE
// level deep (`{...out[comp], ...fields}`), so when a SECOND object also sets
// `_iconModule.package`, the whole `package` object from the first was
// silently replaced rather than field-merged, dropping `package.dir`.
{
  const merged = deepMergeConfigs([
    {
      _iconModule: {
        lib: "Wc",
        iconComp: "Icon",
        catalogFrom: "config/icons-catalog.json",
        tag: "wc-icon",
        iconFamily: "Test Icons",
        attribution: "first",
        package: { dir: "wc-icons", name: "wc-icons" },
      },
    },
    {
      _iconModule: {
        attribution: "second",
        package: { summary: "Icon package" },
      },
    },
  ]);
  const im = merged._iconModule;
  check(Boolean(im), "_iconModule present after two-object merge", JSON.stringify(merged));
  check(
    im && im.tag === "wc-icon" && im.iconFamily === "Test Icons",
    "fields only present in the FIRST object survive the second object's merge",
    JSON.stringify(im)
  );
  check(
    im && im.attribution === "second",
    "a scalar field present in BOTH objects takes the SECOND (last-wins) value",
    JSON.stringify(im)
  );
  check(
    im && im.package && im.package.dir === "wc-icons" && im.package.summary === "Icon package",
    "_iconModule.package is deep-merged across objects, not replaced wholesale (the fixed bug)",
    JSON.stringify(im && im.package)
  );
}

// Existing behavior must be preserved: per-component `attrTypes` merge (the
// original two-level use case) still works after generalizing to full depth.
{
  const merged = deepMergeConfigs([
    { Button: { attrTypes: { variant: "string" } } },
    { Button: { syntheticAttrs: { tocIgnore: { htmlName: "m3e-toc-ignore" } } } },
  ]);
  check(
    merged.Button && merged.Button.attrTypes && merged.Button.attrTypes.variant === "string" &&
      merged.Button.syntheticAttrs && merged.Button.syntheticAttrs.tocIgnore,
    "existing per-component attrTypes/syntheticAttrs merge is unaffected by the recursive generalization",
    JSON.stringify(merged.Button)
  );
}

// Array-valued top-level keys stay last-wins (never index-merged).
{
  const merged = deepMergeConfigs([{ _exclude: ["A", "B"] }, { _exclude: ["C"] }]);
  check(
    Array.isArray(merged._exclude) && merged._exclude.length === 1 && merged._exclude[0] === "C",
    "_exclude (array-valued) stays last-wins, never index-merged",
    JSON.stringify(merged._exclude)
  );
}

// ── Part 2: CLI smoke check — the merge step doesn't choke on these keys ────

{
  const brand = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-icon-families-flags-"));
  fs.mkdirSync(path.join(brand, "config"), { recursive: true });
  fs.writeFileSync(
    path.join(brand, "custom-elements.json"),
    JSON.stringify({ schemaVersion: "1.0.0", modules: [] })
  );
  fs.writeFileSync(
    path.join(brand, "config", "slots.json"),
    JSON.stringify({
      _phantom: true,
      _iconModule: { lib: "Wc", iconComp: "Icon", catalogFrom: "config/icons-catalog.json", tag: "wc-icon", iconFamily: "Test Icons" },
      _families: { lib: "Wc", namespace: "Family", families: { Widget: { root: "Widget", members: [] } } },
    })
  );

  const gen = spawnSync(
    "node",
    [
      cli,
      `--flags-from=${path.join(brand, "custom-elements.json")}`,
      "--config-from=config/slots.json",
      `--output=${path.join(brand, "src")}`,
    ],
    { cwd: brand, encoding: "utf8" }
  );
  check(
    (gen.stdout + gen.stderr).includes("elm-cem: merged --config-from"),
    "elm-cem.js's --config-from merge step runs without choking on _iconModule/_families",
    gen.stdout + gen.stderr
  );
  fs.rmSync(brand, { recursive: true, force: true });
}

finish("config-icon-families-flags: all checks passed");
