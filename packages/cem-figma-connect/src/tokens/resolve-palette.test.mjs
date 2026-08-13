// Task D5, source #2 resolver: src/tokens/resolve-palette.mjs.
//
// Run with the file-arg form:
//   node --test src/tokens/resolve-palette.test.mjs
//
// Tests the CSS-mirroring arithmetic (parseToneTable/parseSeeds,
// resolveRefPalette, resolveSysColorRoles, resolveComputedPalette) against
// the REAL co-located tailwind-m3e-web package (packages/tailwind-m3e-web),
// plus the deterministic fixture-write path (buildFixture/writeFixture).

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  parseToneTable,
  parseSeeds,
  resolveRefPalette,
  resolveSysColorRoles,
  resolveComputedPalette,
  buildFixture,
  FIXTURE_PATH,
} from "./resolve-palette.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");
const VENDORED = path.join(repoRoot, "..", "tailwind-m3e-web", "src");

const seedCss = fs.readFileSync(path.join(VENDORED, "seed.css"), "utf8");
const toneTableCss = fs.readFileSync(path.join(VENDORED, "ref", "_tone-table.css"), "utf8");

test("parseSeeds: reads the real seed.css", () => {
  const seeds = parseSeeds(seedCss);
  assert.equal(seeds.primary, "#6750a4");
  assert.equal(seeds.error, "#b3261e");
});

test("parseToneTable: 12 tones per profile, tone-100 is exactly 100%", () => {
  const table = parseToneTable(toneTableCss);
  assert.equal(Object.keys(table.rich).length, 12);
  assert.equal(Object.keys(table.neutral).length, 12);
  assert.equal(table.rich[100], 1);
  assert.equal(table.neutral[100], 1);
});

test("parseToneTable: throws on a missing tone (defensive)", () => {
  assert.throws(() => parseToneTable(":where(:root) { --_m3e-tone-10-rich: 22.65%; }"));
});

test("resolveRefPalette: primary-40 lies in the violet/indigo range (mirrors tailwind-m3e-web's own palette-resolve.test.mjs assertion)", () => {
  const toneTable = parseToneTable(toneTableCss);
  const seeds = parseSeeds(seedCss);
  const P = resolveRefPalette({ toneTable, seeds });
  const hex = P.primary[40];
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  assert.ok(b > r && b > g, `expected violet (b>r, b>g), got ${hex}`);
});

test("resolveRefPalette: tone-100 gamut-maps to pure white for a chromatic seed (CSS Color 4 gamut mapping, not a naive per-channel clip)", () => {
  const toneTable = parseToneTable(toneTableCss);
  const seeds = parseSeeds(seedCss);
  const P = resolveRefPalette({ toneTable, seeds });
  assert.equal(P.primary[100].toLowerCase(), "#ffffff");
  assert.equal(P.error[100].toLowerCase(), "#ffffff");
});

test("resolveRefPalette: neutral/neutral-variant use FIXED chroma (0.01/0.025), not seed-chroma-scaled", () => {
  const toneTable = parseToneTable(toneTableCss);
  const seeds = parseSeeds(seedCss);
  const P = resolveRefPalette({ toneTable, seeds });
  // A near-achromatic fixed chroma at tone 10 should be a near-gray, not a
  // saturated violet like primary-10.
  const grayish = (hex) => {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return Math.max(r, g, b) - Math.min(r, g, b) < 12;
  };
  assert.ok(grayish(P.neutral[10]), `expected near-gray, got ${P.neutral[10]}`);
});

test("resolveSysColorRoles: emits exactly the 37 roles sys/color.css defines (no *-fixed* roles)", () => {
  const toneTable = parseToneTable(toneTableCss);
  const seeds = parseSeeds(seedCss);
  const P = resolveRefPalette({ toneTable, seeds });
  const roles = resolveSysColorRoles(P);
  assert.equal(Object.keys(roles).length, 37);
  assert.ok(!("primary-fixed" in roles));
  assert.ok(!("on-primary-fixed-variant" in roles));
});

test("resolveSysColorRoles: shadow/scrim are fixed opaque black in both modes", () => {
  const toneTable = parseToneTable(toneTableCss);
  const seeds = parseSeeds(seedCss);
  const P = resolveRefPalette({ toneTable, seeds });
  const roles = resolveSysColorRoles(P);
  assert.deepEqual(roles.shadow, { light: "#000000", dark: "#000000" });
  assert.deepEqual(roles.scrim, { light: "#000000", dark: "#000000" });
});

test("resolveComputedPalette: deterministic — two independent calls produce byte-identical output", () => {
  const a = resolveComputedPalette({ seedCss, toneTableCss });
  const b = resolveComputedPalette({ seedCss, toneTableCss });
  assert.deepEqual(a, b);
});

test("buildFixture: matches the checked-in fixture (regenerating it is a no-op)", () => {
  const fresh = buildFixture();
  const existing = JSON.parse(fs.readFileSync(FIXTURE_PATH, "utf8"));
  assert.deepEqual(fresh.light, existing.light);
  assert.deepEqual(fresh.dark, existing.dark);
});

test("buildFixture: provenance header names the tailwind-m3e-web package version and the resolver", () => {
  const fixture = buildFixture();
  assert.match(fixture._provenance.tailwindM3eWebVersion, /^\d+\.\d+\.\d+/);
  assert.match(fixture._provenance.resolver, /resolve-palette\.mjs/);
});
