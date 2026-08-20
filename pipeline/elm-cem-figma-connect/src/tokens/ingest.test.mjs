// Task D1, Step 1-4: src/tokens/ingest.mjs's kit-token-dump normalizer.
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test src/tokens/ingest.test.mjs
//
// OFFLINE, zero new deps. Most tests load the REAL, committed dumps
// (research/figma-dumps/kit-variables.json, kit-styles.json) directly —
// per the brief, this task's whole point is asserting the MEASURED real
// counts (49/147/95/10/2/1 family split, 30 text styles, 0 codeSyntax), not
// a synthetic fixture that could quietly drift from reality. The alias-cycle
// guard is the one thing tested against a small in-memory fixture, since no
// real cycle exists in the dump to exercise it.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  familyOf,
  normalizeVariables,
  normalizeTextStyles,
  loadKitVariables,
  loadKitTextStyles,
  loadKitTokens,
  assertModesOfRecord,
  MODES_OF_RECORD,
} from "./ingest.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");
const VARIABLES_PATH = path.join(repoRoot, "research", "figma-dumps", "kit-variables.json");
const STYLES_PATH = path.join(repoRoot, "research", "figma-dumps", "kit-styles.json");

// -- familyOf -----------------------------------------------------------

test("familyOf: first '/'-segment of the name", () => {
  assert.equal(familyOf("Schemes/On Surface"), "Schemes");
  assert.equal(familyOf("State Layers/Primary/Opacity-08"), "State Layers");
  assert.equal(familyOf("Add-ons/Section background"), "Add-ons");
  assert.equal(familyOf("NoSlash"), "NoSlash");
});

// -- real dump: measured family counts (evidence #13 / brief's measured split) --

test("loadKitVariables: real dump — 304 variables total, family split matches the measured 49/147/95/10/2/1", () => {
  const { variables } = loadKitVariables(VARIABLES_PATH);
  assert.equal(variables.length, 304);

  const counts = {};
  for (const v of variables) counts[v.family] = (counts[v.family] ?? 0) + 1;

  assert.deepEqual(counts, {
    Schemes: 49,
    "State Layers": 147,
    Static: 95,
    Corner: 10,
    Tracking: 2,
    "Add-ons": 1,
  });
  assert.equal(
    Object.values(counts).reduce((a, b) => a + b, 0),
    304
  );
});

test("loadKitVariables: real dump — 4 collections, M3 has 32 modes", () => {
  const { collections } = loadKitVariables(VARIABLES_PATH);
  assert.equal(collections.length, 4);
  const m3 = collections.find((c) => c.name === "M3");
  assert.ok(m3, "M3 collection must be present");
  assert.equal(m3.modes.length, 32);
});

test("loadKitVariables: real dump — 0 variables have a non-empty codeSyntax (evidence #13)", () => {
  const { variables } = loadKitVariables(VARIABLES_PATH);
  const withCodeSyntax = variables.filter((v) => Object.keys(v.codeSyntax).length > 0);
  assert.deepEqual(withCodeSyntax, []);
});

// -- Light/Dark modes of record -------------------------------------------

test("loadKitVariables: Light and Dark resolve for every M3-collection variable (Schemes/State Layers/Add-ons)", () => {
  const { variables } = loadKitVariables(VARIABLES_PATH);
  const m3Variables = variables.filter((v) => v.collection === "M3");
  assert.equal(m3Variables.length, 197, "sanity: Schemes 49 + State Layers 147 + Add-ons 1");

  for (const v of m3Variables) {
    assert.ok("Light" in v.valuesByModeName, `${v.name} missing Light`);
    assert.ok("Dark" in v.valuesByModeName, `${v.name} missing Dark`);
    assert.notEqual(v.valuesByModeName.Light, undefined, `${v.name} Light did not resolve`);
    assert.notEqual(v.valuesByModeName.Dark, undefined, `${v.name} Dark did not resolve`);
  }

  // does not throw — this is exactly what loadKitVariables already ran internally
  assert.doesNotThrow(() => assertModesOfRecord(variables));
});

test("loadKitVariables: a real Scheme's Light/Dark values are the measured hex-equivalent RGBA (Schemes/Primary)", () => {
  const { variables } = loadKitVariables(VARIABLES_PATH);
  const primary = variables.find((v) => v.name === "Schemes/Primary");
  assert.ok(primary);
  assert.deepEqual(primary.valuesByModeName.Light, {
    r: 0.40392157435417175,
    g: 0.3137255012989044,
    b: 0.6431372761726379,
    a: 1,
  });
  assert.deepEqual(primary.valuesByModeName.Dark, {
    r: 0.8156862854957581,
    g: 0.7372549176216125,
    b: 1,
    a: 1,
  });
});

test("loadKitVariables: the 13 hue themes + contrast tiers parse (audit-only, not asserted) — still present in valuesByModeName", () => {
  const { variables } = loadKitVariables(VARIABLES_PATH);
  const primary = variables.find((v) => v.name === "Schemes/Primary");
  for (const modeName of [
    "Light High Contrast",
    "Dark Medium Contrast",
    "Monochrome LT",
    "Pink DT",
    "Purple LT",
  ]) {
    assert.ok(modeName in primary.valuesByModeName, `expected audit-only mode "${modeName}" to be present`);
    assert.notEqual(primary.valuesByModeName[modeName], undefined);
  }
});

// -- alias resolution ------------------------------------------------------

test("loadKitVariables: a real aliased variable (Static/Title Large/Font) resolves to its terminal value across collections", () => {
  const { variables } = loadKitVariables(VARIABLES_PATH);
  const aliasVar = variables.find((v) => v.name === "Static/Title Large/Font");
  assert.ok(aliasVar, "Static/Title Large/Font must exist in the real dump");

  // Raw: this variable's only mode (Typescale collection's "Baseline") holds
  // a VARIABLE_ALIAS pointing at "Static/Font/Brand" (Font theme collection).
  assert.equal(aliasVar.aliasOf, "VariableID:55064:15503");

  // Terminal: Font/Brand's own Baseline-mode value is the literal string
  // "Roboto" — the alias chain must resolve THROUGH the cross-collection
  // mode-name match (Typescale "Baseline" -> Font theme "Baseline"), not
  // just return the raw {type:"VARIABLE_ALIAS", id} pointer.
  assert.equal(aliasVar.valuesByModeName.Baseline, "Roboto");

  const brand = variables.find((v) => v.id === "VariableID:55064:15503");
  assert.ok(brand);
  assert.equal(brand.name, "Static/Font/Brand");
  assert.equal(brand.aliasOf, undefined, "the terminal target is not itself an alias");
});

test("loadKitVariables: real dump — exactly 45 Static/* variables carry an aliasOf, all resolving to one of 5 distinct Font-theme targets, no dangling/cyclic chains", () => {
  const { variables } = loadKitVariables(VARIABLES_PATH);
  const byId = new Map(variables.map((v) => [v.id, v]));
  const aliasing = variables.filter((v) => v.aliasOf !== undefined);
  assert.equal(aliasing.length, 45);
  assert.ok(aliasing.every((v) => v.family === "Static"));

  const distinctTargets = new Set(aliasing.map((v) => v.aliasOf));
  assert.equal(distinctTargets.size, 5);
  for (const targetId of distinctTargets) {
    assert.ok(byId.has(targetId), `alias target ${targetId} must resolve to a real variable (no dangling alias)`);
    assert.equal(byId.get(targetId).aliasOf, undefined, "measured dump has no 2+-hop alias chains");
  }
});

test("normalizeVariables: cycle guard — a manufactured circular alias throws instead of infinite-looping", () => {
  const data = {
    collections: [
      {
        id: "coll:1",
        name: "Fake",
        defaultModeId: "mode:1",
        variableCount: 2,
        modes: [{ name: "Only", modeId: "mode:1" }],
      },
    ],
    variables: [
      {
        id: "var:a",
        name: "Fake/A",
        type: "STRING",
        collectionId: "coll:1",
        valuesByMode: { "mode:1": { type: "VARIABLE_ALIAS", id: "var:b" } },
        scopes: [],
        codeSyntax: {},
      },
      {
        id: "var:b",
        name: "Fake/B",
        type: "STRING",
        collectionId: "coll:1",
        valuesByMode: { "mode:1": { type: "VARIABLE_ALIAS", id: "var:a" } },
        scopes: [],
        codeSyntax: {},
      },
    ],
  };

  assert.throws(() => normalizeVariables(data), /alias cycle detected/);
});

test("normalizeVariables: a dangling alias (target id doesn't exist) resolves to undefined, not a throw", () => {
  const data = {
    collections: [
      {
        id: "coll:1",
        name: "Fake",
        defaultModeId: "mode:1",
        variableCount: 1,
        modes: [{ name: "Only", modeId: "mode:1" }],
      },
    ],
    variables: [
      {
        id: "var:a",
        name: "Fake/A",
        type: "STRING",
        collectionId: "coll:1",
        valuesByMode: { "mode:1": { type: "VARIABLE_ALIAS", id: "var:does-not-exist" } },
        scopes: [],
        codeSyntax: {},
      },
    ],
  };

  const [a] = normalizeVariables(data);
  assert.equal(a.valuesByModeName.Only, undefined);
  assert.equal(a.aliasOf, "var:does-not-exist");
});

// -- assertModesOfRecord: negative case ------------------------------------

test("assertModesOfRecord: throws when an in-scope variable is missing Dark", () => {
  const broken = [
    {
      id: "v1",
      name: "Schemes/Fake",
      family: "Schemes",
      collection: "M3",
      type: "COLOR",
      valuesByModeName: { Light: { r: 0, g: 0, b: 0, a: 1 } }, // Dark missing
      codeSyntax: {},
    },
  ];
  assert.throws(() => assertModesOfRecord(broken), /missing mode of record "Dark"/);
});

test("assertModesOfRecord: throws when Dark is present but unresolved (undefined)", () => {
  const broken = [
    {
      id: "v1",
      name: "Schemes/Fake",
      family: "Schemes",
      collection: "M3",
      type: "COLOR",
      valuesByModeName: { Light: { r: 0, g: 0, b: 0, a: 1 }, Dark: undefined },
      codeSyntax: {},
    },
  ];
  assert.throws(() => assertModesOfRecord(broken), /failed to resolve mode of record "Dark"/);
});

test("assertModesOfRecord: a variable whose collection has no Light/Dark at all (e.g. Corner) is out of scope, never throws", () => {
  const corner = [
    {
      id: "v1",
      name: "Corner/Small",
      family: "Corner",
      collection: "Shape",
      type: "FLOAT",
      valuesByModeName: { Baseline: 8 },
      codeSyntax: {},
    },
  ];
  assert.doesNotThrow(() => assertModesOfRecord(corner));
});

// -- text styles (D1 Step 4) -----------------------------------------------

test("loadKitTextStyles: real dump — 30 TEXT styles, tagged family 'style:text'", () => {
  const { styles } = loadKitTextStyles(STYLES_PATH);
  assert.equal(styles.length, 30);
  assert.ok(styles.every((s) => s.family === "style:text"));
  assert.ok(styles.every((s) => s.type === "TEXT"));
});

test("loadKitTextStyles: real dump — a known style (M3/display/large) carries its font family/style/size", () => {
  const { styles } = loadKitTextStyles(STYLES_PATH);
  const displayLarge = styles.find((s) => s.name === "M3/display/large");
  assert.ok(displayLarge);
  assert.deepEqual(displayLarge.valuesByModeName.Default, {
    fontFamily: "Roboto",
    fontStyle: "Regular",
    fontSize: 57,
  });
});

test("normalizeTextStyles: determinism — sorted by id, byte-stable across repeated calls", () => {
  const fixtureStyles = [
    { id: "S:b", name: "M3/body/large", fontName: { family: "Roboto", style: "Regular" }, fontSize: 16 },
    { id: "S:a", name: "M3/body/small", fontName: { family: "Roboto", style: "Regular" }, fontSize: 12 },
  ];
  const data = { paintStyles: [], effectStyles: [], textStyles: fixtureStyles };
  const first = JSON.stringify(normalizeTextStyles(data));
  const second = JSON.stringify(normalizeTextStyles(data));
  assert.equal(first, second);

  const [firstNormalized] = normalizeTextStyles(data);
  assert.equal(firstNormalized.id, "S:a", "sorted ordinally by id, not source-file order");
});

// -- combined loader ---------------------------------------------------------

test("loadKitTokens: combines variables + styles; typescale appears in BOTH Static/* variables and style:text styles (kept, not deduped)", () => {
  const { variables, styles, all } = loadKitTokens({ variablesPath: VARIABLES_PATH, stylesPath: STYLES_PATH });
  assert.equal(variables.length, 304);
  assert.equal(styles.length, 30);
  assert.equal(all.length, 334);

  const staticSize = variables.find((v) => v.name === "Static/Display Large/Size");
  const textStyle = styles.find((s) => s.name === "M3/display/large");
  assert.ok(staticSize, "Static/* variable side of typescale must be present");
  assert.ok(textStyle, "text-style side of typescale must be present");
  assert.equal(staticSize.valuesByModeName.Baseline, 57);
  assert.equal(textStyle.valuesByModeName.Default.fontSize, 57);
});

// -- schema validation (offline, malformed-input rejection) -----------------

test("loadKitVariables: schema rejects a dump missing required top-level key 'variables' instead of silently normalizing garbage", () => {
  const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "cem-figma-connect-tokens-test-"));
  try {
    const badPath = path.join(scratch, "bad-variables.json");
    fs.writeFileSync(badPath, JSON.stringify({ collections: [] }), "utf8");
    assert.throws(() => loadKitVariables(badPath), /Invalid kit-variables dump/);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("loadKitTextStyles: schema rejects a textStyles entry missing fontSize", () => {
  const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "cem-figma-connect-tokens-test-"));
  try {
    const badPath = path.join(scratch, "bad-styles.json");
    fs.writeFileSync(
      badPath,
      JSON.stringify({
        paintStyles: [],
        effectStyles: [],
        textStyles: [{ id: "S:x", name: "Broken", fontName: { family: "Roboto", style: "Regular" } }],
      }),
      "utf8"
    );
    assert.throws(() => loadKitTextStyles(badPath), /Invalid kit-styles dump/);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});
