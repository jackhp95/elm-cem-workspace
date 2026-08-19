import { test } from "node:test";
import assert from "node:assert/strict";
import { buildOracle } from "./oracle.mjs";
const oracle = buildOracle();
test("button module + variant enum + bool", () => {
  const b = oracle["m3e-button"];
  assert.equal(b.module, "Button");
  const variant = b.attributes.find((a) => a.htmlName === "variant");
  assert.equal(variant.kind, "enum");
  assert.deepEqual(variant.enumValues.slice().sort(), ["elevated","filled","outlined","text","tonal"]);
  assert.equal(b.attributes.find((a) => a.htmlName === "disabled").kind, "bool");
});
test("button slot helpers are the BARE slot name (no +Slot bump); default child", () => {
  const b = oracle["m3e-button"];
  assert.equal(b.slots.find((s) => s.rawName === "icon").helper, "icon");
  // The positional slot helper is the bare slot name even when it collides with
  // an attribute (`selected`): the generator keeps the positional helper bare and
  // resolves the clash only on the builder (`withSelectedSlot`).
  assert.equal(b.slots.find((s) => s.rawName === "selected").helper, "selected");
  assert.equal(b.slots.find((s) => s.rawName === "").helper, "child");
  // The colliding `selected` BOOLEAN attribute has no positional top setter (its
  // name is taken by the slot helper), so the oracle drops it from `attributes`.
  assert.ok(!b.attributes.some((a) => a.setter === "selected"));
});
test("icon-button module; aria-label is NOT a required field (universal setter)", () => {
  const ib = oracle["m3e-icon-button"];
  assert.equal(ib.module, "IconButton");
  // aria moved off the phantom/required system -> settable via M3e.Aria on anything.
  assert.ok(!ib.requiredFields.some((f) => f.field === "ariaLabel"));
});

// Fix A — tagName reconciliation. The @m3e/web CEM stamps a WRONG class-level
// tagName on two element classes (M3eStepperNextElement.tagName ===
// "m3e-stepper-previous"); the custom-element-definition export carries the
// real registration tag. reconcileTagNames() overwrites the declaration from
// its export so the oracle keys these entries by the correct tag. Without it,
// m3e-stepper-next / m3e-fab-menu-item never resolve and degrade to "unknown
// m3e tag".
test("Fix A: reconciled tags resolve to their own module", () => {
  assert.ok(oracle["m3e-stepper-next"], "m3e-stepper-next tag resolves");
  assert.equal(oracle["m3e-stepper-next"].module, "StepperNext");
  assert.equal(oracle["m3e-stepper-next"].kind, "stepperNext");
  assert.ok(oracle["m3e-fab-menu-item"], "m3e-fab-menu-item tag resolves");
  assert.equal(oracle["m3e-fab-menu-item"].module, "FabMenuItem");
  assert.equal(oracle["m3e-fab-menu-item"].kind, "fabMenuItem");
});

// Fix C — per-container child routing by produced kind. A composite's default
// children with no `slot=` attr route to the NAMED slot whose accepted kind
// matches (panels -> panel, step-panels -> panel). Union-row containers (Menu)
// keep an empty routing map so their heterogeneous children flow through
// `children`.
test("Fix C: childSlotByKind routes typed default children", () => {
  assert.equal(oracle["m3e-tabs"].childSlotByKind.tabPanel, "panel");
  assert.equal(oracle["m3e-stepper"].childSlotByKind.step, "step");
  assert.equal(oracle["m3e-stepper"].childSlotByKind.stepPanel, "panel");
  // Union-row container: no per-kind routing (children flow through `children`).
  assert.deepEqual(oracle["m3e-menu"].childSlotByKind, {});
});
