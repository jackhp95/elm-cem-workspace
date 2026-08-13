// Runner: iterate the target set node ids, capture each set over the bridge,
// write PNGs to <rendersRoot>/<setId>/<variantId>.png and persist the sidecar
// incrementally (flush after each set) so the pass resumes on crash/interrupt.
import fs from "node:fs";
import path from "node:path";
import { wsQuery } from "./lib/ws-query.mjs";
import { emptyCaptures, loadCaptures, saveCaptures, upsertSetCaptures, capturedSetIds } from "../src/capture/captures.mjs";

const seg = (id) => id.replace(/:/g, "-");   // ":" is invalid in Windows paths; normalize for filenames

// Variants captured per capture_set call. Small enough that even a set of
// heavy / temp-frame variants fits one WS timeout — the 120-variant set
// 52798:24373 timed out when captured whole, so the ceiling is render-TIME per
// response, not just payload size — yet large enough to bound round-trips.
const CAPTURE_CHUNK = 50;

// Live capture_set over the bridge, PAGINATED. Injectable so tests pass a fake.
// The plugin dispatcher pulls the target off `params.nodeId` (uniform across
// every bridge command — see handleBridgeCmd), so the wire param MUST be
// `nodeId`, not `setNodeId` (a fake captureSet never caught this; only the live
// contract does). Each capture_set returns a PAGE of <=chunk variants + the
// set's `total`; we walk offset and merge client-side, so no single response
// carries hundreds of base64 PNGs. `query`/`chunk` are injectable for tests.
export function bridgeCaptureSet(channel, scale, query = wsQuery, chunk = CAPTURE_CHUNK) {
  return async (setNodeId) => {
    let offset = 0;
    let total = Infinity;
    let setName;
    const variants = [];
    while (offset < total) {
      const res = await query("capture_set", { nodeId: setNodeId, scale, offset, limit: chunk }, { channel, timeoutMs: 120000 });
      if (!res || res.error) throw new Error(`capture_set(${setNodeId}@${offset}): ${res && res.error}`);
      setName = res.setName;
      total = typeof res.total === "number" ? res.total : res.variants.length;
      variants.push(...res.variants);
      if (!res.variants.length) break;   // non-advancing page — stop rather than loop forever
      offset += res.variants.length;
    }
    return { setNodeId, setName, variants, total: variants.length };
  };
}

export async function runCapture({ setNodeIds, profile, scale = 2, sidecarPath, rendersRoot, captureSet, force = false }) {
  let c = loadCaptures(sidecarPath) || emptyCaptures(profile, scale);
  const done = new Set(force ? [] : capturedSetIds(c));
  const outDir = path.dirname(sidecarPath);

  const skipped = [];
  for (const setNodeId of setNodeIds) {
    if (done.has(setNodeId)) continue;
    let result;
    try {
      result = await captureSet(setNodeId);
    } catch (e) {
      // A set that times out or errors at the bridge (e.g. a 480-variant set
      // whose single WS response is too large) must NOT abort the whole
      // resumable sweep. Skip it — it stays uncaptured, so a later resume (or a
      // chunked capture) retries it — and record it for the caller's summary.
      process.stderr.write(`capture: SKIP set ${setNodeId}: ${e.message}\n`);
      skipped.push({ setNodeId, error: e.message });
      continue;
    }
    const variants = result.variants.map((v) => {
      // A variant the plugin could not render comes back with `error` and no
      // imageData (per-variant try/catch in capture_set). Keep the error record
      // in the sidecar — write no PNG, no renderPath — so one bad variant never
      // aborts the whole (resumable) run. resolveCaptureByVariant treats a
      // missing renderPath as "not captured" and the gate falls back to live.
      if (!v.imageData) {
        const { imageData, ...meta } = v;
        return meta;
      }
      const renderPath = path.join(path.basename(rendersRoot), seg(setNodeId), `${seg(v.variantNodeId)}.png`);
      const absDir = path.join(outDir, path.dirname(renderPath));
      fs.mkdirSync(absDir, { recursive: true });
      fs.writeFileSync(path.join(outDir, renderPath), Buffer.from(v.imageData, "base64"));
      const { imageData, ...meta } = v;   // strip the base64 from the sidecar; it lives on disk
      return { ...meta, renderPath: renderPath.split(path.sep).join("/") };
    });
    c = upsertSetCaptures(c, { setNodeId, setName: result.setName, variants });
    saveCaptures(sidecarPath, c);         // incremental flush = resumable
  }
  return { captures: c, skipped };
}
