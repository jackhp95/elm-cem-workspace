// Task C6, Steps 1-2 + 4: src/visual/review/server.mjs.
//
// Run with the file-arg form:
//   node --test src/visual/review/server.test.mjs
//
// Per the task's SCOPE note, this suite proves the whole review flow
// WITHOUT a real browser: buildQueue/approve/reject/retarget are called
// directly as plain functions, and one HTTP-round-trip block per route
// drives a real (but ephemeral, loopback-only) createServer() instance with
// `fetch`. Nothing here ever touches ui.html's JS or opens a browser —
// ui.html itself is only served byte-for-byte (GET /) and asserted to
// contain the routes it's expected to call.
//
// Scratch-isolated: every test writes into a fresh os.tmpdir() profile dir,
// never the real profiles/m3-kit/**.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadFigmaExport } from "../../ingest/figma.mjs";
import { readCorrespondence, writeCorrespondence } from "../../correspond/merge.mjs";
import { readOverrides, upsertOverride } from "../../correspond/review.mjs";
import { sampleDefault } from "../sample.mjs";
import { status } from "../status.mjs";
import {
  buildQueue,
  approve,
  reject,
  retarget,
  effectiveRationale,
  resolveArtifactPath,
  createServer,
} from "./server.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..", "..");

const figmaExport = loadFigmaExport(path.join(repoRoot, "test", "fixtures", "figma-export.m3-kit.json"));
const realCorrespondence = readCorrespondence(path.join(repoRoot, "profiles", "m3-kit", "correspondence.json"));
const buttonEntry = realCorrespondence.find((e) => e.cemTag === "m3e-button");
assert.ok(buttonEntry, "fixture setup: profiles/m3-kit/correspondence.json must carry a confirmed m3e-button entry");

const EXPECTED_STATE_IDS = sampleDefault(buttonEntry, figmaExport).map((s) => s.stateId);

function mkScratchDir() {
  return fs.mkdtempSync(path.join(os.tmpdir(), "cem-figma-connect-review-server-test-"));
}

// setupScratchProfile(scratch) -> { profileDir, resultsDir, overridesPath, cacheRoot }
// Writes a minimal profile dir carrying just the button entry, so buildQueue
// can resolve `record.entryId` back to a real correspondence entry without
// touching the real profiles/m3-kit/**.
function setupScratchProfile(scratch) {
  const profileDir = path.join(scratch, "profile");
  fs.mkdirSync(profileDir, { recursive: true });
  writeCorrespondence(path.join(profileDir, "correspondence.json"), [buttonEntry]);
  return {
    profileDir,
    resultsDir: path.join(scratch, "results"),
    overridesPath: path.join(profileDir, "overrides.json"),
    cacheRoot: scratch,
  };
}

function writeRun(resultsDir, runId, records) {
  fs.mkdirSync(resultsDir, { recursive: true });
  fs.writeFileSync(path.join(resultsDir, `${runId}.jsonl`), records.map((r) => JSON.stringify(r)).join("\n") + "\n", "utf8");
}

// onePassingOneFailingRun(resultsDir, scratch, runId = "run-1") -> writes one
// run where every expected state passes except EXPECTED_STATE_IDS[1], which
// fails and carries a real PNG (copied from src/visual/fixtures/ INTO
// scratch, so it lives under the test's own cacheRoot — resolveArtifactPath
// refuses anything outside cacheRoot, and cacheRoot here is `scratch`
// itself, never the real repo tree) so /api/image has something genuine to
// serve. `runId` is overridable so a test can write a SECOND run (ordinally
// after "run-1") to simulate a fresh render pass following a retarget.
function onePassingOneFailingRun(resultsDir, scratch, runId = "run-1") {
  const sourcePng = path.join(repoRoot, "src", "visual", "fixtures", "figma-button-filled-medium.png");
  assert.ok(fs.existsSync(sourcePng), "fixture PNG must exist for the image-serving test");
  const codePng = path.join(scratch, "artifacts", "code.png");
  fs.mkdirSync(path.dirname(codePng), { recursive: true });
  fs.copyFileSync(sourcePng, codePng);

  const failingStateId = EXPECTED_STATE_IDS[1];

  const records = EXPECTED_STATE_IDS.map((stateId) => ({
    entryId: buttonEntry.cemTag,
    stateId,
    pass: stateId !== failingStateId,
    diffRatio: stateId === failingStateId ? 0.5 : 0,
    threshold: 0.02,
    pixelThreshold: 0.1,
    artifacts: { code: codePng, figma: codePng, diff: codePng },
  }));
  writeRun(resultsDir, runId, records);
  return failingStateId;
}

// allPassingRun(resultsDir, runId) -> writes a run where EVERY expected
// state passes (diffRatio 0, no artifacts needed — nothing in these tests
// serves images off of it). Used to simulate "the human fixed the mapping
// and a fresh render run now fully passes" after a retarget.
function allPassingRun(resultsDir, runId) {
  const records = EXPECTED_STATE_IDS.map((stateId) => ({
    entryId: buttonEntry.cemTag,
    stateId,
    pass: true,
    diffRatio: 0,
    threshold: 0.02,
    pixelThreshold: 0.1,
    artifacts: {},
  }));
  writeRun(resultsDir, runId, records);
}

// -- effectiveRationale --------------------------------------------------

test("effectiveRationale: no override -> the entry's own rationale, unchanged", () => {
  const entry = { rationale: "auto-exact fusion match" };
  assert.equal(effectiveRationale(entry, undefined), "auto-exact fusion match");
});

test("effectiveRationale: an override with a note is joined on, labeled by gate", () => {
  const entry = { rationale: "auto-exact fusion match" };
  assert.equal(
    effectiveRationale(entry, { gate: "approved", note: "known AA fringe" }),
    "auto-exact fusion match | APPROVED: known AA fringe"
  );
  assert.equal(
    effectiveRationale(entry, { gate: "rejected", note: "wrong node" }),
    "auto-exact fusion match | REJECTED: wrong node"
  );
  assert.equal(
    effectiveRationale(entry, { gate: "pending", note: "remapping" }),
    "auto-exact fusion match | RETARGETED: remapping"
  );
});

test("effectiveRationale: an override with no note (or no gate at all — Plan A's confirm-only shape) leaves the rationale untouched", () => {
  const entry = { rationale: "base" };
  assert.equal(effectiveRationale(entry, { status: "confirmed" }), "base");
  assert.equal(effectiveRationale(entry, { gate: "approved" }), "base");
});

// -- resolveArtifactPath (path-traversal guard) -------------------------------

test("resolveArtifactPath: an absolute path under cacheRoot resolves; outside cacheRoot is refused", () => {
  const scratch = mkScratchDir();
  try {
    const cacheRoot = path.join(scratch, "render-cache");
    fs.mkdirSync(cacheRoot, { recursive: true });
    const inside = path.join(cacheRoot, "results", "run-1", "diffs", "x.png");
    assert.equal(resolveArtifactPath(cacheRoot, inside), inside);

    const outside = path.join(scratch, "elsewhere.png");
    assert.equal(resolveArtifactPath(cacheRoot, outside), null);

    const traversal = path.join(cacheRoot, "..", "escaped.png");
    assert.equal(resolveArtifactPath(cacheRoot, traversal), null);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- buildQueue ------------------------------------------------------------

test("buildQueue: lists exactly the failing, not-yet-decided state as a queue item; passing states never appear", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    const failingStateId = onePassingOneFailingRun(ctx.resultsDir, scratch);

    const queue = buildQueue({ ...ctx, figmaExport });
    assert.equal(queue.runId, "run-1");
    assert.equal(queue.items.length, 1);
    assert.equal(queue.items[0].cemTag, "m3e-button");
    assert.equal(queue.items[0].stateId, failingStateId);
    assert.equal(queue.items[0].diffRatio, 0.5);
    assert.match(queue.items[0].artifacts.code, /^\/api\/image\?path=/);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("buildQueue: an already-approved entry drops out of the queue even though its record still says pass:false", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    onePassingOneFailingRun(ctx.resultsDir, scratch);
    approve({ overridesPath: ctx.overridesPath, cemTag: "m3e-button", note: "fine" });

    const queue = buildQueue({ ...ctx, figmaExport });
    assert.equal(queue.items.length, 0);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("buildQueue: no results run at all -> empty queue (runId null), never throws", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    const queue = buildQueue({ ...ctx, figmaExport });
    assert.deepEqual(queue, { runId: null, items: [] });
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- action handlers: the exact C6 "Verify" round-trip ------------------------
//
// "seed a fake failing result -> call the approve action handler
// (programmatically) -> overrides file contains {gate:"approved", note} ->
// status(entry) reports "approved"; re-run derivation -> unchanged."
//
// WB-fix round: these no longer assert `provenance:"human"` on the written
// decision. The visual gate never reads `provenance` (only `gate`), while
// Plan A's confirmFromDecisions DOES read a bare decision's `provenance` and
// stamps it onto the correspondence entry — so a gate-only decision carrying
// `provenance:"human"` used to spuriously protect a binding that was never
// actually confirmed (see task-C6-report.md's WB-fix round). Gate decisions
// now write ONLY `gate` (+`note`).

test("approve: writes {gate:'approved', note} into overrides.json (no provenance — that's Plan A's field, not the gate's); status() then reports 'approved'; re-derivation is unchanged", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    onePassingOneFailingRun(ctx.resultsDir, scratch);

    assert.equal(status(buttonEntry, ctx), "failed", "sanity: failing before approval");

    const result = approve({ overridesPath: ctx.overridesPath, cemTag: "m3e-button", note: "known AA fringe" });
    assert.deepEqual(result, { cemTag: "m3e-button", gate: "approved" });

    const decisions = readOverrides(ctx.overridesPath);
    const decision = decisions.find((d) => d.cemTag === "m3e-button");
    assert.deepEqual(decision, { cemTag: "m3e-button", gate: "approved", note: "known AA fringe" });

    assert.equal(status(buttonEntry, { ...ctx, figmaExport }), "approved");
    // Re-run derivation: unchanged (determinism — no third mutable store).
    assert.equal(status(buttonEntry, { ...ctx, figmaExport }), "approved");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("reject: writes {gate:'rejected', note} (no provenance); status() reports 'rejected'", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    onePassingOneFailingRun(ctx.resultsDir, scratch);

    reject({ overridesPath: ctx.overridesPath, cemTag: "m3e-button", note: "wrong node bound" });

    const decision = readOverrides(ctx.overridesPath).find((d) => d.cemTag === "m3e-button");
    assert.deepEqual(decision, { cemTag: "m3e-button", gate: "rejected", note: "wrong node bound" });
    assert.equal(status(buttonEntry, { ...ctx, figmaExport }), "rejected");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- retarget: frees the binding back to results-derivation (Fix round) ------
//
// retarget used to write a STICKY {gate:"pending"} override — since status()
// checks the override branch BEFORE consulting results, that permanently
// stranded the entry in "pending" forever, even after a fully-passing
// re-render, and buildQueue only lists `failed` items, so a retargeted entry
// could never even reappear in the review queue. The fix: retarget now
// CLEARS the gate/note fields instead, so a fresh render run's results
// decide the entry's fate again — pass, fail, or still pending if renders
// are genuinely missing. (WB-fix round: gate decisions no longer write
// `provenance` at all, so there's no "gate-owned provenance" left to clear.)

test("retarget: clears a prior gate decision entirely — no sticky gate:'pending' is written, and the whole decision object is removed once no fields remain", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    onePassingOneFailingRun(ctx.resultsDir, scratch);

    reject({ overridesPath: ctx.overridesPath, cemTag: "m3e-button", note: "wrong node bound" });
    assert.ok(readOverrides(ctx.overridesPath).find((d) => d.cemTag === "m3e-button"), "sanity: reject wrote a decision");

    retarget({ overridesPath: ctx.overridesPath, cemTag: "m3e-button" });

    const decision = readOverrides(ctx.overridesPath).find((d) => d.cemTag === "m3e-button");
    assert.equal(decision, undefined, "no gate, no note, no provenance, no status left -> the object is gone entirely");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("retarget then a fresh fully-PASSING run: status() reports 'pass', NOT stuck on 'pending' (the stranding bug)", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    onePassingOneFailingRun(ctx.resultsDir, scratch, "run-1");
    approve({ overridesPath: ctx.overridesPath, cemTag: "m3e-button", note: "first look" });

    retarget({ overridesPath: ctx.overridesPath, cemTag: "m3e-button" });

    // A human fixes the mapping and re-renders: a genuinely fresh, fully
    // passing run (ordinally after run-1).
    allPassingRun(ctx.resultsDir, "run-2");

    assert.equal(status(buttonEntry, { ...ctx, figmaExport }), "pass");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("retarget then a fresh FAILING run: the entry re-appears in buildQueue (derived 'failed'), not stuck pending", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    onePassingOneFailingRun(ctx.resultsDir, scratch, "run-1");
    reject({ overridesPath: ctx.overridesPath, cemTag: "m3e-button", note: "wrong node bound" });

    retarget({ overridesPath: ctx.overridesPath, cemTag: "m3e-button" });

    // The human's re-mapped code still doesn't match Figma: a fresh run
    // (ordinally after run-1) that fails again.
    const failingStateId = onePassingOneFailingRun(ctx.resultsDir, scratch, "run-2");

    assert.equal(status(buttonEntry, { ...ctx, figmaExport }), "failed");
    const queue = buildQueue({ ...ctx, figmaExport });
    assert.equal(queue.runId, "run-2");
    assert.equal(queue.items.length, 1);
    assert.equal(queue.items[0].cemTag, "m3e-button");
    assert.equal(queue.items[0].stateId, failingStateId);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("retarget preserves a coexisting Plan A status/provenance decision on the same cemTag — only the gate fields are cleared", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    onePassingOneFailingRun(ctx.resultsDir, scratch);

    // Plan A's binding-confirm decision lands first (status/provenance).
    upsertOverride(ctx.overridesPath, "m3e-button", { status: "confirmed", provenance: "human" });
    // Then a C6 gate decision merges onto the SAME cemTag object.
    approve({ overridesPath: ctx.overridesPath, cemTag: "m3e-button", note: "known AA fringe" });
    assert.deepEqual(readOverrides(ctx.overridesPath).find((d) => d.cemTag === "m3e-button"), {
      cemTag: "m3e-button",
      status: "confirmed",
      provenance: "human",
      gate: "approved",
      note: "known AA fringe",
    });

    retarget({ overridesPath: ctx.overridesPath, cemTag: "m3e-button" });

    const decision = readOverrides(ctx.overridesPath).find((d) => d.cemTag === "m3e-button");
    assert.deepEqual(
      decision,
      { cemTag: "m3e-button", status: "confirmed", provenance: "human" },
      "Plan A's status/provenance survives; gate/note are gone"
    );
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- same-cemTag status+gate coexistence (Fix round, Fix 2) ------------------
//
// review.mjs's refactor headline claim: one cemTag override object carries
// BOTH Plan A's status/provenance (binding-confirm) AND C6's gate/note
// (visual gate) via shallow-merge — upsertOverride merges a patch onto
// whatever's already there rather than replacing the whole object. This was
// previously untested.

test("coexistence: a Plan A status/provenance decision and a later C6 gate patch survive together on the same cemTag object", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    onePassingOneFailingRun(ctx.resultsDir, scratch);

    // Seed an A6-shape decision (binding-confirm, no gate field at all).
    upsertOverride(ctx.overridesPath, "m3e-button", { status: "confirmed", provenance: "human" });

    // Apply a C6 gate patch via the approve action.
    approve({ overridesPath: ctx.overridesPath, cemTag: "m3e-button", note: "known AA fringe" });

    const decision = readOverrides(ctx.overridesPath).find((d) => d.cemTag === "m3e-button");
    assert.equal(decision.status, "confirmed", "Plan A's status survives the gate patch");
    assert.equal(decision.provenance, "human", "provenance survives (both flows agree on it here)");
    assert.equal(decision.gate, "approved", "C6's gate lands on the SAME object");
    assert.equal(decision.note, "known AA fringe", "C6's note lands on the SAME object");
    assert.equal(status(buttonEntry, { ...ctx, figmaExport }), "approved");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("approve then reject on the same cemTag: the LATER decision wins, and prior fields not in the new patch survive only if re-supplied (shallow merge, not append)", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    onePassingOneFailingRun(ctx.resultsDir, scratch);

    approve({ overridesPath: ctx.overridesPath, cemTag: "m3e-button", note: "first pass" });
    reject({ overridesPath: ctx.overridesPath, cemTag: "m3e-button", note: "actually no" });

    const decisions = readOverrides(ctx.overridesPath);
    assert.equal(decisions.length, 1, "one decision object per cemTag, never an appended history");
    assert.deepEqual(decisions[0], { cemTag: "m3e-button", gate: "rejected", note: "actually no" });
    assert.equal(status(buttonEntry, { ...ctx, figmaExport }), "rejected");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("a decision on one cemTag never disturbs an unrelated cemTag's prior decision in the same overrides.json", () => {
  const scratch = mkScratchDir();
  try {
    const ctx = setupScratchProfile(scratch);
    fs.mkdirSync(path.dirname(ctx.overridesPath), { recursive: true });
    fs.writeFileSync(
      ctx.overridesPath,
      `${JSON.stringify([{ cemTag: "m3e-other-thing", status: "confirmed" }], null, 2)}\n`,
      "utf8"
    );

    approve({ overridesPath: ctx.overridesPath, cemTag: "m3e-button" });

    const decisions = readOverrides(ctx.overridesPath);
    assert.equal(decisions.length, 2);
    assert.deepEqual(
      decisions.find((d) => d.cemTag === "m3e-other-thing"),
      { cemTag: "m3e-other-thing", status: "confirmed" }
    );
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- HTTP round-trip: real (ephemeral, loopback) server, real fetch ----------

test("HTTP: GET / serves ui.html; GET /api/queue lists the failure; GET /api/image serves the PNG; POST /api/approve persists and updates the queue", async () => {
  const scratch = mkScratchDir();
  let handle;
  try {
    const ctx = setupScratchProfile(scratch);
    const failingStateId = onePassingOneFailingRun(ctx.resultsDir, scratch);

    handle = await createServer({ ...ctx, figmaExport });

    const indexRes = await fetch(handle.baseUrl + "/");
    assert.equal(indexRes.status, 200);
    const html = await indexRes.text();
    assert.match(html, /<title>Visual gate review/);
    assert.match(html, /"\/api\/queue"/);
    // ui.html builds action routes via `/api/${action}` — assert the pieces
    // that actually appear verbatim in the source rather than the
    // interpolated string, which never appears literally in the file.
    assert.match(html, /`\/api\/\$\{action\}`/);
    assert.match(html, /"approve"/);
    assert.match(html, /"reject"/);
    assert.match(html, /"retarget"/);

    const queueRes = await fetch(handle.baseUrl + "/api/queue");
    assert.equal(queueRes.status, 200);
    const queue = await queueRes.json();
    assert.equal(queue.items.length, 1);
    assert.equal(queue.items[0].stateId, failingStateId);

    const imageRes = await fetch(handle.baseUrl + queue.items[0].artifacts.code);
    assert.equal(imageRes.status, 200);
    assert.equal(imageRes.headers.get("content-type"), "image/png");
    const bytes = new Uint8Array(await imageRes.arrayBuffer());
    assert.ok(bytes.length > 0);
    // PNG magic bytes.
    assert.deepEqual([...bytes.slice(0, 4)], [0x89, 0x50, 0x4e, 0x47]);

    const approveRes = await fetch(handle.baseUrl + "/api/approve", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ cemTag: "m3e-button", note: "looks fine" }),
    });
    assert.equal(approveRes.status, 200);
    const approveBody = await approveRes.json();
    assert.equal(approveBody.gate, "approved");
    assert.equal(approveBody.queue.items.length, 0, "the just-approved entry drops out of the fresh queue");

    const decisions = readOverrides(ctx.overridesPath);
    assert.deepEqual(
      decisions.find((d) => d.cemTag === "m3e-button"),
      { cemTag: "m3e-button", gate: "approved", note: "looks fine" }
    );
  } finally {
    if (handle) await handle.close();
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("HTTP: GET /api/image refuses a path outside the cache root (404, never serves it)", async () => {
  const scratch = mkScratchDir();
  let handle;
  try {
    const ctx = setupScratchProfile(scratch);
    handle = await createServer({ ...ctx, figmaExport });

    const outside = path.join(os.tmpdir(), "not-under-cache-root.png");
    const res = await fetch(handle.baseUrl + "/api/image?path=" + encodeURIComponent(outside));
    assert.equal(res.status, 404);
  } finally {
    if (handle) await handle.close();
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("HTTP: POST /api/reject and /api/retarget both round-trip correctly", async () => {
  const scratch = mkScratchDir();
  let handle;
  try {
    const ctx = setupScratchProfile(scratch);
    onePassingOneFailingRun(ctx.resultsDir, scratch);
    handle = await createServer({ ...ctx, figmaExport });

    const rejectRes = await fetch(handle.baseUrl + "/api/reject", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ cemTag: "m3e-button", note: "wrong node" }),
    });
    assert.equal((await rejectRes.json()).gate, "rejected");
    assert.equal(status(buttonEntry, { ...ctx, figmaExport }), "rejected");

    const retargetRes = await fetch(handle.baseUrl + "/api/retarget", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ cemTag: "m3e-button", note: "remapping" }),
    });
    assert.equal((await retargetRes.json()).gate, "pending");
    // retarget CLEARS the gate decision (no sticky override survives) but
    // PERSISTS the reviewer's reason as a status-neutral `retargetNote`.
    // The entry therefore remains (carrying only the note, no `gate`), yet
    // status() — which consults only `gate` — falls back to results-
    // derivation and immediately re-reports 'failed', not 'pending'.
    const rt = readOverrides(ctx.overridesPath).find((d) => d.cemTag === "m3e-button");
    assert.deepEqual(rt, { cemTag: "m3e-button", retargetNote: "remapping" });
    assert.equal(status(buttonEntry, { ...ctx, figmaExport }), "failed");
  } finally {
    if (handle) await handle.close();
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("HTTP: POST /api/approve without a cemTag is a 400, not a crash", async () => {
  const scratch = mkScratchDir();
  let handle;
  try {
    const ctx = setupScratchProfile(scratch);
    handle = await createServer({ ...ctx, figmaExport });
    const res = await fetch(handle.baseUrl + "/api/approve", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({}),
    });
    assert.equal(res.status, 400);
  } finally {
    if (handle) await handle.close();
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("HTTP: an unknown route is a 404", async () => {
  const scratch = mkScratchDir();
  let handle;
  try {
    const ctx = setupScratchProfile(scratch);
    handle = await createServer({ ...ctx, figmaExport });
    const res = await fetch(handle.baseUrl + "/api/nonexistent-route");
    assert.equal(res.status, 404);
  } finally {
    if (handle) await handle.close();
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});
