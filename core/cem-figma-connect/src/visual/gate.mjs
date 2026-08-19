// Single-component visual-gate ORCHESTRATOR — the runnable end-to-end driver
// that the C-series modules (drive/sample/capture/diff/status) were always
// meant to feed, but which lived only in a prior session's gitignored scratch.
// Reconstructed here from the committed, individually-tested pieces so the
// gate is a first-class, reusable entry point (Plan E's per-component gating
// + the atoms-up build phase both need it).
//
// Flow per sampled state (all deterministic — no wall-clock, no randomness):
//   sample.sampleDefault(entry)            -> which states to gate
//   drive.driveState(entry, state)         -> { harnessParams, figmaNodeQuery }
//   capture.renderOne(harnessParams)       -> CODE-side PNG (chromium, DPR 2)
//   bridge export_node_as_image(nodeId, 2) -> FIGMA-side PNG (node bounds, 2x)
//   diff.comparePngFiles(...)              -> { pass, diffRatio } vs profile thresholds
//   diff.writeResultRecord(...)            -> render-cache/results/<runId>.jsonl
//   status.status(entry)                   -> "pass" | "failed" | "pending" | ...
//
// Both sides are driven from the SAME correspondence state — that is the whole
// point of the gate (D8: "matched" must mean "pixel-proven"). It is also the
// exact place RC1 (boolean-axis Selected->checked) is proven: drive.mjs now
// emits `checked=""` present/absent, so the code side and the Figma variant
// land on the same pole instead of drifting to opposite defaults.
//
// NOTE: this orchestrator is thin glue over already-tested modules; it hits the
// LIVE Figma bridge for the export side, so it is exercised end-to-end by a
// real run, not a unit test (the pieces it composes are each unit-tested).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadProfile, readCorrespondence } from "../correspond/merge.mjs";
import { loadFigmaExport } from "../ingest/figma.mjs";
import { driveState, toHarnessUrlParams, loadIconTable } from "./drive.mjs";
import { sampleDefault } from "./sample.mjs";
import { comparePngFiles, writeResultRecord, loadThresholds } from "./diff.mjs";
import { status as gateStatus } from "./status.mjs";
import { createRenderer } from "./harness/capture.mjs";
import { wsQuery } from "../../extract/lib/ws-query.mjs";
import { loadCaptures, resolveCaptureByVariant } from "../capture/captures.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");

// exportFigmaNode(nodeId, opts) -> PNG Buffer, via the plugin bridge's
// export_node_as_image (native-scale export; `scale` maps to an
// ExportSettings SCALE constraint, NOT a bare scale field — see the plugin).
async function exportFigmaNode(nodeId, { channel, scale = 2, timeoutMs = 60000 }) {
  const res = await wsQuery("export_node_as_image", { nodeId, scale }, { channel, timeoutMs });
  if (!res || res.error) throw new Error(`export_node_as_image(${nodeId}): ${res && res.error}`);
  if (!res.imageData) throw new Error(`export_node_as_image(${nodeId}) returned no imageData`);
  return Buffer.from(res.imageData, "base64");
}

// resolveFigmaRender(captures, variantNodeId) -> { renderPath, boundsPx } or null.
// Returns null when captures is absent/null, the variant isn't found, or the
// capture is marked degenerate. In all null cases the caller falls back to the
// live exportFigmaNode path (zero behavior change when no sidecar is present).
export function resolveFigmaRender(captures, variantNodeId) {
  if (!captures) return null;
  const hit = resolveCaptureByVariant(captures, variantNodeId);
  if (!hit || hit.degenerate || !hit.renderPath) return null;
  return { renderPath: hit.renderPath, boundsPx: hit.boundsPx };
}

// runGate({ profileName, cemTag, channel, runId, scale }) ->
//   { runId, cemTag, status, records: [{ stateId, nodeId, tier, diffRatio, pass, diff }] }
export async function runGate({ profileName = "m3-kit", cemTag, channel, runId, scale = 2 }) {
  if (!cemTag) throw new Error("runGate: cemTag is required");
  if (!runId) throw new Error("runGate: runId is required");

  const profileDir = path.join(repoRoot, "profiles", profileName);
  const profile = loadProfile(profileDir);
  const correspondencePath = path.join(profileDir, "correspondence.json");
  const entries = readCorrespondence(correspondencePath);
  const entry = entries.find((e) => e.cemTag === cemTag);
  if (!entry) throw new Error(`runGate: no correspondence entry for cemTag '${cemTag}'`);

  const figmaExport = loadFigmaExport(profile.figmaExportPath);
  const iconTable = loadIconTable(correspondencePath);
  const thresholds = await loadThresholds(path.join(profileDir, "visual.json"));

  const samples = sampleDefault(entry, figmaExport);
  if (samples.length === 0) {
    throw new Error(`runGate: entry '${cemTag}' samples to zero states (iconTable/code-only — nothing to gate)`);
  }

  // Fresh, ISOLATED run dir per runId — everything (code/figma/results) under
  // render-cache/gate/<runId>/ so (a) status() reads only THIS run's records
  // (its resultsDir holds exactly one jsonl → no cross-component contamination
  // when batch-gating), and (b) the shared render-cache/results/ the test suite
  // reads is never touched by a gate run.
  const cacheDir = path.join(repoRoot, "render-cache", "gate", runId);
  const resultsDir = path.join(cacheDir, "results");
  fs.rmSync(cacheDir, { recursive: true, force: true });
  const codeDir = path.join(cacheDir, "code");
  const figmaDir = path.join(cacheDir, "figma");
  fs.mkdirSync(codeDir, { recursive: true });
  fs.mkdirSync(figmaDir, { recursive: true });

  // Load the capture sidecar once (null when the file doesn't exist yet, which
  // is the normal state before any `capture` run — all states fall through to
  // the live exportFigmaNode path, preserving today's behavior exactly).
  const captures = loadCaptures(path.join(profileDir, "figma-captures.json"));

  const renderer = await createRenderer(profileName);
  const records = [];
  try {
    for (const { stateId, state } of samples) {
      try {
        const { harnessParams, figmaNodeQuery } = driveState(entry, figmaExport, state, iconTable);

        const codeBuf = await renderer.renderOne(toHarnessUrlParams(harnessParams));
        const codePath = path.join(codeDir, `${stateId}.png`);
        fs.writeFileSync(codePath, codeBuf);

        // Offline path: use a captured PNG when available and non-degenerate.
        // Live fallback: exportFigmaNode (EXACTLY as before) when no capture.
        const cap = resolveFigmaRender(captures, figmaNodeQuery.nodeId);
        let figmaPath;
        if (cap) {
          figmaPath = path.join(repoRoot, "profiles", profileName, cap.renderPath);
        } else {
          const figmaBuf = await exportFigmaNode(figmaNodeQuery.nodeId, { channel, scale });
          figmaPath = path.join(figmaDir, `${stateId}.png`);
          fs.writeFileSync(figmaPath, figmaBuf);
        }

        const record = await comparePngFiles({ entryId: cemTag, stateId, codePath, figmaPath, thresholds, entry });
        const written = await writeResultRecord(record, { cacheDir, runId });
        records.push({
          stateId,
          nodeId: figmaNodeQuery.nodeId,
          tier: figmaNodeQuery.tier,
          diffRatio: Number(written.diffRatio.toFixed(4)),
          pass: written.pass,
          diff: written.artifacts.diff,
        });
      } catch (e) {
        records.push({ stateId, error: e.message });
      }
    }
  } finally {
    await renderer.close();
  }

  const st = gateStatus(entry, { resultsDir, figmaExport });
  return { runId, cemTag, status: st, records };
}

// --- CLI ---------------------------------------------------------------------
//   node src/visual/gate.mjs --tag=m3e-switch --channel=cem-xxxx [--runId=...] [--profile=m3-kit] [--scale=2]
if (import.meta.url === `file://${process.argv[1]}`) {
  const args = {};
  for (const a of process.argv.slice(2)) {
    const eq = a.indexOf("=");
    if (a.startsWith("--") && eq !== -1) args[a.slice(2, eq)] = a.slice(eq + 1);
  }
  const cemTag = args.tag || args.cemTag;
  if (!cemTag) throw new Error("gate.mjs CLI: --tag=<cemTag> is required");
  const runId = args.runId || `gate-${cemTag}`;
  const out = await runGate({
    profileName: args.profile || "m3-kit",
    cemTag,
    channel: args.channel,
    runId,
    scale: args.scale ? Number(args.scale) : 2,
  });
  console.log(JSON.stringify(out, null, 2));
  if (out.status === "failed") process.exitCode = 1;
}
