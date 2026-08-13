// Task C6, Step 3: the gate-status derivation — the one function B4's
// publish runner (src/publish/runner.mjs's resolveStatusFn) dynamic-imports
// once this file exists (D8: "matched" must mean "pixel-proven", not just
// "a correspondence entry exists").
//
// status(entry, options) -> "pass" | "approved" | "failed" | "rejected" | "pending"
//
// PURE in the sense this project's C-series modules use the word: given the
// SAME on-disk inputs (the latest results run's JSONL + the profile's
// overrides.json + the figma export), this always returns the same answer —
// no separate mutable "gate state" store is ever written by this module.
// Every fs read below is parameterized (resultsDir/overridesPath/figmaExport
// all have real-usage defaults but are fully overridable), which is what
// makes this independently unit-testable against scratch fixtures.
//
// -- Reconciliation vs. the brief's abbreviated signature --------------------
// task-C6-brief.md's Step 3 writes the signature as `status(entry, {...})`
// without pinning down every option key. Two deliberate choices this module
// makes that the brief doesn't spell out:
//   1. The overrides option is named `overridesPath` (a file path), not
//      `overrides` (data) — consistent with this codebase's own naming
//      convention for path options (correspondencePath, reviewPath,
//      profileDir, ...) elsewhere in src/correspond/*.
//   2. A third option, `figmaExport`, is required internally to reuse C5's
//      sampleDefault (see below) for the expected-state set — the brief's
//      shorthand signature doesn't list it, but "reuse sampleDefault" (its
//      own words) is impossible without it. Defaults to the m3-kit profile's
//      own figmaExportPath (loadProfile), since resolveStatusFn's real call
//      site (src/publish/runner.mjs) invokes `statusFn(entry)` with NO
//      second argument at all — every default here has to resolve without
//      any caller-supplied profile name. This repo has exactly one profile
//      today (m3-kit); a future multi-profile status.mjs would need
//      runner.mjs's call site to pass the profile name through, which is
//      out of C6's scope (that would be a runner.mjs change, not this
//      module's).
//
// -- Derivation algorithm -----------------------------------------------------
//
//   1. An override decision for entry.cemTag (see readOverrides,
//      src/correspond/review.mjs — the SAME overrides.json file and
//      shallow-merge-by-cemTag discipline Plan A's binding-confirm flow
//      uses, task C6's "reuse the merge machinery" requirement) wins
//      OUTRIGHT over anything results-derived:
//        - gate:"approved" -> "approved" (a human explicitly accepted a
//          flagged diff — the review webapp's approve action).
//        - gate:"rejected" -> "rejected" (a human explicitly blocked this
//          binding — the review webapp's reject action).
//        - gate:"pending"  -> "pending" (a hand-set override value this
//          branch still honors; NOT what the review webapp's retarget
//          action writes anymore, though. retarget's job is "frees the
//          binding back to pending" per the brief, but it does that by
//          CLEARING the gate override entirely (src/correspond/review.mjs's
//          clearGateDecision) rather than writing a sticky gate:"pending" —
//          a sticky value here would win outright forever, even across a
//          later fully-passing re-render, since this override branch is
//          checked BEFORE results below. See server.mjs's retarget()).
//   2. No override (or an override with no `gate` field, e.g. a
//      binding-confirm-only decision from Plan A's flow): derive from
//      results.
//        - sampleDefault(entry, figmaExport) is empty (iconTable entries,
//          gate-exempt in v1 per C5; code-only entries with no figmaSets at
//          all) -> "pass" (vacuous — nothing sampled, nothing to prove).
//        - Otherwise, look up entry.cemTag's records in the LATEST results
//          run (latestRunRecords below) keyed by stateId. Any expected
//          stateId with NO matching record -> "pending" (missing renders).
//        - All expected states have a record AND every one's `pass` field
//          (already computed by C4's diff.mjs — this module never
//          re-derives diffRatio-vs-threshold itself, single source of truth)
//          is true -> "pass". Otherwise -> "failed".
//
// Convention this module establishes (no orchestrator existed before C6 to
// pin it down): a results record's `entryId` (diff.mjs's own field name,
// generic on purpose — see its header) is expected to equal the
// correspondence entry's `cemTag` for every producer of render-cache
// results. Documented here since this is the first consumer that depends on
// it.
//
// Zero new deps. Determinism: latestRunId sorts runIds ordinally
// (../lib/order.mjs's byString, never mtime/wall-clock) — "latest" is
// whichever .jsonl filename sorts last, so run ids must be chosen
// sortable-as-chronological (e.g. an ISO-8601-ish timestamp) by whatever
// eventually writes them.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadProfile } from "../correspond/merge.mjs";
import { readOverrides } from "../correspond/review.mjs";
import { loadFigmaExport } from "../ingest/figma.mjs";
import { sampleDefault } from "./sample.mjs";
import { byString } from "../lib/order.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");

// Single-profile assumption today (see the header reconciliation note).
const DEFAULT_PROFILE_NAME = "m3-kit";
const DEFAULT_PROFILE_DIR = path.join(repoRoot, "profiles", DEFAULT_PROFILE_NAME);

export const DEFAULT_RESULTS_DIR = path.join(repoRoot, "render-cache", "results");
export const DEFAULT_OVERRIDES_PATH = path.join(DEFAULT_PROFILE_DIR, "overrides.json");

// getDefaultFigmaExport() -> the m3-kit profile's own loadFigmaExport()
// result, memoized per process (it's read-only, validated JSON — safe to
// cache; avoids re-parsing the export on every one of resolveStatusFn's
// per-entry statusFn(entry) calls in a publish run's manifest loop).
let _defaultFigmaExportCache;
function getDefaultFigmaExport() {
  if (!_defaultFigmaExportCache) {
    const profile = loadProfile(DEFAULT_PROFILE_DIR);
    _defaultFigmaExportCache = loadFigmaExport(profile.figmaExportPath);
  }
  return _defaultFigmaExportCache;
}

// -- latest results run --------------------------------------------------

// latestRunId(resultsDir) -> the ordinally-greatest "<runId>.jsonl" filename
// (minus extension) under resultsDir, or null if the directory doesn't
// exist / has no .jsonl files yet (the everyday pre-first-run state — e.g.
// m3e-button has no committed visual results at all today).
export function latestRunId(resultsDir) {
  if (!fs.existsSync(resultsDir)) return null;
  const runIds = fs
    .readdirSync(resultsDir)
    .filter((f) => f.endsWith(".jsonl"))
    .map((f) => f.slice(0, -".jsonl".length))
    .sort(byString);
  return runIds.length > 0 ? runIds[runIds.length - 1] : null;
}

// readRunRecords(resultsDir, runId) -> record[] (C4's diff.mjs result-record
// shape), [] if runId is null/the file doesn't exist. Blank lines (e.g. a
// trailing newline) are skipped, not parsed as JSON.
export function readRunRecords(resultsDir, runId) {
  if (!runId) return [];
  const jsonlPath = path.join(resultsDir, `${runId}.jsonl`);
  if (!fs.existsSync(jsonlPath)) return [];
  return fs
    .readFileSync(jsonlPath, "utf8")
    .split("\n")
    .filter((line) => line.trim().length > 0)
    .map((line) => JSON.parse(line));
}

// latestRunRecords(resultsDir) -> every record from the latest run (all
// entries, not filtered to one cemTag) — the shared building block status()
// and src/visual/review/server.mjs's queue-listing both use, so "latest
// run" can never mean two different things in the same process.
export function latestRunRecords(resultsDir) {
  return readRunRecords(resultsDir, latestRunId(resultsDir));
}

// -- the gate itself -----------------------------------------------------

// status(entry, { resultsDir, overridesPath, figmaExport }) -> the gate
// status string. See the module header for the full algorithm.
export function status(entry, options = {}) {
  const {
    resultsDir = DEFAULT_RESULTS_DIR,
    overridesPath = DEFAULT_OVERRIDES_PATH,
    figmaExport = getDefaultFigmaExport(),
  } = options;

  const overrides = readOverrides(overridesPath);
  const override = overrides.find((d) => d.cemTag === entry.cemTag);
  if (override?.gate === "approved") return "approved";
  if (override?.gate === "rejected") return "rejected";
  if (override?.gate === "pending") return "pending";

  const expected = sampleDefault(entry, figmaExport);
  if (expected.length === 0) return "pass"; // gate-exempt: iconTable / code-only (C5)

  const records = latestRunRecords(resultsDir).filter((r) => r.entryId === entry.cemTag);
  const recordByStateId = new Map(records.map((r) => [r.stateId, r]));

  for (const { stateId } of expected) {
    if (!recordByStateId.has(stateId)) return "pending"; // missing renders
  }

  const allPass = expected.every(({ stateId }) => recordByStateId.get(stateId).pass === true);
  return allPass ? "pass" : "failed";
}

// diffPaths(entry, { resultsDir }) -> string[] (sorted) — the diff-artifact
// path (C4 diff.mjs's `artifacts.diff`) for every FAILING record of
// entry.cemTag in the latest results run. [] whenever there's nothing to
// show: no failing records (a "pass"/"approved"/"pending"/"rejected" entry
// has none), or no results at all yet. Never throws — this is a "here's the
// diff to look at" convenience for a summary, not a second gate.
//
// Task C7 (src/publish/runner.mjs's per-binding gate summary): the runner
// calls this ONLY for entries whose `status()` resolved to "failed", to
// surface the diff artifact path(s) next to the blocked cemTag in its run
// summary, per this task's brief. Shares `latestRunRecords`/`resultsDir`
// with `status()` above (same "latest run" convention) rather than
// re-deriving pass/fail itself — single source of truth stays diff.mjs's
// own `pass` field.
export function diffPaths(entry, options = {}) {
  const { resultsDir = DEFAULT_RESULTS_DIR } = options;
  const records = latestRunRecords(resultsDir).filter(
    (r) => r.entryId === entry.cemTag && r.pass === false && r.artifacts?.diff
  );
  return records.map((r) => r.artifacts.diff).sort(byString);
}

export default status;
