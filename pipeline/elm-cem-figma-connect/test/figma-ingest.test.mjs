import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  loadFigmaExport,
  displayNameOf,
  isVariantName,
  parseVariantName,
} from "../src/ingest/figma.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const fixturePath = path.join(here, "fixtures", "figma-export.m3-kit.json");

// Loaded once — the fixture is ~3.9MB and every assertion below reads the
// same derived views.
const loaded = loadFigmaExport(fixturePath);

test("loadFigmaExport: validates and derives sets/standalones/variants from the m3-kit fixture", () => {
  assert.equal(loaded.data.components.length, 5770, "total components");
  assert.equal(loaded.sets.length, 171, "COMPONENT_SET count");
  assert.equal(loaded.variants.length, 5354, "variant COMPONENT count");
  assert.equal(loaded.standalones.length, 245, "standalone COMPONENT count");

  // sets + variants + standalones must partition the flat components array.
  assert.equal(
    loaded.sets.length + loaded.variants.length + loaded.standalones.length,
    loaded.data.components.length
  );
});

test("loadFigmaExport: variables pass-through matches the real kit-variables.json counts", () => {
  const { variables } = loaded.data;
  assert.equal(variables.variables.length, 304, "variable count");

  const m3 = variables.collections.find((c) => c.name === "M3");
  assert.ok(m3, "M3 collection present");
  assert.equal(m3.modes.length, 32, "M3 collection mode count");

  const withCodeSyntax = variables.variables.filter(
    (v) => Object.keys(v.codeSyntax).length > 0
  );
  assert.equal(withCodeSyntax.length, 0, "no variable has a bound codeSyntax yet");
});

test("loadFigmaExport: button main set (57994:2227) exposes its captured properties", () => {
  const buttonSet = loaded.sets.find((s) => s.id === "57994:2227");
  assert.ok(buttonSet, "button main set present among derived sets");
  assert.ok(buttonSet.properties, "button main set has captured setProperties");

  const variantProps = buttonSet.properties
    .filter((p) => p.type === "VARIANT")
    .map((p) => p.displayName)
    .sort();
  // NOTE: the task brief's acceptance list says "Type/Size/Width/State" for
  // this set. The real, checked-in kit-props-button-main.json (id
  // 57994:2227, variantCount 50 = 2 Type * 5 Size * 5 State) does NOT carry
  // a Width axis on THIS set — Width belongs to the separate "Icon button"
  // set (57994:10081). This is a genuine plan-vs-reality gap (see
  // task-A2-report.md); asserting the true, measured shape rather than
  // fudging it to match the brief.
  assert.deepEqual(variantProps, ["Size", "State", "Type"]);

  const textProps = buttonSet.properties.filter((p) => p.type === "TEXT");
  assert.equal(textProps.length, 1);
  assert.equal(textProps[0].displayName, "Label text");
  assert.equal(textProps[0].rawName, "Label text#58653:0");
});

test("loadFigmaExport: button main set (57994:2227) includes SLOT properties with correct displayName", () => {
  const buttonSet = loaded.sets.find((s) => s.id === "57994:2227");
  assert.ok(buttonSet.properties, "button main set has captured setProperties");

  // Two SLOT properties on this fixture set (task 3, matcher-slot-support):
  // "Trailing slot" (Task 1's original addition, no plausible CEM slot
  // counterpart) and "Trailing icon" (Task 3's addition, exact-matches
  // m3e-button's real "trailing-icon" CEM slot) — together exercising both
  // the mapped and unmapped slot-matching branches in the matcher tests.
  const slotProps = buttonSet.properties.filter((p) => p.type === "SLOT");
  assert.equal(slotProps.length, 2, "exactly two SLOT properties");

  const bySlot = Object.fromEntries(slotProps.map((p) => [p.displayName, p]));
  assert.equal(bySlot["Trailing slot"].rawName, "Trailing slot#58653:150", "SLOT rawName is the original Figma name");
  assert.equal(bySlot["Trailing slot"].type, "SLOT", "SLOT type is preserved");
  assert.equal(bySlot["Trailing icon"].rawName, "Trailing icon#58653:151", "SLOT rawName is the original Figma name");
  assert.equal(bySlot["Trailing icon"].type, "SLOT", "SLOT type is preserved");
});

test("displayNameOf: strips the Figma '#nodeId' suffix from non-variant property names", () => {
  assert.equal(displayNameOf("Label text#58653:0"), "Label text");
  assert.equal(displayNameOf("Show icon#58653:51"), "Show icon");
  // VARIANT property names never carry the suffix — pass through unchanged.
  assert.equal(displayNameOf("Type"), "Type");
});

test("isVariantName / parseVariantName: variant-name reconstruction", () => {
  assert.equal(isVariantName("Type=Square, Size=XLarge, State=Enabled"), true);
  assert.equal(isVariantName("3D Avatars / 1"), false);

  assert.deepEqual(
    parseVariantName("Type=Square, Size=XLarge, Width=Wide, State=Enabled"),
    { Type: "Square", Size: "XLarge", Width: "Wide", State: "Enabled" }
  );
});

test("loadFigmaExport: every derived variant's .props matches parseVariantName(name)", () => {
  for (const variant of loaded.variants) {
    assert.deepEqual(variant.props, parseVariantName(variant.name));
  }
});

test("loadFigmaExport: variants are grouped by page", () => {
  const buttonPageVariants = loaded.variantsByPage["Buttons"];
  assert.ok(Array.isArray(buttonPageVariants) && buttonPageVariants.length > 0);
  assert.ok(buttonPageVariants.every((v) => v.page === "Buttons"));

  // every variant appears in exactly its own page's bucket
  const total = Object.values(loaded.variantsByPage).reduce(
    (sum, list) => sum + list.length,
    0
  );
  assert.equal(total, loaded.variants.length);
});

test("loadFigmaExport: standalone components have no '=' in their name", () => {
  assert.ok(loaded.standalones.every((c) => !c.name.includes("=")));
});

test("loadFigmaExport: setProperties is present but not required for every set (A3 fills the rest later)", () => {
  const setsWithProperties = loaded.sets.filter((s) => s.properties !== undefined);
  // Only the two captured button sets in this fixture.
  assert.equal(setsWithProperties.length, 2);
  assert.equal(loaded.sets.length, 171);
});

test("loadFigmaExport: throws on a missing file", () => {
  assert.throws(
    () => loadFigmaExport(path.join(here, "fixtures", "does-not-exist.json")),
    /ENOENT/
  );
});

test("loadFigmaExport: throws with schema validation errors on a structurally invalid export", () => {
  const invalidPath = path.join(os.tmpdir(), `figma-export-invalid-${process.pid}.json`);
  // Missing every required top-level key.
  fs.writeFileSync(invalidPath, JSON.stringify({ notAFigmaExport: true }));
  try {
    assert.throws(
      () => loadFigmaExport(invalidPath),
      /missing required property "meta"/
    );
  } finally {
    fs.unlinkSync(invalidPath);
  }
});
