// Task C6, Steps 1-2 + 4: the human review webapp — `node:http`, no
// framework (matches src/visual/harness/static-server.mjs's own convention).
// Lists pending FAILURES from the latest results run (src/visual/status.mjs's
// latestRunRecords) and lets a human approve/reject/retarget each one; every
// action WRITES IMMEDIATELY into the profile's overrides.json (no bulk-save
// to lose — task brief's ⚑ HUMAN Step 4 requirement) via the SAME
// upsertOverride merge machinery Plan A's binding-confirm flow established
// (src/correspond/review.mjs).
//
// -- Scope split (this task's SCOPE note) -------------------------------------
// Everything in this file is offline-buildable and unit-testable WITHOUT a
// real browser: buildQueue/approve/reject/retarget are plain functions
// (server.test.mjs calls them directly), and createServer's http.Server can
// be driven with real (loopback-only) HTTP requests in-process. The one
// thing genuinely deferred (⚑ HUMAN) is a person looking at the code/figma/
// diff PNGs in ui.html and clicking a button — that click ultimately POSTs
// to exactly the same /api/approve|reject|retarget routes this file's own
// tests already exercise.
//
// -- Metadata note: rationale + note, no second mutable field -----------------
// The brief says reject's "note lands in the entry's rationale". This module
// does NOT write into correspondence.json's `rationale` field (that file
// stays untouched by C6 entirely — protected human/confirmed entries are
// never silently mutated, per merge.mjs's isProtected()). Instead,
// effectiveRationale() below SYNTHESIZES the displayed rationale at read
// time by joining the correspondence entry's stored rationale with the
// override's note (the same `" | "`-joined convention merge.mjs's own
// joinedRationale() uses for combining rationale fragments) — one mutable
// store (overrides.json), not two.
//
// Zero new deps.

import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadProfile, readCorrespondence } from "../../correspond/merge.mjs";
import { readOverrides, upsertOverride, clearGateDecision } from "../../correspond/review.mjs";
import { loadFigmaExport } from "../../ingest/figma.mjs";
import { byKey } from "../../lib/order.mjs";
import { status, latestRunId, latestRunRecords, DEFAULT_RESULTS_DIR } from "../status.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..", "..");

const UI_HTML_PATH = path.join(here, "ui.html");

// -- rationale synthesis (read-time only; see header) -------------------------

export function effectiveRationale(entry, override) {
  const base = entry?.rationale ?? "";
  if (!override?.note) return base;
  const label = override.gate === "rejected" ? "REJECTED" : override.gate === "approved" ? "APPROVED" : "RETARGETED";
  return [base, `${label}: ${override.note}`].filter((s) => s.length > 0).join(" | ");
}

// -- artifact path resolution (bounds serving to the cache root) -------------

// resolveArtifactPath(cacheRoot, artifactPath) -> absolute path, guaranteed
// to live under cacheRoot, or null if it doesn't (refuses to serve it).
// Results records may carry either an absolute artifact path (tests that
// pass an absolute scratch cacheDir to writeResultRecord) or one relative to
// the repo root (the real default cacheDir, "render-cache") — both resolve
// the same way here.
export function resolveArtifactPath(cacheRoot, artifactPath) {
  const resolved = path.isAbsolute(artifactPath) ? artifactPath : path.resolve(repoRoot, artifactPath);
  const boundary = path.resolve(cacheRoot);
  if (resolved !== boundary && !resolved.startsWith(boundary + path.sep)) return null;
  return resolved;
}

function imageUrl(artifactPath) {
  if (!artifactPath) return null;
  return `/api/image?path=${encodeURIComponent(artifactPath)}`;
}

// -- the review queue ----------------------------------------------------

// buildQueue({ profileDir, resultsDir, overridesPath, figmaExport }) ->
//   { runId, items: [{ cemTag, stateId, diffRatio, threshold, rationale,
//     matcherKind, artifacts: {code, figma, diff} (as /api/image URLs) }] }
//
// An item is included iff its record FAILED (pass:false) in the latest run
// AND the entry's CURRENT derived status() is still "failed" — i.e., an
// already-approved/rejected/retargeted entry drops out of the queue the
// moment its override is written, without this function needing to know
// anything about overrides itself (status() already folds that in).
// Deterministic ordering: cemTag then stateId, ordinal (../lib/order.mjs).
export function buildQueue({ profileDir, resultsDir = DEFAULT_RESULTS_DIR, overridesPath, figmaExport }) {
  const correspondencePath = path.join(profileDir, "correspondence.json");
  const entries = readCorrespondence(correspondencePath);
  const byTag = new Map(entries.map((e) => [e.cemTag, e]));
  const overrides = readOverrides(overridesPath);
  const overrideByTag = new Map(overrides.map((d) => [d.cemTag, d]));

  const runId = latestRunId(resultsDir);
  const records = latestRunRecords(resultsDir);

  const items = [];
  for (const record of records) {
    if (record.pass !== false) continue;
    const entry = byTag.get(record.entryId);
    if (!entry) continue; // a stray/removed cemTag — nothing to review against
    if (status(entry, { resultsDir, overridesPath, figmaExport }) !== "failed") continue;

    items.push({
      cemTag: entry.cemTag,
      stateId: record.stateId,
      diffRatio: record.diffRatio,
      threshold: record.threshold,
      matcherKind: entry.matcherKind ?? entry.kind ?? "component",
      rationale: effectiveRationale(entry, overrideByTag.get(entry.cemTag)),
      artifacts: {
        code: imageUrl(record.artifacts?.code),
        figma: imageUrl(record.artifacts?.figma),
        diff: imageUrl(record.artifacts?.diff),
      },
    });
  }

  items.sort(byKey((i) => `${i.cemTag}${i.stateId}`));
  return { runId, items };
}

// -- action handlers (write immediately; see module header) ------------------
//
// Each returns { cemTag, gate } for a caller (the HTTP layer, or a direct
// test call) to confirm the write took, without needing to re-derive
// status() itself — though a fresh status(entry, {resultsDir, overridesPath})
// call is expected to agree (and IS what the C6 verify step asserts).

// WB-fix round: these writes deliberately do NOT include `provenance`. The
// visual gate (src/visual/status.mjs) only ever reads `override.gate` — it
// never reads `provenance` — so a gate decision has no business writing that
// field. Plan A's confirmFromDecisions (src/correspond/review.mjs) DOES read
// `provenance` off a decision with no `status`, and stamps it straight onto
// the CORRESPONDENCE entry; a human who only eyeballed a pixel diff here
// (never confirmed the binding) must not thereby silently protect that
// entry via merge.mjs's isProtected(). See task-C6-report.md's WB-fix round.
export function approve({ overridesPath, cemTag, note }) {
  upsertOverride(overridesPath, cemTag, { gate: "approved", ...(note ? { note } : {}) });
  return { cemTag, gate: "approved" };
}

export function reject({ overridesPath, cemTag, note }) {
  upsertOverride(overridesPath, cemTag, { gate: "rejected", ...(note ? { note } : {}) });
  return { cemTag, gate: "rejected" };
}

// retarget: "frees the binding back to pending after the human edits the
// mapping" (brief) — CLEARS this cemTag's visual-gate override fields
// (review.mjs's clearGateDecision) rather than writing a sticky
// gate:"pending". A sticky override used to strand the entry in "pending"
// FOREVER (status() checks the override branch BEFORE consulting results —
// see status.mjs's derivation-order comment), even after a fully-passing
// re-render, and buildQueue only lists `failed` items, so a stranded entry
// could never even reappear in the review queue to be un-stuck. Clearing
// the decision instead lets status() fall through to results-derivation:
// "pending" only while renders are genuinely missing, "pass"/"failed" from
// the latest run otherwise — so a FRESH render run naturally resolves a
// retargeted entry, whichever way it goes. Any coexisting Plan A
// status/provenance decision on the SAME cemTag survives untouched (see
// clearGateDecision).
//
// `note`: the reviewer's reason for retargeting. We MUST NOT drop it (doing
// so silently lost a whole review session's retarget comments once). But we
// also must not re-strand the entry — so we persist it as `retargetNote`, a
// STATUS-NEUTRAL field: status() only consults `gate` (absent here), so the
// entry still falls through to results-derivation, while the comment
// survives on disk for the next author to read. `retargetNote` also survives
// a future clearGateDecision (which only strips `gate`/`note`), so repeated
// retargets don't lose it.
export function retarget({ overridesPath, cemTag, note }) {
  clearGateDecision(overridesPath, cemTag);
  if (note && String(note).trim()) upsertOverride(overridesPath, cemTag, { retargetNote: String(note) });
  return { cemTag, gate: "pending" };
}

// -- HTTP layer ----------------------------------------------------------

function sendJson(res, statusCode, body) {
  const text = JSON.stringify(body);
  res.writeHead(statusCode, { "content-type": "application/json; charset=utf-8", "content-length": Buffer.byteLength(text) });
  res.end(text);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = "";
    req.on("data", (chunk) => (data += chunk));
    req.on("end", () => {
      if (data.trim().length === 0) return resolve({});
      try {
        resolve(JSON.parse(data));
      } catch (err) {
        reject(err);
      }
    });
    req.on("error", reject);
  });
}

// createRequestHandler(ctx) -> (req, res) => void
//
// ctx: { profileDir, resultsDir, overridesPath, cacheRoot, figmaExport }.
// Exported (not just wrapped inside createServer) so a test can call it
// directly against hand-built req/res mocks if it ever wants to, without
// binding a real socket — createServer below is the convenience wrapper
// that DOES bind one, for the one end-to-end HTTP-round-trip test this
// task's brief also wants.
export function createRequestHandler(ctx) {
  const actionFor = { approve, reject, retarget };

  return async function handleRequest(req, res) {
    const url = new URL(req.url, "http://localhost");

    try {
      if (req.method === "GET" && url.pathname === "/") {
        const html = fs.readFileSync(UI_HTML_PATH, "utf8");
        res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
        res.end(html);
        return;
      }

      if (req.method === "GET" && url.pathname === "/api/queue") {
        sendJson(res, 200, buildQueue(ctx));
        return;
      }

      if (req.method === "GET" && url.pathname === "/api/image") {
        const requested = url.searchParams.get("path");
        const resolved = requested ? resolveArtifactPath(ctx.cacheRoot, requested) : null;
        if (!resolved || !fs.existsSync(resolved) || !fs.statSync(resolved).isFile()) {
          res.writeHead(404).end("not found");
          return;
        }
        res.writeHead(200, { "content-type": "image/png", "cache-control": "no-store" });
        fs.createReadStream(resolved).pipe(res);
        return;
      }

      const actionMatch = /^\/api\/(approve|reject|retarget)$/.exec(url.pathname);
      if (req.method === "POST" && actionMatch) {
        const body = await readBody(req);
        if (!body.cemTag) {
          sendJson(res, 400, { error: "cemTag is required" });
          return;
        }
        const action = actionFor[actionMatch[1]];
        const result = action({ overridesPath: ctx.overridesPath, cemTag: body.cemTag, note: body.note });
        sendJson(res, 200, { ...result, queue: buildQueue(ctx) });
        return;
      }

      res.writeHead(404).end("not found");
    } catch (err) {
      sendJson(res, 500, { error: err.message });
    }
  };
}

// createServer(ctx, port = 0) -> Promise<{ server, baseUrl, close }> — same
// shape convention as src/visual/harness/static-server.mjs's startServer.
// Defaults to an ephemeral loopback-only port (never 0.0.0.0) so tests can
// spin up a real server without a fixed-port collision risk; the CLI below
// passes an explicit `--port` when a human wants a stable, memorable URL.
export function createServer(ctx, port = 0, host = "127.0.0.1") {
  const server = http.createServer(createRequestHandler(ctx));
  return new Promise((resolve) => {
    server.listen(port, host, () => {
      // For the loopback default the address IS the reachable host; when bound
      // to 0.0.0.0 (opt-in --host, e.g. tailnet review) the wildcard is not a
      // dialable URL, so advertise the tailnet/LAN host the human passed.
      const shown = host === "0.0.0.0" ? "0.0.0.0" : host;
      resolve({
        server,
        baseUrl: `http://${shown}:${server.address().port}`,
        close: () => new Promise((r) => server.close(r)),
      });
    });
  });
}

// -- CLI mode: `node src/visual/review/server.mjs --profile m3-kit [--port N]`

function parseCliArgs(argv) {
  const args = { profile: "m3-kit" };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (!arg.startsWith("--")) continue;
    const eq = arg.indexOf("=");
    if (eq !== -1) {
      args[arg.slice(2, eq)] = arg.slice(eq + 1);
    } else {
      args[arg.slice(2)] = argv[i + 1];
      i++;
    }
  }
  return args;
}

// runServer({ profileName, port, repoRoot }) -> Promise<{ baseUrl, close }>
// Prints the ⚑ HUMAN-required start-of-session summary count, then serves.
// The destructured local is named `baseRepoRoot` (not `repoRoot`) purely so
// its default-value expression can refer to this module's own top-level
// `repoRoot` constant (computed from import.meta.url) without the parameter
// name shadowing it.
export async function runServer({ profileName = "m3-kit", port = 0, host = "127.0.0.1", repoRoot: baseRepoRoot = repoRoot } = {}) {
  const profileDir = path.join(baseRepoRoot, "profiles", profileName);
  const profile = loadProfile(profileDir);
  const resultsDir = path.join(baseRepoRoot, "render-cache", "results");
  const overridesPath = path.join(profileDir, "overrides.json");
  const cacheRoot = path.join(baseRepoRoot, "render-cache");
  const figmaExport = loadFigmaExport(profile.figmaExportPath);

  const ctx = { profileDir, resultsDir, overridesPath, cacheRoot, figmaExport };
  const queue = buildQueue(ctx);

  console.log(
    queue.runId
      ? `visual review (${profileName}): ${queue.items.length} pending failure(s) to review (run ${queue.runId})`
      : `visual review (${profileName}): no results run found yet under ${resultsDir}`
  );

  const { server, baseUrl, close } = await createServer(ctx, port, host);
  console.log(`visual review server listening at ${baseUrl}`);
  return { server, baseUrl, close };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const args = parseCliArgs(process.argv.slice(2));
  await runServer({ profileName: args.profile, port: args.port ? Number(args.port) : 0, host: args.host || "127.0.0.1" });
}
