// Phase 4 (L7): token-change-report.md generation + the bump gate (Decision 3
// NON-BLOCKING v1; strict mode fails on an unfiled blocking change, passes a
// re-theme).

import assert from "node:assert/strict";
import fs from "node:fs";
import { test } from "node:test";

import {
  collectStandingChanges,
  renderReport,
  serializeReport,
  runGate,
  changesFromVerdict,
  DEFAULT_REPORT_PATH,
} from "./token-change-report.mjs";
import { classifyDelta, readBaseSources } from "./classify-delta.mjs";

test("L7: token-change-report.md is generated on real inputs and is byte-stable", () => {
  const changes = collectStandingChanges();
  assert.ok(changes.length > 0, "the audit yields standing required-code-changes on real inputs");
  const committed = fs.readFileSync(DEFAULT_REPORT_PATH, "utf8");
  assert.equal(committed, serializeReport(changes), "committed report must equal a fresh regeneration");
});

test("L7: the report renders tier + owner file + reason for every row", () => {
  const changes = collectStandingChanges();
  const md = renderReport(changes);
  assert.match(md, /NON-BLOCKING in v1/);
  assert.match(md, /Blocking-band required code changes/);
  assert.match(md, /Advisory required code changes/);
  for (const c of changes) assert.ok(md.includes(c.token), `report must list ${c.token}`);
});

test("L7: strict gate FAILS on an unfiled blocking required-code-change (the fixture-b delta)", () => {
  const base = readBaseSources();
  const after = {
    ...base,
    cemFacts: JSON.parse(JSON.stringify(base.cemFacts)),
  };
  const target = after.cemFacts.components.find((c) => (c.cssProperties ?? []).length);
  target.cssProperties.push({ name: "--m3e-fake-l7-gate-var-color", description: "L7 gate fixture", default: null, syntax: null });

  const verdict = classifyDelta(base, after);
  assert.equal(verdict.kind, "required-code-change");
  const changes = changesFromVerdict(verdict);
  assert.equal(changes.length, 1);

  const strict = runGate(changes, { strict: true });
  assert.equal(strict.blocking, true, "strict gate must fail on an unfiled blocking required-code-change");

  // v1 default (non-strict) NEVER blocks — it only warns (Decision 3).
  const v1 = runGate(changes, { strict: false });
  assert.equal(v1.blocking, false, "v1 gate is non-blocking (warn only)");
  assert.equal(v1.blockingChanges.length, 1, "…but still surfaces the blocking change for the warning");
});

test("L7: strict gate PASSES a pure re-theme (seed-only delta → no change rows)", () => {
  const base = readBaseSources();
  const after = { ...base, seedCss: base.seedCss.replace("#6750a4", "#2e7d32") };
  const verdict = classifyDelta(base, after);
  assert.equal(verdict.kind, "retheme");
  const changes = changesFromVerdict(verdict);
  assert.deepEqual(changes, [], "a re-theme forces no code change");
  assert.equal(runGate(changes, { strict: true }).blocking, false, "strict gate passes a pure re-theme");
});

test("L7: a filed follow-up unblocks its blocking change even in strict mode", () => {
  const changes = [
    { source: "audit", token: "--md-sys-color-on-primary-container", tier: "system", kind: "required-code-change", reason: "alias-repoint", severity: "blocking", file: "x", detail: "y" },
  ];
  const filed = runGate(changes, { strict: true, followUps: new Set(["--md-sys-color-on-primary-container"]) });
  assert.equal(filed.blocking, false, "a filed follow-up clears the block");
});
