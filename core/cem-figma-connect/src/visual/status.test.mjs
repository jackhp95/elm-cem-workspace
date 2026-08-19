// Task C6, Step 3: src/visual/status.mjs's gate-status derivation.
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test src/visual/status.test.mjs
//
// OFFLINE + scratch-isolated: every test that seeds results/overrides writes
// into a fresh os.tmpdir() scratch dir, NEVER the real
// render-cache/results/ or profiles/m3-kit/overrides.json — this suite must
// be re-runnable any number of times without polluting (or depending on
// load order with) the real repo's state. The one deliberate exception is
// the "real defaults" test near the bottom, which reads (never writes) the
// real repo paths on purpose — it's the test that proves the integration
// seam (B4's resolveStatusFn) now sees a genuinely active gate.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadFigmaExport } from "../ingest/figma.mjs";
import { readCorrespondence } from "../correspond/merge.mjs";
import { sampleDefault } from "./sample.mjs";
import { status, diffPaths, latestRunId, latestRunRecords, DEFAULT_RESULTS_DIR, DEFAULT_OVERRIDES_PATH } from "./status.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");

const figmaExport = loadFigmaExport(path.join(repoRoot, "test", "fixtures", "figma-export.m3-kit.json"));
const realCorrespondencePath = path.join(repoRoot, "profiles", "m3-kit", "correspondence.json");
const correspondence = readCorrespondence(realCorrespondencePath);

const buttonEntry = correspondence.find((e) => e.cemTag === "m3e-button");
assert.ok(buttonEntry, "fixture setup: profiles/m3-kit/correspondence.json must carry a confirmed m3e-button entry");

const iconEntry = correspondence.find((e) => e.kind === "iconTable");
assert.ok(iconEntry, "fixture setup: profiles/m3-kit/correspondence.json must carry the kind:iconTable entry");

const EXPECTED_BUTTON_STATE_IDS = sampleDefault(buttonEntry, figmaExport).map((s) => s.stateId);

function mkScratchDir() {
  return fs.mkdtempSync(path.join(os.tmpdir(), "cem-figma-connect-status-test-"));
}

// writeRun(resultsDir, runId, records) -> writes <resultsDir>/<runId>.jsonl
function writeRun(resultsDir, runId, records) {
  fs.mkdirSync(resultsDir, { recursive: true });
  const lines = records.map((r) => JSON.stringify(r)).join("\n") + "\n";
  fs.writeFileSync(path.join(resultsDir, `${runId}.jsonl`), lines, "utf8");
}

// allPassingRecords(entry, { except }) -> one record per sampleDefault
// state, pass:true/diffRatio:0 by default; `except` maps stateId ->
// partial-record overrides (e.g. { pass: false, diffRatio: 0.5 }) so a
// single test can flip exactly one state to failing/missing.
function allPassingRecords(entry, { except = {}, omit = [] } = {}) {
  const states = sampleDefault(entry, figmaExport);
  return states
    .filter((s) => !omit.includes(s.stateId))
    .map((s) => ({
      entryId: entry.cemTag,
      stateId: s.stateId,
      pass: true,
      diffRatio: 0,
      threshold: 0.02,
      pixelThreshold: 0.1,
      artifacts: { code: `code/${s.stateId}.png`, figma: `figma/${s.stateId}.png`, diff: `diff/${s.stateId}.png` },
      ...(except[s.stateId] ?? {}),
    }));
}

function writeOverrides(overridesPath, decisions) {
  fs.mkdirSync(path.dirname(overridesPath), { recursive: true });
  fs.writeFileSync(overridesPath, `${JSON.stringify(decisions, null, 2)}\n`, "utf8");
}

// -- gate-exempt entries (C5: iconTable / code-only) -------------------------

test("status: an iconTable entry is gate-exempt — always 'pass', no results/overrides needed at all", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results"); // deliberately never created
    const overridesPath = path.join(scratch, "overrides.json"); // deliberately never created
    assert.equal(status(iconEntry, { resultsDir, overridesPath, figmaExport }), "pass");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("status: a code-only entry (figmaSets: []) is gate-exempt — always 'pass'", () => {
  const scratch = mkScratchDir();
  try {
    const codeOnlyEntry = { ...buttonEntry, cemTag: "m3e-fake-code-only", figmaSets: [] };
    const resultsDir = path.join(scratch, "results");
    const overridesPath = path.join(scratch, "overrides.json");
    assert.equal(status(codeOnlyEntry, { resultsDir, overridesPath, figmaExport }), "pass");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- missing renders -> pending ------------------------------------------------

test("status: no results directory at all -> pending (missing renders)", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results"); // never created
    const overridesPath = path.join(scratch, "overrides.json");
    assert.equal(status(buttonEntry, { resultsDir, overridesPath, figmaExport }), "pending");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("status: some (not all) expected states missing from the latest run -> pending", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    const overridesPath = path.join(scratch, "overrides.json");
    const records = allPassingRecords(buttonEntry, { omit: [EXPECTED_BUTTON_STATE_IDS[0]] });
    writeRun(resultsDir, "run-1", records);
    assert.equal(status(buttonEntry, { resultsDir, overridesPath, figmaExport }), "pending");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- fully-rendered, no override ----------------------------------------------

test("status: every expected state present and under threshold -> pass", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    const overridesPath = path.join(scratch, "overrides.json");
    writeRun(resultsDir, "run-1", allPassingRecords(buttonEntry));
    assert.equal(status(buttonEntry, { resultsDir, overridesPath, figmaExport }), "pass");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("status: every expected state present, one over threshold, no override -> failed", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    const overridesPath = path.join(scratch, "overrides.json");
    const failingStateId = EXPECTED_BUTTON_STATE_IDS[1];
    const records = allPassingRecords(buttonEntry, { except: { [failingStateId]: { pass: false, diffRatio: 0.5 } } });
    writeRun(resultsDir, "run-1", records);
    assert.equal(status(buttonEntry, { resultsDir, overridesPath, figmaExport }), "failed");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- diffPaths (task C7: publish runner's per-binding gate summary) ----------
//
// Same "latest run" data diffPaths reads status() reads — these tests reuse
// allPassingRecords/writeRun exactly like the "failed" test above, just
// asserting the artifact path surfaced instead of the pass/fail verdict.

test("diffPaths: the failing state's artifacts.diff path, for a 'failed' entry", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    const failingStateId = EXPECTED_BUTTON_STATE_IDS[1];
    writeRun(
      resultsDir,
      "run-1",
      allPassingRecords(buttonEntry, { except: { [failingStateId]: { pass: false, diffRatio: 0.5 } } })
    );
    assert.deepEqual(diffPaths(buttonEntry, { resultsDir }), [`diff/${failingStateId}.png`]);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("diffPaths: every state passing -> []", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    writeRun(resultsDir, "run-1", allPassingRecords(buttonEntry));
    assert.deepEqual(diffPaths(buttonEntry, { resultsDir }), []);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("diffPaths: no results directory at all -> [] (never throws)", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results"); // never created
    assert.deepEqual(diffPaths(buttonEntry, { resultsDir }), []);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("diffPaths: multiple failing states sort deterministically", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    const [firstId, secondId] = EXPECTED_BUTTON_STATE_IDS;
    writeRun(
      resultsDir,
      "run-1",
      allPassingRecords(buttonEntry, {
        except: {
          [firstId]: { pass: false, diffRatio: 0.5 },
          [secondId]: { pass: false, diffRatio: 0.6 },
        },
      })
    );
    assert.deepEqual(
      diffPaths(buttonEntry, { resultsDir }),
      [`diff/${firstId}.png`, `diff/${secondId}.png`].sort()
    );
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- overrides win outright ---------------------------------------------------

test("status: gate:'approved' override wins over failing results -> approved", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    const overridesPath = path.join(scratch, "overrides.json");
    const failingStateId = EXPECTED_BUTTON_STATE_IDS[1];
    writeRun(resultsDir, "run-1", allPassingRecords(buttonEntry, { except: { [failingStateId]: { pass: false, diffRatio: 0.9 } } }));
    writeOverrides(overridesPath, [{ cemTag: "m3e-button", gate: "approved", provenance: "human", note: "known AA fringe" }]);

    assert.equal(status(buttonEntry, { resultsDir, overridesPath, figmaExport }), "approved");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("status: gate:'rejected' override wins even over otherwise-passing results -> rejected", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    const overridesPath = path.join(scratch, "overrides.json");
    writeRun(resultsDir, "run-1", allPassingRecords(buttonEntry));
    writeOverrides(overridesPath, [{ cemTag: "m3e-button", gate: "rejected", provenance: "human", note: "wrong node bound" }]);

    assert.equal(status(buttonEntry, { resultsDir, overridesPath, figmaExport }), "rejected");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// NOTE: retarget (src/visual/review/server.mjs) no longer WRITES a sticky
// gate:"pending" override (see the Fix round: that stranded entries in
// "pending" forever) — it now CLEARS the gate decision instead, via
// src/correspond/review.mjs's clearGateDecision. This test only proves
// status.mjs's own override branch still honors a hand-set gate:"pending"
// value if one exists in overrides.json, e.g. from data written some other
// way; see server.test.mjs for retarget's actual clearing behavior.
test("status: a hand-set gate:'pending' override value wins over stale failing results -> pending", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    const overridesPath = path.join(scratch, "overrides.json");
    const failingStateId = EXPECTED_BUTTON_STATE_IDS[1];
    writeRun(resultsDir, "run-1", allPassingRecords(buttonEntry, { except: { [failingStateId]: { pass: false, diffRatio: 0.9 } } }));
    writeOverrides(overridesPath, [{ cemTag: "m3e-button", gate: "pending", provenance: "human", note: "remapping size axis" }]);

    assert.equal(status(buttonEntry, { resultsDir, overridesPath, figmaExport }), "pending");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("status: an override decision for a DIFFERENT cemTag never affects this entry", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    const overridesPath = path.join(scratch, "overrides.json");
    writeRun(resultsDir, "run-1", allPassingRecords(buttonEntry));
    writeOverrides(overridesPath, [{ cemTag: "m3e-something-else", gate: "rejected" }]);

    assert.equal(status(buttonEntry, { resultsDir, overridesPath, figmaExport }), "pass");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- a Plan A binding-confirm decision (status/provenance, no gate) coexists --

test("status: an overrides.json decision with only status/provenance (Plan A's binding-confirm shape, no gate field) does not force any gate outcome — falls through to results", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    const overridesPath = path.join(scratch, "overrides.json");
    writeRun(resultsDir, "run-1", allPassingRecords(buttonEntry));
    writeOverrides(overridesPath, [{ cemTag: "m3e-button", status: "confirmed" }]);

    assert.equal(status(buttonEntry, { resultsDir, overridesPath, figmaExport }), "pass");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- determinism ---------------------------------------------------------

test("status: re-running derivation against unchanged results/overrides is unchanged (determinism)", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    const overridesPath = path.join(scratch, "overrides.json");
    writeRun(resultsDir, "run-1", allPassingRecords(buttonEntry));
    writeOverrides(overridesPath, [{ cemTag: "m3e-button", gate: "approved", provenance: "human" }]);

    const first = status(buttonEntry, { resultsDir, overridesPath, figmaExport });
    const second = status(buttonEntry, { resultsDir, overridesPath, figmaExport });
    assert.equal(first, "approved");
    assert.equal(second, "approved");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- latestRunId / latestRunRecords ------------------------------------------

test("latestRunId: null when the results dir doesn't exist or has no .jsonl files", () => {
  const scratch = mkScratchDir();
  try {
    assert.equal(latestRunId(path.join(scratch, "nope")), null);
    fs.mkdirSync(path.join(scratch, "empty"), { recursive: true });
    assert.equal(latestRunId(path.join(scratch, "empty")), null);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("latestRunId: picks the ordinally-greatest runId (sortable-as-chronological convention)", () => {
  const scratch = mkScratchDir();
  try {
    const resultsDir = path.join(scratch, "results");
    writeRun(resultsDir, "2026-07-10T000000Z", [{ entryId: "x", stateId: "s", pass: true }]);
    writeRun(resultsDir, "2026-07-11T000000Z", [{ entryId: "x", stateId: "s", pass: false }]);
    writeRun(resultsDir, "2026-07-09T000000Z", [{ entryId: "x", stateId: "s", pass: true }]);

    assert.equal(latestRunId(resultsDir), "2026-07-11T000000Z");
    assert.deepEqual(latestRunRecords(resultsDir), [{ entryId: "x", stateId: "s", pass: false }]);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- the real integration seam: committed overrides, controlled resultsDir ---
//
// Proves the gate decision for m3e-button comes from the committed
// overrides.json (gate:"approved"), NOT from render-cache/results/ — so the
// test is hermetic: a controlled empty resultsDir is passed explicitly, which
// means no stray gate run left in render-cache/results/ can ever redden it.
// This is the same proof as before: the override path is render-state-
// independent, and status() checks overrides BEFORE reading any results file.
// Read-only against overrides.json; never touches render-cache/results/.
test("status: override gate:'approved' (the real runner.mjs call shape) wins over any render state — hermetic via a controlled empty resultsDir, never reads render-cache/results/", () => {
  const scratch = mkScratchDir();
  try {
    // Empty resultsDir — deliberately no jsonl files written here. The override
    // branch fires before latestRunRecords is ever called, so this dir is never
    // even opened; it exists only to satisfy the explicit injection contract.
    const resultsDir = path.join(scratch, "results");

    assert.ok(fs.existsSync(DEFAULT_OVERRIDES_PATH), "sanity: the real profiles/m3-kit/overrides.json exists");

    const realOverrides = JSON.parse(fs.readFileSync(DEFAULT_OVERRIDES_PATH, "utf8"));
    const buttonOverride = realOverrides.find((d) => d.cemTag === "m3e-button");
    assert.equal(buttonOverride?.gate, "approved", "sanity: m3e-button was human-approved in the visual gate");

    // Pass the controlled resultsDir explicitly — this is the same gate decision
    // the runner.mjs call shape derives (fn(entry) with default opts), but now
    // provably independent of whatever is (or isn't) in render-cache/results/.
    assert.equal(status(buttonEntry, { resultsDir }), "approved");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});
