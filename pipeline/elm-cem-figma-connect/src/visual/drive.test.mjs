// Task C2: the correspondence-driven state driver.
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test src/visual/drive.test.mjs

import { test } from "node:test";
import assert from "node:assert/strict";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadFigmaExport } from "../ingest/figma.mjs";
import { readCorrespondence, loadProfile, repoRoot as mergeRepoRoot } from "../correspond/merge.mjs";
import {
  buildDefaultState,
  driveState,
  findVariantNode,
  loadIconTable,
  toHarnessUrlParams,
} from "./drive.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");

const figmaExport = loadFigmaExport(path.join(repoRoot, "test", "fixtures", "figma-export.m3-kit.json"));
const correspondencePath = path.join(repoRoot, "profiles", "m3-kit", "correspondence.json");
const correspondence = readCorrespondence(correspondencePath);
const iconTable = loadIconTable(correspondencePath);

// The real, checked-in correspondence.json's confirmed m3e-button entry has
// NO record at all — in either props[] or slots[] — of "Trailing slot"/
// "Trailing icon", because those two SLOT properties only exist in
// test/fixtures/figma-export.m3-kit.json (added by Tasks 1 and 3 purely for
// matcher-level test coverage; the real m3-kit export never had them on
// Button). This test file deliberately drives the real button entry against
// that test fixture, so unlike the 8 real confirmed entries that DO carry a
// legacy `kind:"slot"` props[] item drive.mjs's coverage gate now tolerates
// (see drive.test.mjs's "migration tolerance" test below, exercised against
// real data with NO overlay), there is no legacy shape here to fall back to
// — the overlay below is standing in for a re-match this test intentionally
// never runs, not for a migration state. Field shapes/values mirror exactly
// what a real `proposeSlot`/`buildSlots` pass over this fixture produces
// (see test/matcher.test.mjs's "SLOT properties are routed to
// slotProposals" test), including provenance.
const rawButtonEntry = correspondence.find((e) => e.cemTag === "m3e-button");
assert.ok(rawButtonEntry, "fixture setup: profiles/m3-kit/correspondence.json must carry a confirmed m3e-button entry");
assert.equal(rawButtonEntry.status, "confirmed");
const buttonEntry = {
  ...rawButtonEntry,
  slots: [
    {
      figmaSlotName: "Trailing slot",
      kind: "slot",
      multi: false,
      unmapped: "no CEM slot matches Figma SLOT property 'Trailing slot'",
      provenance: "auto-gap",
    },
    { figmaSlotName: "Trailing icon", kind: "slot", multi: false, mappedTo: "trailing-icon", provenance: "auto-exact" },
  ],
};

// -- the reference scenario: filled/medium/round -----------------------------
//
// Starts from the Figma-measured default state (Step 2's rule: TEXT/BOOLEAN/
// INSTANCE_SWAP defaults come from componentPropertyDefinitions) on the bare
// 'Button' set (figmaSets[0], fixedAttrs.variant="filled"), then overrides
// Size to Medium to land on a concrete measured fixture node
// ("Type=Round, Size=Medium, State=Enabled" = 57994:2322) — Type's default
// (Round) and the pinned-default State (Enabled) are left alone.
function filledMediumRoundState() {
  const state = buildDefaultState(buttonEntry, figmaExport);
  assert.deepEqual(state.axisValues, { Type: "Round", Size: "Small", State: "Enabled" });
  assert.deepEqual(state.propValues, {
    "Label text": "Label",
    "Show icon": true,
    Icon: "54616:25409",
    "Show focus indicator": false,
  });
  state.axisValues = { ...state.axisValues, Size: "Medium" };
  return state;
}

test("default (filled/medium/round) state drives every axis + componentProperty and resolves the exact measured node", () => {
  const state = filledMediumRoundState();
  const { harnessParams, figmaNodeQuery } = driveState(buttonEntry, figmaExport, state, iconTable);

  assert.deepEqual(harnessParams, {
    tag: "m3e-button",
    attrs: { shape: "rounded", size: "medium", variant: "filled" },
    text: "Label",
    slots: { icon: "m3e-icon:stars!filled" }, // Icon default (54616:25409) -> iconTable symbolName "stars" + FILL axis
  });

  assert.deepEqual(toHarnessUrlParams(harnessParams), {
    tag: "m3e-button",
    "attr.shape": "rounded",
    "attr.size": "medium",
    "attr.variant": "filled",
    text: "Label",
    "slot.icon": "m3e-icon:stars!filled",
  });

  assert.deepEqual(figmaNodeQuery, {
    setNodeId: "57994:2227",
    nodeId: "57994:2322", // MEASURED, from test/fixtures/figma-export.m3-kit.json
    name: "Type=Round, Size=Medium, State=Enabled",
    tier: "exact",
  });
});

test("non-default Show icon=false suppresses the icon on the CODE side (harnessParams); the Figma variant node is unaffected — see scope note in drive.mjs", () => {
  const state = filledMediumRoundState();
  state.propValues = { ...state.propValues, "Show icon": false };
  const { harnessParams } = driveState(buttonEntry, figmaExport, state, iconTable);
  assert.deepEqual(harnessParams.slots, {});
});

test("a fused sibling set ('Button - tonal') contributes its fixed variant from the set binding, not an axis", () => {
  const tonalSet = buttonEntry.figmaSets.find((s) => s.setName === "Button - tonal");
  assert.ok(tonalSet);
  assert.equal(tonalSet.fixedAttrs.variant, "tonal");

  const state = {
    setNodeId: tonalSet.nodeId,
    axisValues: { Type: "Round", Size: "Medium", State: "Enabled" },
    propValues: {
      "Label text": "Label",
      "Show icon": true,
      Icon: "54616:25409",
      "Show focus indicator": false,
    },
  };
  const { harnessParams, figmaNodeQuery } = driveState(buttonEntry, figmaExport, state, iconTable);

  assert.equal(harnessParams.attrs.variant, "tonal");
  assert.equal(harnessParams.attrs.shape, "rounded");
  assert.equal(harnessParams.attrs.size, "medium");
  assert.deepEqual(figmaNodeQuery, {
    setNodeId: tonalSet.nodeId,
    nodeId: "57994:2302", // MEASURED sibling under 'Button - tonal'
    name: "Type=Round, Size=Medium, State=Enabled",
    tier: "exact",
  });
});

test("an unmapped-but-unmarked Figma axis throws (silent unmapped axis is a correspondence bug)", () => {
  const brokenEntry = {
    ...buttonEntry,
    axes: buttonEntry.axes.filter((a) => a.figmaProp !== "State"), // drop State entirely
  };
  const state = filledMediumRoundState();
  assert.throws(
    () => driveState(brokenEntry, figmaExport, state, iconTable),
    /figma VARIANT axis 'State'.*not present in correspondence axes/
  );
});

test("an unmapped-but-unmarked componentProperty throws too (same silent-drop bug, prop side)", () => {
  const brokenEntry = {
    ...buttonEntry,
    props: buttonEntry.props.filter((p) => p.figmaProp !== "Show focus indicator"),
  };
  const state = filledMediumRoundState();
  assert.throws(
    () => driveState(brokenEntry, figmaExport, state, iconTable),
    /figma property 'Show focus indicator'.*not present in correspondence props/
  );
});

test("a mistyped state.axisValues key throws instead of silently falling back to the default (never-silent, C2b)", () => {
  const state = filledMediumRoundState();
  state.axisValues = { ...state.axisValues, Sizee: "Medium" }; // typo: 'Sizee', not 'Size'
  assert.throws(
    () => driveState(buttonEntry, figmaExport, state, iconTable),
    /state\.axisValues key 'Sizee'.*not a known Figma VARIANT axis/
  );
});

test("a mistyped state.propValues key throws instead of silently falling back to the default (never-silent, C2b)", () => {
  const state = filledMediumRoundState();
  state.propValues = { ...state.propValues, "Show Icon": true }; // typo: wrong case vs 'Show icon'
  assert.throws(
    () => driveState(buttonEntry, figmaExport, state, iconTable),
    /state\.propValues key 'Show Icon'.*not a known Figma componentProperty/
  );
});

test("definitionsFor throws when no sibling in the fusion group captured setProperties in this export", () => {
  // Synthetic: every figmaSet points at a nodeId with no setProperties entry
  // in the fixture export at all, simulating an export where none of the
  // fusion group's siblings captured their properties (drive.mjs:142-145).
  const brokenEntry = {
    ...buttonEntry,
    figmaSets: buttonEntry.figmaSets.map((s) => ({ ...s, nodeId: "99999:9999" })),
  };
  assert.throws(
    () => buildDefaultState(brokenEntry, figmaExport),
    /has no figmaSet with captured setProperties in this export/
  );
});

test("figmaNodeQuery's fuzzy tier tolerates a kit typo ('State=Presssed') via normalize.mjs's valueMatch", () => {
  // Measured: 'Button - outline' (58650:10213) has a real kit typo at
  // components[675], id 58650:10582, name 'Type=Square, Size=XLarge,
  // State=Presssed'. Querying the CORRECT spelling must still resolve it.
  const resolved = findVariantNode(figmaExport, "58650:10213", {
    Type: "Square",
    Size: "XLarge",
    State: "Pressed",
  });
  assert.deepEqual(resolved, {
    setNodeId: "58650:10213",
    nodeId: "58650:10582",
    name: "Type=Square, Size=XLarge, State=Presssed",
    tier: "fuzzy",
  });
});

test("figmaNodeQuery's exact tier is preferred over fuzzy when a correctly-spelled node exists", () => {
  const resolved = findVariantNode(figmaExport, "57994:2227", {
    Type: "Round",
    Size: "Medium",
    State: "Enabled",
  });
  assert.equal(resolved.tier, "exact");
  assert.equal(resolved.nodeId, "57994:2322");
});

// -- RC2 chip Configuration→slot-visibility -----------------------------------
//
// Chips have NO `Show icon` boolean prop; icon presence is driven by the
// `Configuration` VARIANT axis (unmapped; pinned to its Figma default). A
// prop with `visibilityAxis`/`visibleWhen` must only inject its slot when
// the named axis's current value (driven or defaulted) is in `visibleWhen`.
//
// The tests use a synthetic chip-like entry and a minimal synthetic
// figmaExport carrying just the setProperties and two variant nodes —
// one for each Configuration value — so they don't depend on the live dump.

// Synthetic icon in the iconTable (local_taxi, id "54616:25441") — the
// same node-id the real filter-chip Leading icon default points at.
const CHIP_ICON_TABLE = [
  { figmaNodeId: "54616:25441", figmaName: "local_taxi", symbolName: "local_taxi", filled: false },
];

// Minimal synthetic figmaExport for a chip-like set ("TEST:1"):
//   - setProperties: Configuration VARIANT (default "Label only") + Leading
//     icon INSTANCE_SWAP + Label text TEXT
//   - Two variant COMPONENTs: Configuration=Label only and
//     Configuration=Label & leading icon, both State=Enabled
function makeSyntheticChipExport({ configDefault = "Label only" } = {}) {
  // NOTE: non-VARIANT prop names must use real Figma nodeId suffix format
  // ("name#digits:digits") so displayNameOf() in drive.mjs's definitionsFor()
  // correctly strips the suffix. A non-digit suffix (e.g. "#TEST:99") is
  // treated by displayNameOf as a literal '#' in the display name.
  return {
    data: {
      setProperties: {
        "99001:1": [
          { name: "Leading icon#99001:99", type: "INSTANCE_SWAP", defaultValue: "54616:25441" },
          { name: "Label text#99001:98", type: "TEXT", defaultValue: "Label" },
          { name: "Configuration", type: "VARIANT", defaultValue: configDefault, variantOptions: ["Label only", "Label & leading icon"] },
          { name: "State", type: "VARIANT", defaultValue: "Enabled", variantOptions: ["Enabled", "Disabled"] },
        ],
      },
      components: [
        { id: "99001:1", name: "Synthetic chip", type: "COMPONENT_SET" },
        { id: "99001:2", name: "Configuration=Label only, State=Enabled", type: "COMPONENT" },
        { id: "99001:3", name: "Configuration=Label & leading icon, State=Enabled", type: "COMPONENT" },
      ],
    },
  };
}

// Synthetic chip entry mirroring the correspondence.json shape for a chip
// with a `visibilityAxis`-annotated Leading icon prop.
const syntheticChipEntry = {
  cemTag: "m3e-test-chip",
  matcherKind: "set",
  figmaSets: [{ nodeId: "99001:1", setName: "Synthetic chip", fixedAttrs: {} }],
  axes: [
    {
      figmaProp: "Configuration",
      unmapped: "no CEM enum attribute shares its value set (options: Label only, Label & leading icon)",
    },
    {
      figmaProp: "State",
      unmapped: "no CEM enum attribute shares its value set (options: Enabled, Disabled)",
    },
  ],
  props: [
    {
      figmaProp: "Leading icon",
      kind: "instanceSwap",
      binding: "slot:icon",
      visibilityAxis: "Configuration",
      visibleWhen: ["Label & leading icon"],
    },
    { figmaProp: "Label text", kind: "text", binding: "content" },
  ],
  provenance: "human",
  status: "proposed",
};

test("RC2 chip Configuration→slot-visibility: default Configuration='Label only' omits the icon slot", () => {
  // Default Configuration is "Label only" → visibilityAxis not in visibleWhen → no icon.
  const chipExport = makeSyntheticChipExport({ configDefault: "Label only" });
  const state = buildDefaultState(syntheticChipEntry, chipExport);
  assert.deepEqual(state.axisValues, { Configuration: "Label only", State: "Enabled" });

  const { harnessParams } = driveState(syntheticChipEntry, chipExport, state, CHIP_ICON_TABLE);
  assert.deepEqual(harnessParams.slots, {}, "icon slot must be absent when Configuration='Label only'");
  assert.equal(harnessParams.text, "Label");
});

test("RC2 chip Configuration→slot-visibility: Configuration='Label & leading icon' injects the icon slot", () => {
  // Change the Figma default to "Label & leading icon" → visibilityAxis IS in visibleWhen → icon shown.
  const chipExport = makeSyntheticChipExport({ configDefault: "Label & leading icon" });
  const state = buildDefaultState(syntheticChipEntry, chipExport);
  assert.deepEqual(state.axisValues, { Configuration: "Label & leading icon", State: "Enabled" });

  const { harnessParams } = driveState(syntheticChipEntry, chipExport, state, CHIP_ICON_TABLE);
  assert.deepEqual(harnessParams.slots, { icon: "m3e-icon:local_taxi" }, "icon slot must be present when Configuration='Label & leading icon'");
});

// -- fixedAttrs pins an UNMAPPED Figma axis (avatar Style, m3e-avatar) --------
//
// m3e-avatar's `Style` axis is unmapped (no CEM attr). The code (Letter text)
// renders a MONOGRAM. Without a pin, driveState defaults to the Figma axis's
// defaultValue ("Avatar", node 50731:13713 — person icon). With
// fixedAttrs:{Style:"Monogram"} on figmaSets[0], the Figma query is redirected
// to the Monogram variant (50731:13717), so both sides compare the same thing.
//
// The real figma-export.m3-kit.json fixture has no setProperties for
// 50731:13725 (the avatar set's properties weren't captured), so this test
// uses a synthetic export that mirrors the avatar's known axis/prop shape.
function makeAvatarExport() {
  return {
    data: {
      setProperties: {
        "50731:13725": [
          { name: "Style", type: "VARIANT", defaultValue: "Avatar", variantOptions: ["Avatar", "Monogram", "Check"] },
          { name: "Letter#50731:11111", type: "TEXT", defaultValue: "A" },
        ],
      },
      components: [
        { id: "50731:13725", name: "Generic avatar", type: "COMPONENT_SET" },
        { id: "50731:13713", name: "Style=Avatar", type: "COMPONENT" },
        { id: "50731:13717", name: "Style=Monogram", type: "COMPONENT" },
        { id: "50731:13723", name: "Style=Check", type: "COMPONENT" },
      ],
    },
  };
}

const avatarEntry = {
  cemTag: "m3e-avatar",
  matcherKind: "contains",
  figmaSets: [{ nodeId: "50731:13725", setName: "Generic avatar", fixedAttrs: {} }],
  axes: [
    { figmaProp: "Style", unmapped: "no CEM enum attribute shares its value set (options: Check, Monogram, Avatar)" },
  ],
  props: [
    { figmaProp: "Letter", kind: "text", binding: "content" },
  ],
  provenance: "auto-contains",
  status: "proposed",
};

test("fixedAttrs:{Style:'Monogram'} pins the UNMAPPED Style axis to the Monogram variant node (50731:13717), not the person-icon default (50731:13713)", () => {
  const avatarExport = makeAvatarExport();

  // NEGATIVE: WITHOUT the pin, the default axis value ('Avatar') selects the person-icon node.
  const entryNoPIN = {
    ...avatarEntry,
    figmaSets: [{ ...avatarEntry.figmaSets[0], fixedAttrs: {} }],
  };
  const stateNoPIN = buildDefaultState(entryNoPIN, avatarExport);
  const { figmaNodeQuery: noPinQuery } = driveState(entryNoPIN, avatarExport, stateNoPIN);
  assert.equal(noPinQuery.nodeId, "50731:13713", "without pin: default Style=Avatar maps to person-icon node");

  // POSITIVE: WITH fixedAttrs:{Style:"Monogram"}, the query resolves the monogram node.
  const entryPinned = {
    ...avatarEntry,
    figmaSets: [{ ...avatarEntry.figmaSets[0], fixedAttrs: { Style: "Monogram" } }],
  };
  const statePinned = buildDefaultState(entryPinned, avatarExport);
  // buildDefaultState must have overlaid the fixedAttrs pin into axisValues.
  assert.equal(statePinned.axisValues.Style, "Monogram", "buildDefaultState overlays fixedAttrs pin onto axisValues");
  const { figmaNodeQuery: pinnedQuery } = driveState(entryPinned, avatarExport, statePinned);
  assert.equal(pinnedQuery.nodeId, "50731:13717", "with pin: Style=Monogram selects the monogram variant node");
});

test("RC2 chip Configuration→slot-visibility: instanceSwap with no iconTable entry is silently skipped (assist-chip branded icon path)", () => {
  // An instanceSwap whose default value is NOT in the iconTable (brand logo,
  // not a Material Symbol) must be silently skipped — no throw, no slot content.
  // This is the assist-chip "Label & brand icon" scenario: the visibility gate
  // PASSES (the prop IS visible for that Configuration value), but the brand
  // logo node-id has no iconTable entry, so drive.mjs gracefully omits the slot.
  const brandIconExport = {
    data: {
      setProperties: {
        "99002:1": [
          // Default value "BRAND:9999" is NOT in CHIP_ICON_TABLE (simulates brand logo)
          { name: "Branded icon#99002:99", type: "INSTANCE_SWAP", defaultValue: "BRAND:9999" },
          { name: "Label text#99002:98", type: "TEXT", defaultValue: "Label" },
          { name: "Configuration", type: "VARIANT", defaultValue: "Label & brand icon", variantOptions: ["Label only", "Label & brand icon"] },
          { name: "State", type: "VARIANT", defaultValue: "Enabled", variantOptions: ["Enabled", "Disabled"] },
        ],
      },
      components: [
        { id: "99002:1", name: "Synthetic assist chip", type: "COMPONENT_SET" },
        { id: "99002:2", name: "Configuration=Label only, State=Enabled", type: "COMPONENT" },
        { id: "99002:3", name: "Configuration=Label & brand icon, State=Enabled", type: "COMPONENT" },
      ],
    },
  };
  const brandEntry = {
    cemTag: "m3e-assist-chip-test",
    matcherKind: "set",
    figmaSets: [{ nodeId: "99002:1", setName: "Synthetic assist chip", fixedAttrs: {} }],
    axes: [
      { figmaProp: "Configuration", unmapped: "no CEM enum attribute shares its value set" },
      { figmaProp: "State", unmapped: "no CEM enum attribute shares its value set" },
    ],
    props: [
      {
        figmaProp: "Branded icon",
        kind: "instanceSwap",
        binding: "slot:icon",
        visibilityAxis: "Configuration",
        // visibleWhen passes for "Label & brand icon" — so drive.mjs proceeds
        // to the iconTable lookup and finds no entry → silently skips.
        visibleWhen: ["Label & brand icon"],
      },
      { figmaProp: "Label text", kind: "text", binding: "content" },
    ],
    provenance: "human",
    status: "proposed",
  };

  const state = buildDefaultState(brandEntry, brandIconExport);
  assert.deepEqual(state.axisValues, { Configuration: "Label & brand icon", State: "Enabled" });

  // Must not throw — the iconTable miss is silently skipped, slot stays absent.
  const { harnessParams } = driveState(brandEntry, brandIconExport, state, CHIP_ICON_TABLE);
  assert.deepEqual(harnessParams.slots, {}, "slot absent when iconTable entry is missing (brand logo)");
  assert.equal(harnessParams.text, "Label");
});

// -- Task 3 migration tolerance: real, un-re-matched confirmed entries ------
//
// 8 real confirmed entries in the checked-in profiles/m3-kit correspondence
// still cover their real SLOT property the OLD way — a legacy `kind:"slot"`
// item inside props[] — because nothing has re-run match/review/confirm on
// them since the slots[] relocation shipped (that's a human action, out of
// this task's remit). assertFullyMapped's SLOT coverage gate must accept
// that legacy shape as valid coverage, not just entry.slots[], or every one
// of these real entries would fail to drive at all. This exercises the REAL
// m3-kit export + REAL correspondence.json (no synthetic/overlaid fixture)
// to prove the production data actually drives cleanly, not just a
// hand-crafted test double.
test("migration tolerance: a real confirmed entry whose SLOT property is still covered via legacy props[] (not yet re-matched into slots[]) drives cleanly", () => {
  const profileDir = path.join(mergeRepoRoot, "profiles", "m3-kit");
  const profile = loadProfile(profileDir);
  const realFigmaExport = loadFigmaExport(profile.figmaExportPath);
  const realCorrespondencePath = path.join(profileDir, "correspondence.json");
  const realCorrespondence = readCorrespondence(realCorrespondencePath);
  const realIconTable = loadIconTable(realCorrespondencePath);

  const dialog = realCorrespondence.find((e) => e.cemTag === "m3e-dialog");
  assert.ok(dialog, "fixture setup: m3e-dialog must be present in the real correspondence.json");
  assert.equal(dialog.status, "confirmed");
  assert.equal(dialog.slots, undefined, "pre-migration: m3e-dialog has no slots[] yet");
  assert.ok(
    dialog.props.some((p) => p.kind === "slot" && p.figmaProp === "Content" && p.unmapped),
    "pre-migration: m3e-dialog's real SLOT property is still a legacy kind:'slot' item inside props[]"
  );

  const state = buildDefaultState(dialog, realFigmaExport);
  assert.doesNotThrow(() => driveState(dialog, realFigmaExport, state, realIconTable));
});
