// Parity tests: docs-gen's brand-agnostic core, run against the REAL m3e brand
// inputs, must reproduce exactly what the brand's in-tree generators committed.
// This is the proof the extracted seam is faithful — a brand's `gen-*` wrapper
// could delegate to docs-gen and get byte-identical output.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { deriveFamilies } from "../src/families.mjs";
import { deriveTypescale, deriveShapeCorners, deriveColorRoleInventory } from "../src/tokens.mjs";
import { splitSections } from "../src/sections.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(here, "..", "..", ".."); // pipeline/docs-gen/test -> repo root
const M3E = path.join(ROOT, "brands/m3e");
const DOCS = path.join(M3E, "generated/docs/elm-m3e-docs");
const SYS = path.join(M3E, "generated/style/elm-m3e-tailwind/src/sys");
const read = (p) => fs.readFileSync(p, "utf8");
const readJson = (p) => JSON.parse(read(p));

test("deriveFamilies reproduces the brand's committed data/families.json", () => {
  const slots = readJson(path.join(M3E, "inputs/cem/config/slots.json"));
  const committed = readJson(path.join(DOCS, "data/families.json"));
  assert.deepEqual(deriveFamilies(slots._families.families), committed);
});

test("deriveTypescale reproduces the brand's committed typography table", () => {
  const committed = readJson(path.join(DOCS, "data/style-tokens.json"));
  assert.deepEqual(deriveTypescale(read(path.join(SYS, "typescale.css"))), committed.typography);
});

test("deriveShapeCorners reproduces the brand's committed corner scale", () => {
  const committed = readJson(path.join(DOCS, "data/style-tokens.json"));
  const sizes = committed.shapeCorners.map((c) => c.utility.replace(/^rounded-md-corner-/, ""));
  const derived = deriveShapeCorners(read(path.join(SYS, "shape.css")), sizes);
  assert.deepEqual(derived, committed.shapeCorners);
});

test("deriveColorRoleInventory reproduces the brand's committed color inventory", () => {
  const committed = readJson(path.join(DOCS, "data/style-tokens.json"));
  assert.deepEqual(deriveColorRoleInventory(read(path.join(SYS, "color.css"))), committed.colorRoleInventory);
});

test("splitSections parses a migrated guide chapter's sections", () => {
  const md = read(path.join(DOCS, "content/guides/Motion.md"));
  const secs = splitSections(md);
  // Every section round-trips to a non-empty string, and the known Motion prose
  // sections are all present.
  for (const name of ["intro", "shippedBody", "authorBody", "recap"]) {
    assert.ok(secs[name] && secs[name].length > 0, `missing section ${name}`);
  }
  // No delimiter leakage into content.
  for (const v of Object.values(secs)) assert.ok(!v.includes("\n@@@ "), "section content leaked a delimiter");
});
