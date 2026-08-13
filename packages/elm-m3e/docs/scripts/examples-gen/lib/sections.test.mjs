import { test } from "node:test";
import assert from "node:assert/strict";
import { buildOracle } from "./oracle.mjs";
import { deriveSection } from "./sections.mjs";
const oracle = buildOracle();
const sec = (h) => deriveSection(h, oracle);

test("five buttons varying by variant -> Variants", () => {
  const h = `<m3e-button variant="filled">a</m3e-button><m3e-button variant="tonal">b</m3e-button><m3e-button variant="text">c</m3e-button>`;
  assert.equal(sec(h), "Variants");
});
test("single element -> null", () => {
  assert.equal(sec(`<m3e-button variant="filled">a</m3e-button>`), null);
});
test("siblings varying only by aria-label/href -> null (not enum)", () => {
  const h = `<m3e-icon-button aria-label="Prev"><m3e-icon name="a"></m3e-icon></m3e-icon-button><m3e-icon-button aria-label="Next"><m3e-icon name="b"></m3e-icon></m3e-icon-button>`;
  assert.equal(sec(h), null);
});
