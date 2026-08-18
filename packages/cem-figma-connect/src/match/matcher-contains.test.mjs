import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

import { loadCem } from "../ingest/cem.mjs";
import { loadFigmaExport } from "../ingest/figma.mjs";
import { match, proposeAxis, loadMatcherConfig } from "./matcher.mjs";

// The m3-kit profile's own calibration (finding 2.4) — these tests exercise
// the real m3-kit fixture, so they use the same matcher.json a real `match`
// run would load, not a synthetic stand-in.
const m3KitMatcherConfig = loadMatcherConfig(path.join(process.cwd(), "profiles/m3-kit"));

function realMatch() {
  const prof = JSON.parse(fs.readFileSync(path.join(process.cwd(), "profiles/m3-kit/profile.json"), "utf8"));
  const cem = loadCem(path.resolve(process.cwd(), prof.cem.manifestPath), { log: () => {} });
  const figma = loadFigmaExport(path.resolve(process.cwd(), prof.figmaExportPath));
  return match(cem, figma, m3KitMatcherConfig);
}

test("contains tier: the clean qualifier components bind at tier:contains", () => {
  const { candidates } = realMatch();
  const byTag = (t) => candidates.filter((c) => c.cemTag === t);
  // m3e-radio is NOT in this list: in the m3-kit fixture the only radio set is
  // "Radio buttons" whose slug head-noun is "button" (not "radio"), so it is
  // correctly bound to m3e-button — not a contains-tier radio bind.
  for (const tag of ["m3e-avatar", "m3e-tooltip", "m3e-button-group", "m3e-card",
                      "m3e-circular-progress-indicator", "m3e-linear-progress-indicator"]) {
    const hits = byTag(tag);
    assert.ok(hits.length >= 1, `${tag} should be matched`);
    assert.ok(hits.some((c) => c.tier === "contains"), `${tag} should bind at tier:contains`);
  }
});

test("contains tier does NOT let m3e-chip grab the exact-matched specific chips", () => {
  const { candidates } = realMatch();
  // m3e-filter-chip, m3e-input-chip, m3e-suggestion-chip have Figma sets with
  // exact slug matches, so they stay at tier:exact. m3e-assist-chip's Figma
  // counterpart is "Assistive chip" (no exact slug match) → always tier:fuzzy.
  // None of them are absorbed into a contains group for a generic m3e-chip.
  for (const specific of ["m3e-filter-chip", "m3e-input-chip", "m3e-suggestion-chip"]) {
    const hit = candidates.find((c) => c.cemTag === specific);
    assert.ok(hit && hit.tier === "exact", `${specific} stays exact`);
  }
  const assistChip = candidates.find((c) => c.cemTag === "m3e-assist-chip");
  assert.ok(assistChip && assistChip.tier === "fuzzy", "m3e-assist-chip stays fuzzy (Assistive chip slugs differently)");
});

test("un-resolvable structural variants stay gaps (List dialog / Range slider)", () => {
  const { candidates } = realMatch();
  const listDialog = candidates.find((c) => c.figmaName === "List dialog");
  const rangeSlider = candidates.find((c) => c.figmaName === "Range slider");
  assert.ok(!listDialog || listDialog.tier === "gap", "List dialog not bound");
  assert.ok(!rangeSlider || rangeSlider.tier === "gap", "Range slider not bound");
});

// -- proposeAxis unit tests ---------------------------------------------------

const BUTTON_CEM = {
  tag: "m3e-button",
  attributes: [
    { name: "variant", kind: "enum", values: ["filled", "outlined", "text", "elevated", "tonal"] },
    { name: "size", kind: "enum", values: ["extra-small", "small", "medium", "large", "extra-large"] },
  ],
  slots: [],
};

test("proposeAxis: maps a size axis with synonym values", () => {
  const axis = { name: "Size", options: ["XSmall", "Small", "Medium", "Large", "XLarge"] };
  const result = proposeAxis(axis, BUTTON_CEM, m3KitMatcherConfig);
  assert.equal(result.mapped, true);
  assert.equal(result.attribute, "size");
  assert.equal(result.coverage, "5/5");
  const map = Object.fromEntries(result.valueMap.map((v) => [v.figma, v.cem]));
  assert.equal(map.XSmall, "extra-small");
  assert.equal(map.XLarge, "extra-large");
});

test("proposeAxis: returns mapped:false when no attribute covers the axis", () => {
  const axis = { name: "State", options: ["Default", "Hovered", "Focused", "Pressed", "Disabled"] };
  const result = proposeAxis(axis, BUTTON_CEM, m3KitMatcherConfig);
  assert.equal(result.mapped, false);
  assert.match(result.reason, /no CEM enum attribute/);
});

test("proposeAxis: maps a boolean axis by name-affinity (Modal on/off)", () => {
  const cem = {
    tag: "m3e-dialog",
    attributes: [{ name: "modal", kind: "boolean" }],
    slots: [],
  };
  const axis = { name: "Modal", options: ["True", "False"] };
  const result = proposeAxis(axis, cem, m3KitMatcherConfig);
  assert.equal(result.mapped, true);
  assert.equal(result.attribute, "modal");
  assert.equal(result.attributeKind, "boolean");
});

test("proposeAxis: maps a multi-boolean axis (checkbox Type -> checked+indeterminate)", () => {
  const cem = {
    tag: "m3e-checkbox",
    attributes: [
      { name: "checked", kind: "boolean" },
      { name: "indeterminate", kind: "boolean" },
    ],
    slots: [],
  };
  const axis = { name: "Type", options: ["Selected", "Unselected", "Indeterminate"] };
  const result = proposeAxis(axis, cem, m3KitMatcherConfig);
  assert.equal(result.mapped, true);
  assert.equal(result.kind, "multi-boolean");
  assert.ok(Array.isArray(result.attrs));
  assert.equal(result.attrs.length, 2);
  const attrNames = result.attrs.map((a) => a.attr).sort();
  assert.deepEqual(attrNames, ["checked", "indeterminate"]);
});

// -- match() integration tests -----------------------------------------------

const MINIMAL_CEM = {
  components: [
    {
      tag: "m3e-button",
      description: "A button component. m3.material.io/components/buttons/overview",
      attributes: [
        { name: "variant", kind: "enum", values: ["filled", "outlined", "text", "elevated", "tonal"] },
        { name: "size", kind: "enum", values: ["extra-small", "small", "medium", "large", "extra-large"] },
      ],
      slots: [{ name: "icon" }],
    },
    {
      tag: "m3e-badge",
      description: "A badge component. m3.material.io/components/badges/overview",
      attributes: [],
      slots: [],
    },
  ],
};

const MINIMAL_FIGMA = {
  sets: [
    {
      id: "1:1",
      name: "Button",
      page: "Components",
      description: "A button. m3.material.io/components/buttons/overview",
      properties: [
        { displayName: "Size", type: "VARIANT", variantOptions: ["XSmall", "Small", "Medium", "Large", "XLarge"] },
        { displayName: "Label text", type: "TEXT", defaultValue: "Label" },
      ],
    },
    {
      id: "2:1",
      name: "Button - outlined",
      page: "Components",
      description: "",
      properties: [
        { displayName: "Size", type: "VARIANT", variantOptions: ["XSmall", "Small", "Medium", "Large", "XLarge"] },
      ],
    },
    {
      id: "2:2",
      name: "Button - tonal",
      page: "Components",
      description: "",
      properties: [
        { displayName: "Size", type: "VARIANT", variantOptions: ["XSmall", "Small", "Medium", "Large", "XLarge"] },
      ],
    },
  ],
  standalones: [],
};

test("match: exact tier — normalized name match gives tier:exact, score:1", () => {
  // Button (id 1:1) matches exactly; the fusion siblings are subsets of that
  // set by id. In this minimal fixture there's no fusion (not enough siblings
  // sharing the exact name convention), so we get a singleton set exact match.
  const { candidates } = match(MINIMAL_CEM, MINIMAL_FIGMA, m3KitMatcherConfig);
  const btn = candidates.find((c) => c.figmaName === "Button" && c.tier === "exact");
  assert.ok(btn, "Button should match at exact tier");
  assert.equal(btn.cemTag, "m3e-button");
  assert.equal(btn.tier, "exact");
  assert.equal(btn.score, 1);
});

test("match: gap — no CEM counterpart emits tier:gap with cemTag:null", () => {
  const cem = { components: [] };
  const figma = {
    sets: [{ id: "9:9", name: "Totally Novel Widget", page: "Components", description: "", properties: [] }],
    standalones: [],
  };
  const { candidates } = match(cem, figma, m3KitMatcherConfig);
  assert.equal(candidates.length, 1);
  assert.equal(candidates[0].tier, "gap");
  assert.equal(candidates[0].cemTag, null);
});

test("match: fuzzy tier — Assistive chip -> m3e-assist-chip above threshold", () => {
  const cem = {
    components: [
      {
        tag: "m3e-assist-chip",
        description: "assist chip m3.material.io/components/chips/overview",
        attributes: [],
        slots: [],
      },
    ],
  };
  const figma = {
    sets: [
      {
        id: "3:1",
        name: "Assistive chip",
        page: "Components",
        description: "assist chip m3.material.io/components/chips/overview",
        properties: [],
      },
    ],
    standalones: [],
  };
  const { candidates } = match(cem, figma, m3KitMatcherConfig);
  assert.equal(candidates[0].tier, "fuzzy");
  assert.equal(candidates[0].cemTag, "m3e-assist-chip");
  assert.ok(candidates[0].score >= 0.5);
});

test("match: output is sorted — exact before fuzzy before gap", () => {
  const { candidates } = match(MINIMAL_CEM, MINIMAL_FIGMA, m3KitMatcherConfig);
  const tierRank = { exact: 0, fuzzy: 1, contains: 0.5, gap: 2 };
  // Allow 'contains' between exact and fuzzy.
  for (let i = 1; i < candidates.length; i++) {
    const prev = tierRank[candidates[i - 1].tier] ?? 3;
    const curr = tierRank[candidates[i].tier] ?? 3;
    assert.ok(prev <= curr, `tier order violated at index ${i}: ${candidates[i - 1].tier} > ${candidates[i].tier}`);
  }
});

test("match: result carries axis/property proposals for exact-matched set", () => {
  const { candidates } = match(MINIMAL_CEM, MINIMAL_FIGMA, m3KitMatcherConfig);
  const btn = candidates.find((c) => c.cemTag === "m3e-button" && c.tier === "exact");
  assert.ok(btn, "m3e-button exact candidate should exist");
  assert.ok(Array.isArray(btn.axisProposals), "axisProposals should be an array");
  const size = btn.axisProposals?.find((a) => a.axis === "Size");
  assert.ok(size, "Size axis proposal should exist");
  assert.equal(size.mapped, true);
  assert.equal(size.attribute, "size");
});
