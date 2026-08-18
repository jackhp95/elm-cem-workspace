// Phase 4 (L2): tier-attribution of the correspondence table (tokens.json).

import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { test } from "node:test";

import { deriveTokenRows, tierForMd, DEFAULT_PATHS } from "./derive.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));

test("L2: tierForMd derives the tier from the --md prefix", () => {
  assert.equal(tierForMd("--md-seed-primary"), "seed");
  assert.equal(tierForMd("--md-ref-palette-primary-40"), "reference");
  assert.equal(tierForMd("--md-sys-color-primary"), "system");
  assert.equal(tierForMd("--m3e-button-container-color"), "component");
  assert.equal(tierForMd(null), null);
  assert.equal(tierForMd(""), null);
});

test("L2: every derived row carries a tier, placed right after md", () => {
  const rows = deriveTokenRows();
  for (const row of rows) {
    assert.ok("tier" in row, `row ${row.figma} is missing a tier`);
    assert.equal(row.tier, tierForMd(row.md), `row ${row.figma} tier disagrees with its md prefix`);
    // key order: figma, md, tier, ... (tier immediately follows md)
    const keys = Object.keys(row);
    assert.equal(keys[0], "figma");
    assert.equal(keys[1], "md");
    assert.equal(keys[2], "tier");
  }
});

test("L2: the Figma overlay has ZERO component-tier rows (component tokens live only in the CEM/graph)", () => {
  const rows = deriveTokenRows();
  const component = rows.filter((r) => r.tier === "component");
  assert.equal(component.length, 0, "tokens.json must never carry a --m3e-* component-tier row");

  // Every mapped (non-null md) row is system-tier by construction.
  const tierCounts = {};
  for (const r of rows) tierCounts[String(r.tier)] = (tierCounts[String(r.tier)] ?? 0) + 1;
  assert.equal(tierCounts.component, undefined);
  assert.ok(tierCounts.system > 0, "at least some rows are system-tier");
});

test("L2: the committed tokens.json already carries the tier field (byte-stable regen)", () => {
  const committed = JSON.parse(fs.readFileSync(DEFAULT_PATHS.tokensPath, "utf8"));
  for (const row of committed) {
    assert.ok("tier" in row, `committed row ${row.figma} is missing a tier — run derive.mjs`);
  }
  assert.equal(committed.filter((r) => r.tier === "component").length, 0);
});
