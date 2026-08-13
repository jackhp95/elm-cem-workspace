// Task D4: density & spacing policy (docs/density-and-spacing.md;
// plans/plan/D-tokens.md Task D4; evidence #4/#13).
//
// This is a shape/sanity test over profiles/m3-kit/spacing-advisory.json,
// not a generator test — the file is hand-authored data (an advisory table,
// not derived from any ingest like tokens.json), so there is no
// derive-and-diff check here. What IS worth guarding:
//   - the file parses and has the documented shape (agents/humans consulting
//     it can rely on the field names)
//   - it stays honestly "advisory only" (autoApplied: false) — the whole
//     point of Task D4's policy is that this table is NOT auto-applied
//   - rows are sorted ascending by px and every px is unique (so a reader
//     scanning top-to-bottom sees a monotonic scale, and no ambiguous
//     duplicate entry)
//   - every row explicitly records "kit has no spacing variables" in
//     m3SpacingToken (null) — this table exists BECAUSE the kit has none
//     (evidence #13); a row that silently invented a token name would
//     contradict the documented policy.
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test test/spacing-advisory.test.mjs

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const advisoryPath = path.join(here, "..", "profiles", "m3-kit", "spacing-advisory.json");

function load() {
  return JSON.parse(fs.readFileSync(advisoryPath, "utf8"));
}

test("spacing-advisory.json parses and declares itself advisory-only, never auto-applied", () => {
  const advisory = load();
  assert.equal(advisory.autoApplied, false, "Task D4's policy: the advisory table is consulted, never applied automatically");
  assert.equal(typeof advisory.seeAlso, "string");
  assert.ok(advisory.seeAlso.includes("density-and-spacing.md"));
  assert.ok(Array.isArray(advisory.rows) && advisory.rows.length > 0);
});

test("rows are sorted ascending by px with no duplicate px values", () => {
  const { rows } = load();
  const pxValues = rows.map((r) => r.px);
  const sorted = [...pxValues].sort((a, b) => a - b);
  assert.deepEqual(pxValues, sorted, "rows must already be in ascending px order");
  assert.equal(new Set(pxValues).size, pxValues.length, "no duplicate px values");
});

test("every row has the full documented shape and no invented m3 spacing token", () => {
  const { rows } = load();
  for (const row of rows) {
    assert.equal(typeof row.px, "number");
    assert.equal(typeof row.tailwindGap, "string");
    assert.equal(typeof row.tailwindPadding, "string");
    assert.equal(row.m3SpacingToken, null, "the kit ships no spacing variables (evidence #13) — no row may invent one");
    assert.equal(typeof row.note, "string");
    assert.equal(typeof row.measuredInEvidence4, "boolean");
  }
});

test("at least one row is flagged as the literal px evidence #4 actually observed", () => {
  const { rows } = load();
  const measured = rows.filter((r) => r.measuredInEvidence4);
  assert.ok(measured.length > 0, "evidence #4 measured px-[24px] and gap-[8px] in a real frame render");
  const measuredPx = measured.map((r) => r.px).sort((a, b) => a - b);
  assert.deepEqual(measuredPx, [8, 24]);
});
