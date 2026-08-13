import { test } from "node:test";
import assert from "node:assert/strict";
import { camel, pascal, constructor, avoidConflicts } from "./naming.mjs";

test("camel", () => {
  assert.equal(camel("variant"), "variant");
  assert.equal(camel("disabled-interactive"), "disabledInteractive");
  assert.equal(camel("extra-small"), "extraSmall");
  assert.equal(camel("trailing-icon"), "trailingIcon");
  assert.equal(camel("12-sided-cookie"), "value12SidedCookie");
  assert.equal(camel("_blank"), "blank");
});
test("pascal", () => {
  assert.equal(pascal("button"), "Button");
  assert.equal(pascal("icon-button"), "IconButton");
  assert.equal(pascal("chip-set"), "ChipSet");
  assert.equal(pascal("top-start"), "TopStart");
  assert.equal(pascal("2x"), "V2x");
});
test("constructor == pascal", () => assert.equal(constructor("tonal-spot"), pascal("tonal-spot")));
test("avoidConflicts", () => {
  assert.equal(avoidConflicts("round", new Set()), "roundAttr");
  assert.equal(avoidConflicts("children", new Set()), "childrenAttr");
  assert.equal(avoidConflicts("variant", new Set()), "variant");
  assert.equal(avoidConflicts("foo", new Set(["foo"])), "fooAttr");
});
