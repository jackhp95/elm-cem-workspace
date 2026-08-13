import { test } from "node:test";
import assert from "node:assert/strict";
import { slugTokenSet, containsSubset, pickHeadComponent, BASE_MARKERS } from "./normalize.mjs";

test("slugTokenSet splits a slug into a token Set", () => {
  assert.deepEqual([...slugTokenSet("connected-button-group")].sort(), ["button", "connected", "group"]);
  assert.deepEqual([...slugTokenSet("")], []);
});

test("containsSubset is true when every cem token is present (order-independent)", () => {
  assert.equal(containsSubset(["button", "group"], slugTokenSet("connected-button-group")), true);
  assert.equal(containsSubset(["circular", "progress", "indicator"], slugTokenSet("circular-determinate-progress-indicator")), true);
  assert.equal(containsSubset(["card"], slugTokenSet("stacked-card")), true);
  assert.equal(containsSubset(["button", "segment"], slugTokenSet("stacked-card")), false);
  assert.equal(containsSubset([], slugTokenSet("stacked-card")), false);
});

test("pickHeadComponent returns the longest-slug CEM component whose tokens ⊆ the set, or null", () => {
  const cems = [
    { tag: "m3e-button", slug: "button" },
    { tag: "m3e-button-group", slug: "button-group" },
    { tag: "m3e-group", slug: "group" },
  ];
  const hit = pickHeadComponent("connected-button-group", cems);
  assert.equal(hit.component.tag, "m3e-button-group");
  assert.deepEqual([...hit.qualifier].sort(), ["connected"]);
  assert.equal(pickHeadComponent("totally-unrelated", cems), null);
});

test("pickHeadComponent breaks equal-length ties by ordinal tag order (deterministic)", () => {
  const cems = [{ tag: "m3e-b", slug: "b" }, { tag: "m3e-a", slug: "a" }];
  const hit = pickHeadComponent("a-b", cems);
  assert.equal(hit.component.tag, "m3e-a");
});

test("BASE_MARKERS holds the canonical qualifier words", () => {
  for (const w of ["basic", "standard", "plain", "generic", "default"]) assert.ok(BASE_MARKERS.has(w));
});
