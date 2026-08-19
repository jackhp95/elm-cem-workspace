// Task C5: the sampling policy.
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test src/visual/sample.test.mjs

import { test } from "node:test";
import assert from "node:assert/strict";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadFigmaExport } from "../ingest/figma.mjs";
import { readCorrespondence } from "../correspond/merge.mjs";
import { driveState, loadIconTable } from "./drive.mjs";
import { sampleDefault, sampleAudit, auditIconSpotCheck, assertNonGoalExclusions } from "./sample.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");

const figmaExport = loadFigmaExport(path.join(repoRoot, "test", "fixtures", "figma-export.m3-kit.json"));
const correspondencePath = path.join(repoRoot, "profiles", "m3-kit", "correspondence.json");
const correspondence = readCorrespondence(correspondencePath);
const iconTable = loadIconTable(correspondencePath);

// The real, checked-in correspondence.json's confirmed m3e-button entry
// predates SLOT support and carries no slots[] (real m3-kit export has no
// SLOT-typed props on Button). This test file, however, deliberately drives
// that same entry against test/fixtures/figma-export.m3-kit.json — which
// DOES carry two SLOT props on button's bare set (57994:2227): "Trailing
// slot" (Task 1's original fixture addition, no CEM counterpart) and
// "Trailing icon" (Task 3's fixture addition, exact-matches m3e-button's
// real "trailing-icon" CEM slot). Overlay the slots[] a real re-match
// against that fixture would produce, so drive.mjs's "never silent"
// coverage gate (task 3) has something to check against — without touching
// the real correspondence.json, which stays byte-identical on disk.
const rawButtonEntry = correspondence.find((e) => e.cemTag === "m3e-button");
assert.ok(rawButtonEntry, "fixture setup: profiles/m3-kit/correspondence.json must carry a confirmed m3e-button entry");
const buttonEntry = {
  ...rawButtonEntry,
  slots: [
    { figmaSlotName: "Trailing slot", kind: "slot", multi: false, unmapped: "no CEM slot matches Figma SLOT property 'Trailing slot'" },
    { figmaSlotName: "Trailing icon", kind: "slot", multi: false, mappedTo: "trailing-icon" },
  ],
};

const iconEntry = correspondence.find((e) => e.kind === "iconTable");
assert.ok(iconEntry, "fixture setup: profiles/m3-kit/correspondence.json must carry the kind:iconTable entry");

// -- Step 1 + the ⚑ reconciliation: measured button count = 10, not ≈11 -----

test("default sample on the button fixture yields exactly the reconciled 10 axis/set states (icon-off ABSENT)", () => {
  const states = sampleDefault(buttonEntry, figmaExport);

  const stateIds = states.map((s) => s.stateId);
  assert.deepEqual(
    stateIds,
    [
      "default",
      "axis-size-large",
      "axis-size-medium",
      "axis-size-xlarge",
      "axis-size-xsmall",
      "axis-type-square",
      "set-button-text",
      "set-button-elevated",
      "set-button-outline",
      "set-button-tonal",
    ],
    "measured button count is 10 (1 default + 4 sizes + 1 shape + 4 sibling sets) — " +
      "NOT the brief's ≈11, which double-counted an ungateable 'icon off' state (see sample.mjs docstring)"
  );
  assert.equal(states.length, 10);

  // No stateId anywhere encodes a componentProperty variation (icon/label/
  // focus-indicator) — the reconciliation's central assertion.
  for (const id of stateIds) {
    assert.ok(!/icon|label|focus/i.test(id), `stateId '${id}' looks like a componentProperty state, not axis/set`);
  }
});

test("the all-defaults state matches drive.mjs's own measured default exactly, and every propValues entry across the sample stays at the Figma-measured default (no non-default componentProperty state emitted)", () => {
  const states = sampleDefault(buttonEntry, figmaExport);
  const expectedDefaultProps = {
    "Label text": "Label",
    "Show icon": true,
    Icon: "54616:25409",
    "Show focus indicator": false,
  };

  const defaultEntry = states.find((s) => s.stateId === "default");
  assert.deepEqual(defaultEntry.state, {
    setNodeId: "57994:2227",
    axisValues: { Type: "Round", Size: "Small", State: "Enabled" },
    propValues: expectedDefaultProps,
  });

  for (const { state } of states) {
    assert.deepEqual(state.propValues, expectedDefaultProps);
  }
});

test("each axis variation pins every other axis at its default and varies exactly one non-default value", () => {
  const states = sampleDefault(buttonEntry, figmaExport);

  const sizeVariations = states.filter((s) => s.stateId.startsWith("axis-size-"));
  assert.equal(sizeVariations.length, 4, "Size has 5 values (XSmall/Small/Medium/Large/XLarge); default is Small");
  for (const { state } of sizeVariations) {
    assert.equal(state.axisValues.Type, "Round", "Type stays at its default while Size varies");
    assert.notEqual(state.axisValues.Size, "Small");
  }

  const typeVariations = states.filter((s) => s.stateId.startsWith("axis-type-"));
  assert.equal(typeVariations.length, 1, "Type has 2 values (Round/Square); default is Round");
  assert.equal(typeVariations[0].state.axisValues.Size, "Small", "Size stays at its default while Type varies");
  assert.equal(typeVariations[0].state.axisValues.Type, "Square");
});

test("each sibling figmaSet contributes one state at ITS OWN setNodeId, with axisValues/propValues at the shared fusion-group default", () => {
  const states = sampleDefault(buttonEntry, figmaExport);
  const siblingStates = states.filter((s) => s.stateId.startsWith("set-"));
  assert.equal(siblingStates.length, 4);

  // Only the primary axis-grid sets are sampled; appended representative-example
  // 2nd-sets (slugSuffix/example) are excluded from the visual gate (see sample.mjs).
  const expectedSetNodeIds = buttonEntry.figmaSets
    .filter((s) => s.slugSuffix === undefined && s.example === undefined)
    .slice(1)
    .map((s) => s.nodeId)
    .sort();
  assert.deepEqual(
    siblingStates.map((s) => s.state.setNodeId).sort(),
    expectedSetNodeIds
  );

  for (const { state } of siblingStates) {
    assert.deepEqual(state.axisValues, { Type: "Round", Size: "Small", State: "Enabled" });
  }
});

test("every emitted state drives cleanly through C2's driveState (validates against validateStateKeys, resolves a real figmaNodeQuery)", () => {
  const states = sampleDefault(buttonEntry, figmaExport);
  for (const { stateId, state } of states) {
    const { harnessParams, figmaNodeQuery } = driveState(buttonEntry, figmaExport, state, iconTable);
    assert.equal(harnessParams.tag, "m3e-button", `stateId ${stateId}`);
    assert.ok(figmaNodeQuery.nodeId, `stateId ${stateId} must resolve a real Figma node`);
  }
});

test("determinism: repeated calls produce byte-identical (deep-equal) stateId order and state content", () => {
  const first = sampleDefault(buttonEntry, figmaExport);
  const second = sampleDefault(buttonEntry, figmaExport);
  assert.deepEqual(
    first.map((s) => s.stateId),
    second.map((s) => s.stateId)
  );
  assert.deepEqual(first, second);
});

// -- Step 3: exclusions, asserted in code ------------------------------------

test("the State axis (interaction states) never appears as a varied axis in the default sample", () => {
  const states = sampleDefault(buttonEntry, figmaExport);
  for (const { state } of states) {
    assert.equal(state.axisValues.State, "Enabled", "State must stay pinned at its Figma default everywhere");
  }
  assert.ok(
    !states.some((s) => s.stateId.includes("state")),
    "no stateId should reference the excluded State axis"
  );
});

test("assertNonGoalExclusions throws if a future correspondence.json ever maps State instead of marking it unmapped", () => {
  const brokenEntry = {
    ...buttonEntry,
    axes: buttonEntry.axes.map((a) =>
      a.figmaProp === "State" ? { figmaProp: "State", attr: "state", valueMap: { Enabled: "enabled" } } : a
    ),
  };
  assert.throws(() => assertNonGoalExclusions(brokenEntry), /Plan C non-goal/);
  assert.throws(() => sampleDefault(brokenEntry, figmaExport), /Plan C non-goal/);
  assert.throws(() => sampleAudit(brokenEntry, figmaExport), /Plan C non-goal/);
});

test("an axis marked unmapped for any reason (not just State) is excluded from the default sample", () => {
  const brokenEntry = {
    ...buttonEntry,
    axes: buttonEntry.axes.map((a) => (a.figmaProp === "Type" ? { figmaProp: "Type", unmapped: "test-only" } : a)),
  };
  const states = sampleDefault(brokenEntry, figmaExport);
  assert.ok(
    !states.some((s) => s.stateId.startsWith("axis-type-")),
    "an unmapped Type axis must never be varied, regardless of WHY it's unmapped"
  );
});

test("an iconTable entry is gate-exempt in v1: sampleDefault and sampleAudit both return no states", () => {
  assert.deepEqual(sampleDefault(iconEntry, figmaExport), []);
  assert.deepEqual(sampleAudit(iconEntry, figmaExport), []);
});

test("a code-only entry (no figmaSets) yields no states — nothing to visually gate", () => {
  const codeOnlyEntry = { ...buttonEntry, cemTag: "m3e-fake-code-only", figmaSets: [] };
  assert.deepEqual(sampleDefault(codeOnlyEntry, figmaExport), []);
  assert.deepEqual(sampleAudit(codeOnlyEntry, figmaExport), []);
});

// -- publish live-test finding: entries whose figmaSets ALL lack captured ---
// -- setProperties (e.g. m3e-nav-menu, a standalone Figma COMPONENT bound  ---
// -- via a non-"standalone" matcherKind) are gate-exempt, not a throw       --
//
// Extraction (extract/README.md) only calls `get_component_properties` on
// COMPONENT_SET node ids — a correspondence entry whose only figmaSet(s)
// resolve to a standalone COMPONENT will NEVER have a captured setProperties
// entry, by design. Before this fix, drive.mjs's definitionsFor threw in
// this case (no axis grid to derive defaults from), which used to propagate
// all the way up through sampleDefault/status() and abort the whole
// publish run for every OTHER binding too (see src/publish/runner.mjs's
// per-entry statusFn try/catch fix, which this exemption makes unnecessary
// for this specific, legitimate case — it's caught structurally here
// instead of generically there).

test("an entry whose figmaSets ALL lack captured setProperties (standalone-Figma-COMPONENT-bound-via-non-'standalone'-matcherKind, e.g. the real m3e-nav-menu shape) is gate-exempt: sampleDefault/sampleAudit both return no states", () => {
  const navMenuLikeEntry = {
    ...buttonEntry,
    cemTag: "m3e-fake-nav-menu",
    matcherKind: "manual",
    figmaSets: [{ nodeId: "99999:9999", setName: "Fake Standalone Component", fixedAttrs: {} }],
    axes: [],
    props: [],
  };
  assert.deepEqual(sampleDefault(navMenuLikeEntry, figmaExport), []);
  assert.deepEqual(sampleAudit(navMenuLikeEntry, figmaExport), []);
});

test("an entry with a MIX of one captured COMPONENT_SET figmaSet and one uncaptured standalone-COMPONENT figmaSet still drives normally off the captured sibling — NOT gate-exempt, and does not regress", () => {
  const mixedEntry = {
    ...buttonEntry,
    cemTag: "m3e-fake-mixed",
    figmaSets: [
      buttonEntry.figmaSets[0], // real, captured (57994:2227)
      { nodeId: "99999:9999", setName: "Fake Standalone Sibling", fixedAttrs: {} }, // uncaptured
    ],
  };

  const states = sampleDefault(mixedEntry, figmaExport);
  assert.ok(states.length > 0, "a mixed entry must still produce real states, not be exempted");
  assert.ok(states.some((s) => s.stateId === "default"), "the captured sibling still drives the base default state");
  assert.ok(
    states.some((s) => s.stateId === "set-fake-standalone-sibling"),
    "the uncaptured sibling still contributes its own sample state (driven off the captured sibling's defs)"
  );

  // The base ("default") state — driven off the CAPTURED sibling — still
  // drives cleanly through C2's driveState, proving definitionsFor really
  // did fall back to the captured sibling's setProperties rather than
  // silently producing a broken/empty defs object. (The uncaptured
  // sibling's own sample state resolves fine at the sampling layer — its
  // axisValues/propValues are correctly derived from the captured sibling's
  // defs, per definitionsFor's fusion-group convention — but driving it all
  // the way to a figmaNodeQuery would require the uncaptured node to ALSO
  // have real variant children to resolve against, which a genuinely
  // standalone COMPONENT never has; that's a separate, pre-existing
  // driveState concern, out of scope for this exemption.)
  const defaultState = states.find((s) => s.stateId === "default");
  assert.doesNotThrow(() => driveState(mixedEntry, figmaExport, defaultState.state, iconTable));
});

// -- Step 2: --audit = full cartesian of DRAWN variants ----------------------

test("--audit produces the full cartesian of drawn variants: 5 figmaSets x 2 Types x 5 Sizes (State pinned to Enabled) = 50", () => {
  const states = sampleAudit(buttonEntry, figmaExport);
  assert.equal(states.length, 50, "measured: every one of the 5 sibling sets has all 10 Type x Size combos drawn at State=Enabled");

  // every state pins State to the default (Enabled) — audit does not
  // sweep interaction states either (Plan C non-goal, not just a default-
  // plan-only rule).
  for (const { state } of states) {
    assert.equal(state.axisValues.State, "Enabled");
  }

  // full cartesian per set: 2 Types x 5 Sizes, no gaps.
  const bySet = new Map();
  for (const { state } of states) {
    if (!bySet.has(state.setNodeId)) bySet.set(state.setNodeId, new Set());
    bySet.get(state.setNodeId).add(`${state.axisValues.Type}/${state.axisValues.Size}`);
  }
  assert.equal(bySet.size, 5);
  for (const combos of bySet.values()) {
    assert.equal(combos.size, 10);
  }
});

test("--audit states also drive cleanly and resolve real (measured) figma nodes, matching the default-plan's reference node", () => {
  const states = sampleAudit(buttonEntry, figmaExport);
  const filledMedium = states.find(
    (s) => s.state.setNodeId === "57994:2227" && s.state.axisValues.Type === "Round" && s.state.axisValues.Size === "Medium"
  );
  assert.ok(filledMedium);
  const { figmaNodeQuery } = driveState(buttonEntry, figmaExport, filledMedium.state, iconTable);
  assert.equal(figmaNodeQuery.nodeId, "57994:2322"); // same measured node as drive.test.mjs's reference scenario
});

test("--audit determinism: stable stateId ordering across repeated calls (set-major, in entry.figmaSets order, then variant name ordinal)", () => {
  const first = sampleAudit(buttonEntry, figmaExport).map((s) => s.stateId);
  const second = sampleAudit(buttonEntry, figmaExport).map((s) => s.stateId);
  assert.deepEqual(first, second);

  // set-major: each set's 10 states are contiguous, in entry.figmaSets order.
  const actualSetOrder = [];
  for (const id of first) {
    const setLabel = id.replace(/-type-.*$/, "");
    if (actualSetOrder[actualSetOrder.length - 1] !== setLabel) actualSetOrder.push(setLabel);
  }
  assert.equal(actualSetOrder.length, 5, "exactly 5 contiguous set-groups, i.e. no interleaving across sets");

  // within each set, variant-name ordinal order (Round before Square, since
  // 'R' < 'S'; within a Type, Large/Medium/XLarge/XSmall/Small ordinal).
  const firstSetStates = first.slice(0, 10);
  assert.deepEqual(firstSetStates, [...firstSetStates].sort());
});

test("--audit spot-checks exactly 5 icons (deterministic, sorted by symbolName) instead of the full 141-icon cartesian", () => {
  const spotCheck = auditIconSpotCheck(iconTable);
  assert.equal(spotCheck.length, 5);
  assert.ok(iconTable.length > 5, "fixture sanity: the full iconTable is much larger than the spot-check sample");

  const symbolNames = spotCheck.map((i) => i.symbolName);
  assert.deepEqual(symbolNames, [...symbolNames].sort(), "spot-check is sorted (ordinal) for determinism");

  for (const icon of spotCheck) {
    assert.ok(icon.figmaNodeId, "each spot-check entry must carry a real figma node id");
    assert.ok(icon.stateId.startsWith("audit-icon-"));
  }

  const second = auditIconSpotCheck(iconTable);
  assert.deepEqual(spotCheck, second, "determinism: repeated calls pick the same 5 icons in the same order");
});

test("auditIconSpotCheck respects a custom count", () => {
  const three = auditIconSpotCheck(iconTable, 3);
  assert.equal(three.length, 3);
});
