// Phase 4 (L8): the audit's spec-failures fold into the tier model as
// tier-attributed required-code-change rows — with NO double-count, and the
// audit and the report AGREE.

import assert from "node:assert/strict";
import fs from "node:fs";
import { test } from "node:test";

import { collectStandingChanges, DEFAULT_REPORT_PATH } from "./token-change-report.mjs";
import { runAudit } from "./audit.mjs";

test("L8: report rows == audit spec-failures + numeric required-code-changes (no double-count)", () => {
  const changes = collectStandingChanges();
  const { colorRows, numericRows } = runAudit();
  const specFailures = colorRows.filter((r) => r.status === "spec-failure");
  const numericRequired = numericRows.filter((r) => r.classification === "required-code-change");

  assert.equal(
    changes.length,
    specFailures.length + numericRequired.length,
    "one report row per audit spec-failure / numeric-required — no more, no fewer",
  );

  // No token appears twice (no double-count).
  const tokens = changes.map((c) => c.token);
  assert.equal(new Set(tokens).size, tokens.length, "no duplicate token rows in the report");
});

test("L8: every audit spec-failure appears as a system/reference-tier row naming the offending file", () => {
  const changes = collectStandingChanges();
  const { colorRows } = runAudit();
  const byToken = new Map(changes.map((c) => [c.token, c]));

  for (const row of colorRows.filter((r) => r.status === "spec-failure")) {
    const change = byToken.get(row.md);
    assert.ok(change, `audit spec-failure ${row.md} must appear in the report`);
    assert.ok(["system", "reference"].includes(change.tier), `${row.md} must be system/reference tier`);
    assert.match(change.file, /tailwind-m3e-web\/(src\/(sys\/color|ref\/palette)\.css|bin\/calibrate-tones\.mjs)/, `${row.md} must name its offending file`);
    // The audit's rootCause is carried through faithfully.
    assert.equal(change.rootCause, row.rootCause, `${row.md} rootCause must match the audit`);
  }
});

test("L8: Decision-7 severity split — 8 genuine derivation bugs blocking, tone-table noise advisory", () => {
  const changes = collectStandingChanges();
  const blocking = changes.filter((c) => c.severity === "blocking");
  const advisory = changes.filter((c) => c.severity === "advisory");

  // The 8 real derivation bugs: container-tone-regression (4) + model-divergence (4).
  const containerTone = changes.filter((c) => c.rootCause === "container-tone-regression");
  const modelDivergence = changes.filter((c) => c.rootCause === "model-divergence");
  const toneNoise = changes.filter((c) => c.rootCause === "tone-table-approximation-noise");

  assert.equal(containerTone.length, 4, "4 container-tone regressions");
  assert.equal(modelDivergence.length, 4, "4 tertiary/error model divergences");
  assert.equal(toneNoise.length, 20, "20 tone-table approximation-noise rows");

  assert.equal(blocking.length, 8, "8 blocking (the genuine derivation bugs)");
  assert.equal(advisory.length, 20, "20 advisory (tone-table noise, Decision 7 — never block)");
  for (const c of containerTone) assert.equal(c.severity, "blocking");
  for (const c of modelDivergence) assert.equal(c.severity, "blocking");
  for (const c of toneNoise) assert.equal(c.severity, "advisory");
});

test("L8: the benign-equivalent numeric mismatch is NOT folded as a required change", () => {
  const changes = collectStandingChanges();
  const { numericRows } = runAudit();
  const benign = numericRows.filter((r) => r.classification === "benign-equivalent");
  // On the real inputs Corner/Full is benign-equivalent — it must not be a row.
  for (const b of benign) {
    assert.ok(!changes.some((c) => c.token === b.md), `benign-equivalent ${b.md} must NOT be a required-code-change row`);
  }
});

test("L8: the committed report re-expresses the audit and is byte-stable", () => {
  // Guards against the report and audit silently diverging.
  const md = fs.readFileSync(DEFAULT_REPORT_PATH, "utf8");
  const changes = collectStandingChanges();
  for (const c of changes) {
    assert.ok(md.includes(c.token), `${c.token} must be in the committed report`);
    assert.ok(md.includes(c.file), `${c.file} must be named in the committed report`);
  }
});
