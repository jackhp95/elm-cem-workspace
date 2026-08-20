import { test } from "node:test";
import assert from "node:assert/strict";
import { detectQualifierGroups } from "./qualifier.mjs";

const CEMS = [
  { tag: "m3e-avatar", slug: "avatar", attributes: [] },
  { tag: "m3e-card", slug: "card", attributes: [
    { name: "orientation", kind: "enum", values: ["vertical", "horizontal"] },
  ] },
];
const set = (id, name, page = "Components") => ({ id, name, page, properties: null });

test("sole-set head-noun binds directly with value=null (Generic avatar -> m3e-avatar)", () => {
  const groups = detectQualifierGroups([set("1:1", "Generic avatar")], CEMS);
  assert.equal(groups.length, 1);
  const g = groups[0];
  assert.equal(g.boundTag, "m3e-avatar");
  assert.equal(g.mode, "sole");
  assert.deepEqual(g.setIds, ["1:1"]);
  assert.equal(g.members.length, 1);
  assert.equal(g.members[0].value, null);
});

test("a set that contain-matches nothing yields no group", () => {
  const groups = detectQualifierGroups([set("9:9", "Totally unrelated widget")], CEMS);
  assert.deepEqual(groups, []);
});

test("leading-dot internal sets are skipped", () => {
  const groups = detectQualifierGroups([set("2:2", ".Building Blocks/Generic avatar")], CEMS);
  assert.deepEqual(groups, []);
});

test("a set whose slug IS an exact CEM slug is left to the exact tier (no contains group)", () => {
  const cems = [{ tag: "m3e-filter-chip", slug: "filter-chip", attributes: [] }];
  const groups = detectQualifierGroups([set("8:8", "Filter chip")], cems);
  assert.deepEqual(groups, []);
});

const CARD = { tag: "m3e-card", slug: "card", attributes: [
  { name: "orientation", kind: "enum", values: ["vertical", "horizontal"] },
] };
const BG = { tag: "m3e-button-group", slug: "button-group", attributes: [
  { name: "variant", kind: "enum", values: ["standard", "connected"] },
] };
const PROG = { tag: "m3e-circular-progress-indicator", slug: "circular-progress-indicator", attributes: [
  { name: "indeterminate", kind: "boolean" },
] };

test("attr mode: all qualifiers value-match an enum (Connected/Standard -> variant)", () => {
  const groups = detectQualifierGroups(
    [set("3:1", "Connected button group"), set("3:2", "Standard button group")], [BG]);
  assert.equal(groups.length, 1);
  const g = groups[0];
  assert.equal(g.boundTag, "m3e-button-group");
  assert.equal(g.mode, "attr");
  const byId = Object.fromEntries(g.members.map((m) => [m.id, m.value]));
  assert.equal(byId["3:1"], "connected");
  assert.equal(byId["3:2"], "standard");
});

test("attr mode with leftover: one member unresolved becomes bare value=null (Stacked=leftover)", () => {
  const groups = detectQualifierGroups(
    [set("4:1", "Horizontal card"), set("4:2", "Stacked card")], [CARD]);
  const g = groups[0];
  assert.equal(g.mode, "attr");
  const byId = Object.fromEntries(g.members.map((m) => [m.id, m.value]));
  assert.equal(byId["4:1"], "horizontal");
  assert.equal(byId["4:2"], null);
});

test("attr mode boolean: determinate/indeterminate -> indeterminate boolean (name-affinity + leftover)", () => {
  const groups = detectQualifierGroups(
    [set("5:1", "Circular-indeterminate progress indicator"), set("5:2", "Circular-determinate progress indicator")], [PROG]);
  const g = groups[0];
  assert.equal(g.mode, "attr");
  const byId = Object.fromEntries(g.members.map((m) => [m.id, m.value]));
  assert.equal(byId["5:1"], "indeterminate");
  assert.equal(byId["5:2"], null);
});

const DIALOG = { tag: "m3e-dialog", slug: "dialog", attributes: [
  { name: "open", kind: "boolean" }, // no enum whose values are basic/list/scrollable
] };

test("canonical mode: bind only the base-marker set, gap the rest (Basic dialog -> m3e-dialog)", () => {
  const groups = detectQualifierGroups(
    [set("6:1", "Basic dialog"), set("6:2", "List dialog"), set("6:3", "Scrollable dialog")], [DIALOG]);
  assert.equal(groups.length, 1);
  const g = groups[0];
  assert.equal(g.boundTag, "m3e-dialog");
  assert.equal(g.mode, "canonical");
  assert.deepEqual(g.setIds, ["6:1"]);
  assert.equal(g.members[0].value, null);
});

test("no base marker + no attr resolution -> bind nothing (all gap)", () => {
  const groups = detectQualifierGroups(
    [set("7:1", "List dialog"), set("7:2", "Scrollable dialog")], [DIALOG]);
  assert.deepEqual(groups, []);
});
